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
		sort 	country
		by 		country: 	egen m_`v' = mean(`v')

		// replace the real var's value if that obs is missings
		replace `v' = m_`v' 	if `v' == .

		// drop the egened var
		drop m_`v'
}




							* | 	Day of Week		| *

					/* 	Runs a mini-script that takes the raw input and
					 	generates day of week vars, not actual date vars
						which are PII. This can be changed on the main
						script under switch s5. */


do 			"${scripts_clone}/mother/utils/survey_time.do"






						* | 	schools per district, region		| *

					/* 	this section generates variables of the number of
						schools per region and district */

* number of schools per district
egen nsch_dist = count(idschool), by(country g2)


* number of schools per region
egen nsch_region = count(idschool), by(country g1)




							* | 	z-scores 		| *

					/* here we will use a stata package instead of manual,
					sorted out by country */

foreach v of global schoutcome {
	bysort countryname: scores `v'_z = mean(`v'), sc(z)
}




save "${C_sch}", replace
