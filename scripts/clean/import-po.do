/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: import-po.do
Function: runs all the scripts for the cleaning portion.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


							* | 	Append using iecodebook	| *

							/* 	use iecodebook to harmonized
								variable names
								across all datasets 		*/


* create a template using iecodebook
if (1) {
iecodebook template ///
			 "A:/Countries/Peru/Data/PER_po_survey_data_short.dta" /// path to Peru
			 "A:/Countries/Jordan/Data/JOR_po_survey_data_short.dta" /// Path to jordan
			 "A:/Countries/Mozambique/Data/MOZ_po_survey_data_short.dta" /// path to moz
			 "A:/Countries/Rwanda/Data/RWA_po_survey_data_short.dta" /// path to rwanda
			 using `"${mastData}/codebooks/po.xlsx"' /// path to codebook
			, replace surveys($countrynames) generate(country)
}
		/*excel editing happens manually here. */

if (0) {
* apply to all datasets
iecodebook apply ///
			 "A:/Countries/Peru/Data/PER_po_survey_data_short.dta" /// path to Peru
			 "A:/Countries/Jordan/Data/JOR_po_survey_data_short.dta" /// Path to jordan
			 "A:/Countries/Mozambique/Data/MOZ_po_survey_data_short.dta" /// path to moz
			 "A:/Countries/Rwanda/Data/RWA_po_survey_data_short.dta" /// path to rwanda
			 using `"${mastData}/codebooks/po.xlsx"' /// path to codebook
			, replace surveys($countrynames) generate(country)

}



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
