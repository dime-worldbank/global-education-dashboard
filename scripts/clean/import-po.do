/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: import-po.do
Function: runs all the scripts for the cleaning portion.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


							* | 	Append using iecodebook	| *

							/* 	use iecodebook to harmonized
								variable names
								across all datasets 		*/


* create a template using iecodebook %% note, will use files with long names
iecodebook template ///
			`"${rawencrypt}/Peru/Data/public_official_dta_confidential.dta"' /// path to PER survey %
			`"${rawencrypt}/Jordan/Data/public_officials_survey_data.dta"' /// path to JOR
			`"${rawencrypt}/Mozambique/Data/public_official_dta_confidential.dta"' /// path to MOZ
			`"${rawencrypt}/Rwanda/Data/public_officials_survey_data.dta"' /// path to RWA
			using `"${mastData}/codebooks/po.xlsx"'	/// path to codebook
			, surveys(${countrynames}) ///
			gen(country)	// variable that identifies source of each obs


		/*excel editing happens manually here. */


* apply to all datasets
iecodebook append ///
			`"${rawencrypt}/Peru/Data/public_official_dta_confidential.dta"' /// path to PER survey %
			`"${rawencrypt}/Jordan/Data/public_officials_survey_data.dta"' /// path to JOR
			`"${rawencrypt}/Mozambique/Data/public_official_dta_confidential.dta"' /// path to MOZ
			`"${rawencrypt}/Rwanda/Data/public_officials_survey_data.dta"' /// path to RWA
			using `"${mastData}/codebooks/po.xlsx"'	/// path to codebook
			, clear ///
			gen(country) surveys(`"${countrynames}"') 	// identify where each





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
