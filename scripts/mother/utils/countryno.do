* countryno.do
* assigns a numeric country number based on string country name and checks.


* verify that there are the right number of countries, and no missings
levelsof 	country, miss
assert 		r(r) == ${c_n} 		// should only be the number of values as the no of countries

* generate the country number 
gen 		int countryname = ""
replace 	countryname = "Peru" if country == 1
replace 	countryname = "Jordan" if country == 2
replace 	countryname = "Mozambique" if country == 3
replace 	countryname = "Rwanda" if country == 4

mdesc 		countryname		// check to make sure no missings of countryno
assert 		r(miss) == 0
