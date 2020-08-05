/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: construct-school.do
Function: adds new variables, include z-scores.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


use	 	"${B_sch}", replace

	local		newimpvars ""		// blank, to be filled in do-file
	local		nozscoresch =	"idschool geocode g0 g1 g2 g3"


							* | 	imputations 		| *

					/* we will only impute the list of ~11 key outcome Variables
						we will replace the main variable and leave original as
						another variable that is "unimputed". We will also replace
						mising values with the country average. */

forvalues i = 1/$c_n	{							// iterate over all countries
	foreach v of global schoutcome {
		clonevar 	`v'_raw = `v'					// clone the var with missing values, label raw

		qui sum 	`v'		if countryno == `i'		// save sum for each country
		replace 	`v' 	= r(mean) 	///
							if `v' == . 			// replace only if the variable is missing
		label var	`v'_raw "Unimputed `v'"			// label the raw variable
	}
}



							* | 	z-scores 		| *

					/* here we will use a stata package instead of manual,
					sorted out by country */

foreach v of global schoutcome {
	bysort countryno: scores `v'_z = mean(`v'), sc(z)
}




save "${C_sch}", replace 
