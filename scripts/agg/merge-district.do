/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: merge-district.do
Function: merges the district-level averages to countries
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


								* | Merge at district level, all tiers | *


	use `"${D_sch}"', clear  					// start with schools dataset

		sort countryno g1 g2

		preserve
			merge 			m:1 	countryno g2 	///
									using "${publicofficial}/Dataset/col_po_g2_alltier.dta" ///
									, gen(merge)

			* verify quality of the merge BEFORE dropping
			/* run schoolcheck.do */

			* Save whole dataset ...

				save 		"${baseline_dt}/Intermediate/merge_district_alltiers_nomatch.dta", replace

			* Then drop non-mereged obs and...
				keep if 	merge == 3
				drop		merge matched

			* Verify quality of dataset after the drop.
				/* run another checkscript (diff cuz this time we loose school obs) */

				* save the dataset as a new version.
				save 		"${baseline_dt}/final/merge_district_alltiers.dta", replace

		restore








					* | Merge at district level, only district level bureaucrats | *


		sort countryno g1 g2

		preserve

			* keep only district officials
				keep if 		govt_tier == 3 	// where 3 == district

			* merge
				merge 		m:1 	countryno g2 	///
									using "${publicofficial}/Dataset/col_po_g2_tier3.dta" ///
									, gen(merge)

			* verify quality of the merge BEFORE dropping
			/* run schoolcheck.do */

			* Save whole dataset ...

				save 		"${baseline_dt}/Intermediate/merge_district_tdist_nonmatch.dta", replace

			* Then drop non-mereged obs and...
				keep if 	merge == 3
				drop		merge matched

			* Verify quality of dataset after the drop.
				/* run another checkscript (diff cuz this time we loose school obs) */

				* save the dataset as a new version.
				save 		"${baseline_dt}/final/merge_district_tdist.dta", replace

		restore
