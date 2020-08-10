/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: deidentify-po.do
Function: merges to master dataset, replaces some vars with random id, remove pii.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/

use "${C_po}", clear
loc keep 		// these variables will be kept from merge.

							* | 	merge to master 		| *

merge 1:1 	countryname school_code 	/// this will connect two datasets
			using "${po0}" 		/// use master dataset
			, assert(match) 		/// every single obseration should match perfectly
			keep(`keep')			// keep only these variables




							* | 	drop pii variables		| *

drop 		${piipo} _merge



save 		`"${D_po}"' , replace

pause on
pause
