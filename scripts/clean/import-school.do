/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: import-school.do
Function: runs all the scripts for the cleaning portion.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


							* | 	Append using iecodebook	| *

							/* 	use iecodebook to harmonized
								variable names
								across all datasets 		*/


* create a template using iecodebook
iecodebook template ///
			`"${rawencrypt}/Peru/Data/school_indicator_dta_confidential.dta"' /// path to PER survey
			`"${rawencrypt}/Jordan/Data/final_indicator_school_data.dta"' /// path to JOR
			`"${rawencrypt}/Mozambique/Data/school_inicators_data.dta"' /// path to MOZ
			`"${rawencrypt}/Rwanda/Data/final_indicator_school_data.dta"' /// path to RWA
			using `"${mastData}/codebooks/schools.xlsx"'	/// path to codebook
			, surveys(`"${countries}"') ///
			gen(country)	// variable that identifies source of each obs


		/*excel editing happens manually here. */


* apply to all datasets
iecodebook append ///
			`"${rawencrypt}/Peru/Data/school_indicator_dta_confidential.dta"' /// path to PER survey
			`"${rawencrypt}/Jordan/Data/final_indicator_school_data.dta"' /// path to JOR
			`"${rawencrypt}/Mozambique/Data/school_inicators_data.dta"' /// path to MOZ
			`"${rawencrypt}/Rwanda/Data/final_indicator_school_data.dta"' /// path to RWA
			using `"${mastData}/codebooks/schools.xlsx"'	/// path to codebook
			, clear ///
			gen(country) 	// identify where each





									* | Add country number var | *

* convert to categorical variable with labels (move this into script?)
do `"${scripts_clone}/mother/utils/countryno.do"'





									* | ID Check | *

						/* countryno and school code should uniquely identify
						each observation. */


capture  	isid countryno school_code

	if _rc {
		duplicates 	drop 	countryno school_code student_knowledge lat lon, force	// drop obs that are same on these vars
							/*it is very unlikely to have two schools with the same id and test score that are dif */
		isid 				countryno school_code
	}

	save "${A_sch}", replace