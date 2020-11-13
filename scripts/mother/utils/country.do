* countryname.do
* assigns a numeric country number based on string country name and checks.


* verify that there are the right number of countries, and no missings
levelsof 	countryname, miss
assert 		r(r) == ${c_n} 		// should only be the number of values as the no of countries

* generate the country number 
gen 		country = .
replace 	country = 1 	if countryname == "Peru"
replace 	country = 2 	if countryname == "Jordan"
replace 	country = 4 	if countryname == "Mozambique"
replace 	country = 3 	if countryname == "Rwanda"

mdesc 		country		// check to make sure no missings of countryname
assert 		r(miss) == 0
