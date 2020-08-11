/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: merge-region.do
Function: merges the region-level averages to countries
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


								* | Merge at region level | *


	use `"${D_sch}"', clear  					// start with schools dataset

		sort countryname g1 g2

		preserve

		* merge on region (g1)
				merge 		m:1 	countryname g1 	///
									using "${publicofficial}/Dataset/col_po_g1_alltier.dta" ///
									, gen(merge)

			* verify quality of the merge BEFORE dropping
			/* run schoolcheck.do */

			* Save whole dataset ...
				la data 	"School indicators with all tiers of officials averaged by region; all matches"
				save 		"${baseline_dt}/Intermediate/merge_region_alltiers_nonmatch.dta", replace

			* Then drop non-mereged obs and...
				keep if 	merge == 3

			* Verify quality of dataset after the drop.
				/* run another checkscript (diff cuz this time we loose school obs) */

				* save the dataset as a new version.
				la data 	"School indicators with all tiers of officials averaged by region"
				save 		"${baseline_dt}/final/merge_region_alltiers.dta", replace

		restore
