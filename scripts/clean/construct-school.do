/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: construct-school.do
Function: adds new variables, include z-scores.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


use	 	"${B_sch}", replace



							* | 	imputations 		| *

					/* we will only impute the list of ~11 key outcome Variables
						we will replace the main variable and leave original as
						another variable that is "unimputed". We will also replace
						mising values with the country average. */

	foreach v of global schoutcome {

		clonevar 	`v'_raw = `v'					// clone the var with missing values, label raw
		label var	`v'_raw "Unimputed `v'"			// label the raw variable

		// generate a by-country mean of each var
		egen m_`v' = mean(`v') by country

		// replace the real var's value if that obs is missings
		replace `v' = m`v' 	if `v' == .

		// drop the egened var
		drop m_`v' 
}



							* | 	z-scores 		| *

					/* here we will use a stata package instead of manual,
					sorted out by country */

foreach v of global schoutcome {
	bysort countryname: scores `v'_z = mean(`v'), sc(z)
}




save "${C_sch}", replace
