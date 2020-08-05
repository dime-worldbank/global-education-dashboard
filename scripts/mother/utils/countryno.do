* countryno.do
* assigns a numeric country number based on string country name and checks.


gen 		countryno = .
replace 	countryno = 1 if country == "Peru"
replace 	countryno = 2 if country == "Jordan"
replace 	countryno = 3 if country == "Mozambique"
replace 	countryno = 4 if country == "Rwanda"

mdesc 		countryno		// check to make sure no missings of countryno
assert 		r(miss) == 0
