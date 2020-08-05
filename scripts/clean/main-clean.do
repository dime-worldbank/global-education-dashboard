/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: main-clean.do
Function: runs all the scripts for the cleaning portion.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/

* global setup for clean
do `"${scripts_clone}/clean/clean-global-setup.do"'

* 1. Import
	* In: Raw Stata files.
	* Out: all-country appended Bureaucrat and School dataset with harmonized variable names: A_*

do `"${scripts_clone}/clean/import-school.do"'
do `"${scripts_clone}/clean/import-po.do"'


* 2. Clean
	* In: appended datasets: A_*
	* Out: cleaned, mostly handling missing values. B_*

do `"${scripts_clone}/clean/clean-school.do"'
do `"${scripts_clone}/clean/clean-po.do"'

* 3. Construct
	* In: cleaned datasets: B_*
	* Out: added constructed variables: Bureaucracy Indicators, others . C_*

do `"${scripts_clone}/clean/construct-school.do"'
do `"${scripts_clone}/clean/construct-po.do"'

* 4. Deidentify
	* In: constructed datasets: C_*
	* Out: removed pii, merge with mother dataset to pull values . D_*

do `"${scripts_clone}/clean/deiden-school.do"'
do `"${scripts_clone}/clean/deiden-po.do"'
