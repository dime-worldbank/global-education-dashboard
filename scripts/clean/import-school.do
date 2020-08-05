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
			/// path to PER survey %
			/// path to JOR
			/// path to MOZ
			/// path to RWA
			using `"${mastData}/codebooks/schools.xlsx"'	/// path to codebook
			, surveys(`"${countries}"') ///
			gen(country)	// variable that identifies source of each obs


		/*excel editing happens manually here. */


* apply to all datasets
iecodebook append ///
			/// path to PER survey %
			/// path to JOR
			/// path to MOZ
			/// path to RWA
			using `"${mastData}/codebooks/schools.xlsx"'	/// path to codebook
			, clear ///
			generate(country) 	/// identify where each





									* | Add country number var | *

* verify that there are the right number of countries, and no missings
levelsof 	country, miss
assert 		r(r) == ${c_n} 		// should only be the number of values as the no of countries

* convert to categorical variable with labels (move this into script?)
gen 		countryno = .
replace 	countryno = 1 if country == "Peru"
replace 	countryno = 2 if country == "Jordan"
replace 	countryno = 3 if country == "Mozambique"
replace 	countryno = 4 if country == "Rwanda"

mdesc 		countryno		// check to make sure no missings of countryno
assert 		r(miss) == 0







									* | ID Check | *
						/* countryno and school code should uniquely identify
						each observation. */


capture  	isid countryno school_code

	if _rc {
		duplicates 	drop 	school_code student_knowledge lat lon, force	// drop obs that are same on these vars
							/*it is very unlikely to have two schools with the same id and test score that are dif */
		isid 				countryno school_code
	}

	save "${A_sch}", replace
