/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: main-misc.do
Function: file for running miscellaneous data processing.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/

* settings: set to 1 to compile the md file
loc p1 	0	// environmental controls



************* Globals ***************************

************* Run Scripts ***************************

* 1. Run Survey Match check:
*		add variables to main school dataset that tell us what obs will be dropped for various datasets

do 	"${scripts_clone}/misc/match-check-schools.do"
