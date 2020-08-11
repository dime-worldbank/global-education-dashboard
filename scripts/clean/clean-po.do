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

	if (${s3} == 1) {
	gen 	droptag1 = 0
	replace droptag1 = 1 	if 	targeting == . & monitoring == . & incentives == . ///
							& coherence == . & transparency == . & accountability == .
	}
	/* there are ~ 27 obs that have basically no po data, only demogrpahic info,
	 	and we can identify them if they are missing on these two variables.
		if ${s3}==1, this indicates that we will evntually drop them from the
		dataset,  and exclude them in the bi contstruct check if tag==1*/




save	 	"${B_po}", replace
