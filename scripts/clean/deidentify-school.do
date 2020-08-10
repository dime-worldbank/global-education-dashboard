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




							* | 	drop pii variables		| *

drop 		${piisch} _merge



save 		`"${D_sch}"' , replace
