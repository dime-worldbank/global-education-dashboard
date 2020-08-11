/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: deidentify-school.do
Function: merges to master dataset, replaces some vars with random id, remove pii.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/

use "${C_sch}", clear

							* | 	merge to master 		| *

merge 1:1 	countryname school_code 	/// this will connect two datasets
			using "${sch0}" 		/// use master dataset
			, assert(match master) 		/// every single obseration should match perfectly
			keep(match)			// keep only these variables

			/* note that the variables that don't match are ones that are in the masterdataset,
			 	and these unmatched variables do not have any shcool info, so we can keep only the matched ones
				*/






							* | 	convert school size into categorical		| *



la def 	enrolled 	1	"25 or fewer" ///
					2 	"25-50" ///
					3 	"50-75" ///
					4 	"75-100" ///
					5 	"100-150" ///
					6 	"150-300" ///
					7	"300-500" ///
					8	"500+"

gen 	enrolled		= .
la values enrolled enrolled 			// assign value label
la var	enrolled 		"Total Student Enrollement" // label variable

replace enrolled 		= 1 	if 							total_enrolled < 25
replace enrolled 		= 2 	if total_enrolled >= 25 & 	total_enrolled < 50
replace enrolled 		= 3 	if total_enrolled >= 50 & 	total_enrolled < 75
replace enrolled 		= 4 	if total_enrolled >= 75 & 	total_enrolled < 100
replace enrolled 		= 5 	if total_enrolled >= 100 & 	total_enrolled < 150
replace enrolled 		= 6 	if total_enrolled >= 150 & 	total_enrolled < 300
replace enrolled 		= 7 	if total_enrolled >= 300 & 	total_enrolled < 500
replace enrolled 		= 8 	if total_enrolled >= 500






							* | 	drop pii variables		| *

drop 		${piisch} _merge

order 		${sorder}

save 		`"${D_sch}"' , replace
