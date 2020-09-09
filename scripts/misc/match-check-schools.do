* match-check-schools.do
* util that uses the district and region- merged dataset to map info on to main schools dataset to tell what observations will be kept/dropped

/*


NOTE 9 SEPT, 2020: 	this file is basically obscolete as these variables are created in the main datasets in R. will not be 
					run starting now.

*/


							*| create a tempfile from D_sch 	|*
						/*	this tempfile is a copy of the de-identified school
						  	dataset that will become E_school. */

use 	`"${D_sch}"', clear
preserve

tempfile smatch
save 	 `smatch', replace

restore 			// this restores D_school
clear



							*| For district-level merge, all tiers 	|*

use 	"${baseline_dt}/final/merge_district_alltiers.dta", clear
preserve

* 1. Extract observations that made it to the district merged dataset

keep 		idschool country 			// keep only the id vars
gen 		int dist_merge_keep1	= 1 // generate indicator saying that this id will be kept in the district match

tempfile 	distkeep 				// save as tempfile
save 		`distkeep'

restore
clear


* 2. Merge these obs back onto main dataset

use 		 `smatch', clear			// main school dataset

merge 		1:1 /// merge type
			country idschool  /// key vars
			using `distkeep' ///
			, assert(master match) // every single obs should match


* 3. Now replace dist_merge_keep for all missing vars as 0

replace 	dist_merge_keep1 = 0 	if dist_merge_keep1 == .
la var 		dist_merge_keep1 		"Indicator if obs will be kept in district schools dataset (all tiers)"

save 		`smatch', replace




							*| For district-level merge, district only tier 	|*

use 	"${baseline_dt}/final/merge_district_tdist.dta", clear
preserve

* 1. Extract observations that made it to the district merged dataset

keep 		idschool country 			// keep only the id vars
gen 		int dist_merge_keep2	= 1 // generate indicator saying that this id will be kept in the district match

tempfile 	distkeep 				// save as tempfile
save 		`distkeep'

restore
clear


* 2. Merge these obs back onto main dataset

use 		`smatch'			// main school dataset

merge 		1:1 /// merge type
			country idschool  /// key vars
			using `distkeep' ///
			, assert(master match) // every single obs should match


* 3. Now replace dist_merge_keep for all missing vars as 0

replace 	dist_merge_keep2 = 0 	if dist_merge_keep2 == .
la var 		dist_merge_keep2 		"Indicator if obs will be kept in district schools dataset (dist-only tier)"

save 		`smatch', replace








							*| For region-level merge, all tiers 	|*

use 	"${baseline_dt}/final/merge_region_alltiers.dta", clear
preserve

* 1. Extract observations that made it to the district merged dataset

keep 		idschool country 			// keep only the id vars
gen 		int region_merge_keep1	= 1 // generate indicator saying that this id will be kept in the district match

tempfile 	distkeep 				// save as tempfile
save 		`distkeep'

restore
clear


* 2. Merge these obs back onto main dataset

use 		`smatch'			// main school dataset

merge 		1:1 /// merge type
			country idschool  /// key vars
			using `distkeep' ///
			, assert(master match) // every single obs should match


* 3. Now replace dist_merge_keep for all missing vars as 0

replace 	region_merge_keep1 = 0 	if region_merge_keep1 == .
la var 		region_merge_keep1 		"Indicator if obs will be kept in region schools dataset (all tiers)"


* **** Final Save. *****
save 		`"${E_sch}"', replace


/*** ttests

iebaltab 	student_knowledge ecd_student_knowledge inputs infrastructure intrinsic_motivation ///
			content_knowledge pedagogical_knowledge operational_manage instr_leader ///
			principal_knowl_score principal_manage ///
			, grpvar(dist_merge_keep) ///
			save(`"${GLOBE_out}/baltab/school-district-merge.xlsx"') ///
			replace rowvarlabels
