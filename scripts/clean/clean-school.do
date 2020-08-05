/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: clean-school.do
Function: handles missing values.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/


use	 	"${A_sch}", replace


							* | 	store values in varlist 		| *


ds
local 	varlist = r(varlist) 				// store local list of all variables
local 	except	= "idschool geocode g0 g1 g2"	// these are the list of vars we don't care if they aren't missing
local 	misvars: list varlist - except		// this list of vars are the ones we care about if they are missing





							* | 	Missing values 		| *


* drop observations that are missing on all survey values
	missings dropobs 	`misvars' ///
						, force


							* | 	Order Variables		| *


	order 				idschool geocode g1 g2 g3





save	 	"${B_sch}", replace
