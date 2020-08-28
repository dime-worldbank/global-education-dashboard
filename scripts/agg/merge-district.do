/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: merge-district.do
Function: merges the district-level averages to countries
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


								* | Merge at district level, all tiers | *


	use `"${D_sch}"', clear  					// start with schools dataset

		sort countryname g1 g2

		preserve
			merge 			m:1 	countryname g2 	///
									using "${publicofficial}/Dataset/col_po_g2_alltier.dta" ///
									, gen(merge)

			* 1.  verify quality of the merge BEFORE dropping
			/* run schoolcheck.do */



			* 2.  Generate top/bottom quartile tags
			* generate a variable that lists the number of schools in each district
			preserve

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

			restore		// this brings back dataset we just created in merging.

			* use merged dataset, mege with merged-bi-nschools-by-district.dta
			merge m:1 	country g2 ///
						using "${baseline_dt}/Intermediate/m-bi-nschools-by-district-alltier.dta" ///
						, assert(match) /// everything should match perfectly
						keepusing(t_bi t_national_learning_goals t_mandates_accountability t_quality_bureaucracy t_impartial_decision_making l_bi l_national_learning_goals l_mandates_accountability l_quality_bureaucracy l_impartial_decision_making)




			* 3. Save whole dataset ...
				la data 	"School indicators with all tiers of officials averaged by district; all matches"
				save 		"${baseline_dt}/Intermediate/merge_district_alltiers_nomatch.dta", replace

			* Then drop non-mereged obs and...
				keep if 	merge == 3
				drop		merge

			* Verify quality of dataset after the drop.
				/* run another checkscript (diff cuz this time we loose school obs) */

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

			* 1.  verify quality of the merge BEFORE dropping
			/* run schoolcheck.do */



			* 2.  Generate top/bottom quartile tags
			* generate a variable that lists the number of schools in each district
			preserve

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

			restore		// this brings back dataset we just created in merging.

			* use merged dataset, mege with merged-bi-nschools-by-district.dta
			merge m:1 	country g2 ///
						using "${baseline_dt}/Intermediate/m-bi-nschools-by-district-tier3.dta.dta" ///
						, assert(match) /// everything should match perfectly
						keepusing(t_bi t_national_learning_goals t_mandates_accountability t_quality_bureaucracy t_impartial_decision_making l_bi l_national_learning_goals l_mandates_accountability l_quality_bureaucracy l_impartial_decision_making)



			* 3. Save whole dataset ...
				la data 	"School indicators w/ only district officials averaged by district; all matches"
				save 		"${baseline_dt}/Intermediate/merge_district_tdist_nonmatch.dta", replace

			* Then drop non-mereged obs and...
				keep if 	merge == 3
				drop		merge

			* Verify quality of dataset after the drop.
				/* run another checkscript (diff cuz this time we loose school obs) */

				* save the dataset as a new version.
				la data 	"School indicators w/ only district officials averaged by district"
				save 		"${baseline_dt}/final/merge_district_tdist.dta", replace

		restore
