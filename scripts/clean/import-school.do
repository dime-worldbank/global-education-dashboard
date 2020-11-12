/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: import-school.do
Function: runs all the scripts for the cleaning portion.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


							* | 	Append using iecodebook	| *

							/* 	use iecodebook to harmonized
								variable names
								across all datasets 		*/


if (1) {
* create a template using iecodebook
iecodebook template ///
			 "B:/main/final_main_school_data.dta" /// path to main schools dataset
			 using `"${mastData}/codebooks/schools3.xlsx"' /// path to codebook
			, replace generate(country) match
}

		/*excel editing happens manually here. */


* apply to all datasets
* %% this will not run unless you delete the _appended.xlsx, and replace option wont work
iecodebook apply ///
			 using `"${mastData}/codebooks/schools3.xlsx"' /// path to codebook
			, replace generate(country) clear





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
