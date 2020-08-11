/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: deidentify-po.do
Function: merges to master dataset, replaces some vars with random id, remove pii.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/

use "${C_po}", clear
loc keep 	master match 			// these variables categories will be kept from merge.
if (${s3} == 1) {
loc keep 	match
}
/*note: there's a discrepency in the number of total observations in teh Peru public
officials dataset. in the .dta version there's 203 obs, whereas in Brian's Rdata
there are only 181. This leaves 22 obs unmatched from Peru, setting $s3 to 1 in
the main script will keep only the 181, while setting $s3 to 0 will keep the 203.*/

							* | 	merge to master 		| *

merge 1:1 	countryname interview__id 	/// this will connect two datasets
			using "${po0}" 		/// use master dataset
			, assert(master match) 		/// every single obseration should match perfectly
			keep(`keep')			// keep only these variables




							* | 	drop pii variables		| *

drop 		${piipo} _merge



save 		`"${D_po}"' , replace

pause on
pause
