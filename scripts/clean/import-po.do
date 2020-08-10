/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: import-po.do
Function: runs all the scripts for the cleaning portion.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


							* | 	Append using iecodebook	| *

							/* 	use iecodebook to harmonized
								variable names
								across all datasets 		*/

use 			"A:/main/final_main_po_data.dta", clear  // path to PER survey

* create a template using iecodebook %% note, will use files with long names
iecodebook template ///
			using `"${mastData}/codebooks/po-4countries.xlsx"', replace	// path to codebook


		/*excel editing happens manually here. */


* apply to all datasets
iecodebook apply ///
			using `"${mastData}/codebooks/po-4countries.xlsx"'	// path to codebook





								* | Add country number var | *

* convert to categorical variable with labels (move this into script?)
do `"${scripts_clone}/mother/utils/countryname.do"'





									* | ID Check | *

						/* countryname and school code should uniquely identify
						each observation. */


capture  	isid countryname interview__id

	if _rc {
		duplicates 	drop 	countryname interview__id national_learning_goals lat lon, force	// drop obs that are same on these vars
							/*it is very unlikely to have two schools with the same id and test score that are dif */
		isid 				countryname interview__id
	}

	save "${A_po}", replace
