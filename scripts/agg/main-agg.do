/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: main-agg.do
Function: runs all the scripts for the aggregation portion.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/

* global setup for agg
do `"${scripts_clone}/agg/agg-global-setup.do"'

* 1. Collapse
	* In: Deidentified _D
	* Out: collapsed on country-admin region, various combinations.

do `"${scripts_clone}/agg/collapse.do"' // note this only does PO


* 2. Merge
	* In: collapsed datasets
	* Out: Global datasets

do `"${scripts_clone}/agg/merge-region.do"'		// merges all combos at region level
do `"${scripts_clone}/agg/merge-district.do"'	// merges all combos at district level.

clear
