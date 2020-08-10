/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: clean-po.do
Function: handles missing values.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


use	 	"${A_po}", replace


							* | 	store values in varlist 		| *


ds
local 	varlist = r(varlist) 				// store local list of all variables
local 	except	= ""	// these are the list of vars we don't care if they aren't missing
local 	misvars: list varlist - except		// this list of vars are the ones we care about if they are missing





							* | 	Missing values 		| *


* drop observations that are missing on all survey values
	missings dropobs 	`misvars' ///
						, force




save	 	"${B_po}", replace
