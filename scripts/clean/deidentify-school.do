/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: deidentify-school.do
Function: merges to master dataset, replaces some vars with random id, remove pii.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/

use "${C_sch}", clear
loc keep 		// these variables will be kept from merge.

							* | 	merge to master 		| *

merge 1:1 	countryname school_code 	/// this will connect two datasets
			using "${sch0}" 		/// use master dataset
			, assert(match) 		/// every single obseration should match perfectly
			keep(`keep')			// keep only these variables




							* | 	drop pii variables		| *

drop 		${piisch}



save 		`"${D_sch}"' , replace
