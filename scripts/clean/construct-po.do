/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: construct-po.do
Function: adds new variables, include z-scores.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


use	 	"${B_po}", replace


							* | 	re-construction of BI 	| *
						/* since all secondary and tertiary variables are averages of groups of
						   raw qustions, we could average these manually. */

	if (`s1' == 1) {
		do `"${scripts_clone}/mother/utils/bi-reconstruct.do"'
	}


							* | 	imputations 		| *

					/* we won't do imputations for po, but if we did,
					 	it'd be like that of schools. */



							* | 	z-scores 		| *

					/* here we will use a stata package instead of manual,
					sorted out by country, on all numeric variables */
ds , has(type numeric)
local numeric

foreach v of local numeric {
	bysort countryname: scores `v'_z = mean(`v'), sc(z)
}




save "${C_po}", replace
