/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: merge-district.do
Function: merges the district-level averages to countries
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


				/* 	This script conducts two merges: the first merge amounts
					to matching the individual school observations to the
					district-averaged bureaucracy scores. The second merge will
					then adds on district-averaged conditional variables pulled
					from IPUMS, such as literacy rates/median age in the district.

				*/


						* | Merge at district level, all tiers | *


	use `"${D_sch}"', clear  					// start with schools dataset

		sort countryname g1 g2

		preserve
			merge 			m:1 	countryname g2 	///
									using "${publicofficial}/Dataset/col_po_g2_alltier.dta" ///
									, gen(merge)

			* save as tempfile, will need later
			tempfile 	mergeg2
			save 		`mergeg2'

			* 1.  verify quality of the merge BEFORE dropping
			/* run schoolcheck.do */



			* 2.  Generate top/bottom quartile tags
			* generate a variable that lists the number of schools in each district


			* tag schools in areas that are in the lower quartile of 5 bureaucracy indicators
			collapse (mean) ${bi} nsch_dist, by(country g2)

			foreach bi of global bi {
				// determine the quartile values
				sum 		`bi', d
				// tag the schools if their bi value is in bottom quartile
				gen 		byte l_`bi' = (`bi' <= r(p25))
				la var 		l_`bi' `"Score of `bi' is in lowest quartile of district averages"'
				// tag if in top quartile
				gen 		byte t_`bi' = (`bi' >= r(p75))
				la var 		t_`bi' `"Score of `bi' is in highest quartile of district averages"'
			}

			* save snippet as realfile to merge back on to md dataset
			save 		"${baseline_dt}/Intermediate/m-bi-nschools-by-district-alltier", replace

			use 		`mergeg2', clear		// this brings back dataset we just created in merging.

			* use merged dataset, mege with merged-bi-nschools-by-district.dta
			merge m:1 	country g2 ///
						using "${baseline_dt}/Intermediate/m-bi-nschools-by-district-alltier.dta" ///
						, assert(match) /// everything should match perfectly
						keepusing(t_bi t_national_learning_goals t_mandates_accountability t_quality_bureaucracy t_impartial_decision_making l_bi l_national_learning_goals l_mandates_accountability l_quality_bureaucracy l_impartial_decision_making)




			* 3. Save whole dataset ...
				la data 	"School indicators with all tiers of officials averaged by district; all matches"
				save 		"${baseline_dt}/Intermediate/merge_district_alltiers_nomatch.dta", replace

			* Then drop non-mereged obs and empty observations
				keep if 	merge == 3
				drop		merge

				// drop all obs that are missing on most values
				drop if 	countryname == "" 	& g1 == . 	& g2 == .

			* Verify quality of dataset after the drop.
				/* run another checkscript (diff cuz this time we loose school obs) */

			* 4. Merge the IPUMS data
			merge m:1 	g2 ///
						using "${encryptFolder}/main/school_dist_conditionals.dta" ///
						, assert(using match)  /// there are more districts in ipums than our data
						gen(ipums_merge) ///
						force  	 //convert countryname from long to str10

				* keep only match, drop that variable
				keep if 	ipums_merge == 3
				drop		ipums_merge


			* 5. Mege the District Enrollment data
			merge m:1 	g2 ///
						using "${encryptFolder}/main/by-district-enrollment.dta" ///
						, assert(using match)  /// there are more districts in using than our data
						gen(enroll_merge) ///
						keepusing(ln_dist_n_stud)

				* keep only necessary vars
				keep 		${finalvars}


				* save the dataset as a new version.
				la data 	"School indicators with all tiers of officials averaged by district"
				save 		"${baseline_dt}/final/merge_district_alltiers.dta", replace

		restore








					* | Merge at district level, only district level bureaucrats | *


		sort countryname g1 g2

		preserve

			* merge
				merge 		m:1 	countryname g2 	///
									using "${publicofficial}/Dataset/col_po_g2_tier3.dta" ///
									, gen(merge)

			* save as tempfile, will need later
			tempfile 	mergeg2b // "a" is above, careful not to mess with overwriting tempfiles, etc
			save 		`mergeg2b'

			* 1.  verify quality of the merge BEFORE dropping
			/* run schoolcheck.do */



			* 2.  Generate top/bottom quartile tags
			* generate a variable that lists the number of schools in each district


			* tag schools in areas that are in the lower quartile of 5 bureaucracy indicators
			collapse (mean) ${bi} nsch_dist, by(country g2)

			foreach bi of global bi {
				// determine the quartile values
				sum 		`bi', d
				// tag the schools if their bi value is in bottom quartile
				gen 		byte l_`bi' = (`bi' <= r(p25))
				la var 		l_`bi' `"Score of `bi' is in lowest quartile of district averages"'
				// tag if in top quartile
				gen 		byte t_`bi' = (`bi' >= r(p75))
				la var 		t_`bi' `"Score of `bi' is in highest quartile of district averages"'
			}

			* save snippet as realfile to merge back on to md dataset
			save 		"${baseline_dt}/Intermediate/m-bi-nschools-by-district-tier3.dta", replace

			use 		`mergeg2b', clear		// this brings back dataset we just created in merging.

			* use merged dataset, mege with merged-bi-nschools-by-district.dta
			merge m:1 	country g2 ///
						using "${baseline_dt}/Intermediate/m-bi-nschools-by-district-tier3.dta" ///
						, assert(match) /// everything should match perfectly
						keepusing(t_bi t_national_learning_goals t_mandates_accountability t_quality_bureaucracy t_impartial_decision_making l_bi l_national_learning_goals l_mandates_accountability l_quality_bureaucracy l_impartial_decision_making)



			* 3. Save whole dataset ...
				la data 	"School indicators w/ only district officials averaged by district; all matches"
				save 		"${baseline_dt}/Intermediate/merge_district_tdist_nonmatch.dta", replace

			* Then drop non-mereged obs and...
				keep if 	merge == 3
				drop		merge

				// drop all obs that are missing on most values
				drop if 	countryname == "" 	& g1 == . 	& g2 == .


			* Verify quality of dataset after the drop.
				/* run another checkscript (diff cuz this time we loose school obs) */


			* 4. Merge the IPUMS data
			merge m:1 	g2 ///
						using "${encryptFolder}/main/school_dist_conditionals.dta" ///
						, assert(using match)  ///
						gen(ipums_merge) ///
						force // force strL into str10



			* ensure the observation count is accurate
			count if 	idschool != .
			assert 		r(N) == 191 	// should be school 320 observations $magic, now 191

			* keep only match, drop that variable
			keep if 	ipums_merge == 3
			drop 		ipums_merge



			* 5. Mege the District Enrollment data
			merge m:1 	g2 ///
						using "${encryptFolder}/main/by-district-enrollment.dta" ///
						,   /// there are more districts in using than our data    assert(using match)
						gen(enroll_merge) ///
						keepusing(ln_dist_n_stud)


			* keep only match, drop that variable
			keep if 	enroll_merge == 3
			drop 		enroll_merge


			* ensure the observation count is accurate
			count if	idschool != .
			assert 		r(N) == 191 	// should be school 320 observations, formerly magic, now 191





				* keep only necessary vars
				keep 		${finalvars}


				* save the dataset as a new version.
				la data 	"School indicators w/ only district officials averaged by district"
				save 		"${baseline_dt}/final/merge_district_tdist.dta", replace

		restore
