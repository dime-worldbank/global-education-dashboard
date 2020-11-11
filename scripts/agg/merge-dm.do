/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: merge-dm.do
Function: merges the district-level averages to countries
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


				/* 	This script conducts two merges: the first merge amounts
					to matching the individual school observations to the
					district-averaged bureaucracy scores. The second merge will
					then adds on district-averaged conditional variables pulled
					from IPUMS, such as literacy rates/median age in the district.

				*/
				
				
						* | split up decision-making averages 'using' dataset | *
						
				/*	We want to merge the schools dataset with averaged bi indicators taken at the 
					decision-making level but the problem is, some countries only have g1 and not 
					g2 if the decision-making level is region (RWA) so when you merge, stata is 
					not smart enough to just ignore the 'missing' values in a m:1 merge, so we 
					have to load the tempfile and split it up into by g2 and by g1 merges. 
				
				*/

				
// load file, preserve
use 		"${publicofficial}/Dataset/col_po_dm.dta", clear 
preserve 


// split off the g2 obs 
keep if 	g2 != . 


// save as tempfile, restore 
tempfile 	g2 
save 		`g2'

restore 	// returns to full col_po_dm


// split off g1 
preserve 

keep if 	g2 == . 


// save as tempfile, restore, clear 
tempfile	g1 
save 		`g1'

restore 	// restores back to col_po_dm
clear 		// no data in memory now





						* | Merge at decision-making level, only appropriate tiers | *


	use `"${D_sch}"', clear  					// start with schools dataset



		** Merge at Disrict-level **   - 	-		-		-

		sort countryname g1 g2

		preserve

		* keep only district-level countries

			keep if  	countryname 	== "Peru" /// 	keep only countries agg'd at district level
						| countryname 	== "Jordan" ///
						| countryname	== "Mozambique"

			* merge with bureaucracy indicators
				merge 		m:1 	countryname g2 	///
									using `g2' /// merge with subset of col_po_dm with only non-missing obs for g2
									, gen(merge)


			* 1.  verify quality of the merge BEFORE dropping
			/* run schoolcheck.do */


			* Then drop non-mereged obs and...
				keep if 	merge == 3
				drop		merge

				// drop all obs that are missing on most values
				drop if 	countryname == "" 	& g1 == . 	& g2 == .


			* 2. Merge the IPUMS data
			merge m:1 	g2 ///
						using "${encryptFolder}/main/school_dist_conditionals.dta" ///
						, assert(using match)  ///
						gen(ipums_merge) ///
						force // force strL into str10



			* ensure the observation count is accurate
			count if 	idschool != .

			assert 		r(N) == 191	// should be school 191 observationsfor these three countries

			* keep only match, drop that variable
			keep if 	ipums_merge == 3
			drop 		ipums_merge



			* 3. Mege the District Enrollment data
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
			assert 		r(N) == 191	// should be school 191 observationsfor these three countries


			* save tempfile
			tempfile 	mergedist
			save 		`mergedist'


		restore 		// restore to main school dataset




		** Merge at Region-level **   - 	-		-		-


		preserve

		* keep only district-level countries

			keep if  	countryname 	== "Rwanda" // 	keep only countries agg'd at region

			* merge with bureaucracy indicators (this gets merged on g1/region )
				merge 		m:1 	countryname g1 	///
									using `g1' /// merge with subset of col_po_dm with only missing obs for g2, aka region level dm level
									, gen(merge)


			* 1.  verify quality of the merge BEFORE dropping
			/* run schoolcheck.do */


			* Then drop non-mereged obs and...
				keep if 	merge == 3
				drop		merge

				// drop all obs that are missing on most values
				drop if 	countryname == "" 	& g1 == .


			* 2. Merge the IPUMS data (this gets merged on district)
			merge m:1 	g2 ///
						using "${encryptFolder}/main/school_dist_conditionals.dta" ///
						,  /// assert(using match) 
						gen(ipums_merge) ///
						force // force strL into str10



			* ensure the observation count is accurate
			count if 	idschool != .
			assert 		r(N) == 200	// should be 200 schools for RWA

			* keep only match, drop that variable
			keep if 	ipums_merge == 3
			drop 		ipums_merge



			* 3. Mege the District Enrollment data (this also gets merged on district)
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

			assert 		r(N) == 200 	// should be school 200 schools for RWA observations


			* save tempfile
			tempfile 	mergereg
			save 		`mergereg'


		restore 		// restore to main schools dataset



* Append district and region -merged parts


* Append region and district tempfiles to create decision-making dataset

clear 						// clear D_sch

use 		 `mergedist' 	// use the district dataset
append using `mergereg' 	// append with the region-level dataset

 // check
count if	idschool != .
assert 		r(N) == ${magic} 	// should be school 391 school observations

* keep only necessary vars
keep 		${finalvars}

 // save
la data 	"Final Schools Dataset with district-lev conditionals and Decision-Making BI"
save 		"${baseline_dt}/final/final-schools-dataset.dta", replace


clear 
