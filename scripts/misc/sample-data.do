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

// use the nlsw88 system dataset 
sysuse 		nlsw88, clear 
preserve


// duplicate, rename, save 
save 		`"${reprex}/nlsw88-edit.dta"'
restore 

clear 



// bring back new dataset 
use 		`"${reprex}/nlsw88-edit.dta"', clear 



// data manipuation
// idpo country g1 g2 g3 govt_tier `var'

