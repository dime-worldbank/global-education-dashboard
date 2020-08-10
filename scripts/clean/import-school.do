/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: import-school.do
Function: runs all the scripts for the cleaning portion.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


							* | 	Append using iecodebook	| *

							/* 	use iecodebook to harmonized
								variable names
								across all datasets 		*/

use 			"A:/main/final_main_school_data.dta", clear  // path to PER survey

if (0) {
* create a template using iecodebook
iecodebook template ///
			 "A:/Countries/Peru/Data/school_indicator_dta_confidential.dta" /// path to Peru
			 "A:/Countries/Jordan/Data/final_indicator_school_data.dta" /// Path to jordan
			 "A:/Countries/Mozambique/Data/school_inicators_data.dta" /// path to moz
			 "A:/Countries/Rwanda/Data/final_indicator_school_data.dta" /// path to rwanda
			 using `"${mastData}/codebooks/schools.xlsx"' /// path to codebook
			, replace surveys($countrynames) generate(country)
}

		/*excel editing happens manually here. */


* apply to all datasets
* %% this will not run unless you delete the _appended.xlsx, and replace option wont work
iecodebook append ///
			 "A:/Countries/Peru/Data/school_indicator_dta_confidential.dta" /// path to Peru
			 "A:/Countries/Jordan/Data/final_indicator_school_data.dta" /// Path to jordan 
			 "A:/Countries/Mozambique/Data/school_inicators_data.dta" /// path to moz
			 "A:/Countries/Rwanda/Data/final_indicator_school_data.dta" /// path to rwanda
			 using `"${mastData}/codebooks/schools.xlsx"' /// path to codebook
			, replace surveys($countrynames) generate(country)
}




									* | Add country number var | *

* convert to categorical variable with labels (move this into script?)
do `"${scripts_clone}/mother/utils/countryname.do"'





									* | ID Check | *

						/* countryname and school code should uniquely identify
						each observation. */


capture  	isid countryname school_code

	if _rc {
		duplicates 	drop 	countryname school_code student_knowledge lat lon, force	// drop obs that are same on these vars
							/*it is very unlikely to have two schools with the same id and test score that are dif */
		isid 				countryname school_code
	}

	save "${A_sch}", replace
