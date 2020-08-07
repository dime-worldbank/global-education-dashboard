/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: collapse.do
Function: collapses the public officials dataset by country-region and country-district.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/



use `"${D_po}"', clear

* determine muneric vars
ds	,	 		has(type numeric)
loc numeric 	= r(varlist)



							* | whole sample | *

					/* for now, just use all tiers of gov officials */


	* By Region
		preserve

			sort		countryno g1
			collapse 	(mean) `numeric', by(countryno g1)

				if (${s2} == 1) {
				*>> Now Create Averages for BI by region
					* Generate variable with the 50th, 60th, 70th, 80th, 90th percentile
					foreach bi of global bi_secondary {
						forvalues 		p = 50(10)90 	{

							egen 		p`p'`bi' = pctile(`bi'), p(`p')	// gen the nth-tile for each secondary indicators
							gen 		top`p'`bi'  = (`bi' >= p`p'`bi') if !missing(`bi')	// generate a dummy if each g1 averate is greater than or equal to nth-tile
							drop		p`p'`bi'	// drop the variable used to create the nth-tile value
						}
					}
				}

			drop 		idpo g2 g3 // we don't need these as they will be meaningless as averages.
			do 			"${scripts_clone}/mother/utils/labpreserve.do"
			save 		"${publicofficial}/Dataset/col_po_g1_alltier.dta", replace
					restore

				*2A. By District
					preserve

						sort		countryno g1 g2
						collapse 	(mean) `numeric', by(g2)
						drop 		idpo g3
						*do 		${labscript}
						save 		"${publicofficial}/Dataset/col_po_g2_alltier.dta", replace

					restore

		restore



* By District
	preserve

		sort		countryno g1 g2
		collapse 	(mean) `numeric', by(countryno g1 g2)
		drop 		idpo g3
		do 			"${scripts_clone}/mother/utils/labpreserve.do"
		save 		"${publicofficial}/Dataset/col_po_g2_alltier.dta", replace

	restore

* Now restrict the sample only certain officials

		// district-level only
			preserve

				keep if 	govt_tier == 3 		// where 3 == district officials

				sort		countryno g1 g2
				collapse 	(mean) `numeric', by(countryno g1 g2)
				drop 		idpo g3
				do 			"${scripts_clone}/mother/utils/labpreserve.do"
				save 		"${publicofficial}/Dataset/col_po_g2_tier3.dta", replace

			restore