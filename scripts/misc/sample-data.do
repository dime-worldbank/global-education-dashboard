*sample-data.do

/*This script makes changes to a system-standard dataset to mimic the data structure needed
to run montecarlo-sample.do. The main data structure is microdata (individual level) 
and stratified based on 1) country 2) level of government 3) administrative region. The main 
outcome variable is numeric.  In theory
any data with 3 factor level variables and one continous outcome variable could be run with this
script. 

We're going to edit the nlsw88 dataset to produce the following:


	id | countryname (factor) | govt_tier (factor) | admin regions g1 g2 and g3 (factor vars) | outcome  (numeric)


*/




gl 			reprex 	"C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/mc-reprex" // <- insert top path here.

clear 
set obs 	1000
set seed 	47




** data manipuation 



// idpo 
gen 		idpo = _n


// countryname (string)
gen 		country = runiformint(1,2)
gen 		countryname = ""
 
replace 	countryname = "Atlantis" 	if country == 1
replace 	countryname = "Gaia"		if country == 2 


// govt_tier 
bysort 		country:  gen govt_tier 	= runiformint(1,3)



// g1 
gen  		g1 = runiformint(1,10)
replace 	g1 = 10 + g1 	if countryname == "Gaia"



// g2 
bysort 		g1:			gen g2 			= runiformint(1,12) 	



// g3 
bysort g1 g2: gen g3 = runiformint(1,3)



// outcome variables 
set seed	4747
bysort 		country: 	gen outcome1 = runiformint(1,10)

set seed 	1234 
bysort		country:	gen outcome2 = runiformint(1,10)	



save 		`"${reprex}/reprex.dta"', replace 


