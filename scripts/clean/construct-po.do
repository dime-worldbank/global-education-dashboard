/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: construct-po.do
Function: adds new variables, include z-scores.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


use	 	"${B_po}", replace


							* | 	re-construction of BI 	| *
						/* since all secondary and tertiary variables are averages of groups of
						   raw qustions, we could average these manually. */

	if (${s1} == 1) {
		do `"${scripts_clone}/mother/utils/bi-reconstruct.do"'
	}


							* | 	imputations 		| *

					/* we won't do imputations for po, but if we did,
					 	it'd be like that of schools. */



							* | 	reconstruct bi 		| *

					/* turning s4 to 1 will check and regenerate all of
					 	the bi information, where 0 will leave the raw
						data as it and only generate BI */

if (${s4} == 1) {
	do 	 "${scripts_clone}/mother/utils/bi-reconstruct.do"
}
else {
	egen 	bi = rowmean(national_learning_goals mandates_accountability quality_bureaucracy impartial_decision_making)
}



							* | 	enumerator quality 		| *

		/* note that the coding puts missing values in 0 for generated dummy vars, not missing.
		 	missings are mostly 0, at most 3 total for all 4 countries*/


	gen enum_priv = (ENUMq3 == 1) // privacy: interview was totally private
	gen enum_know = (ENUMq4 == 3) // expert knowledge: Expert knowledge about both their own work and about the organization.
	gen enum_info = (ENUMq5 == 3) // reveal information: provides both basic and sensitive info
	gen enum_eval = (ENUMq7 == 4) // overall assessment: very well






							* | 	Day of Week		| *

					/* 	Runs a mini-script that takes the raw input and
					 	generates day of week vars, not actual date vars
						which are PII. This can be changed on the main
						script under switch s5. */


do 			"${scripts_clone}/mother/utils/survey_time.do"







							* | 	z-scores 		| *

					/* here we will use a stata package instead of manual,
					sorted out by country, on all numeric variables */
ds , has(type numeric)
local numeric

foreach v of local numeric {
	bysort countryname: scores `v'_z = mean(`v'), sc(z)
}




save "${C_po}", replace
