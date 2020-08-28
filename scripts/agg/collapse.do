/*--------------- ---------- --------- -------- ------- ------ ----- ---- --- --
Name: collapse.do
Function: collapses the public officials dataset by country-region and country-district.
-- --- ---- ----- ------ ------- -------- -------- --------- -------------------*/



use `"${D_po}"', clear

* determine muneric vars
ds	,	 		has(type numeric)
loc numbers 	= r(varlist)

* take away the the geographic vars
loc g1 		g1 g2
loc g2 		g2
loc district 	: list numbers - g1 // for district we want to have g1
loc region 		: list numbers - g1 // for region we don't want either g2 or g1
* these are the same, yes, it's right, trust me




							* | whole sample | *

					/* for now, just use all tiers of gov officials */


	* By Region
		preserve

			sort		countryname g1
			collapse 	(mean) `region', by(countryname g1)

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

			drop 		idpo  			// we don't need these as they will be meaningless as averages.
			drop if 	g2 == . 		// we don't want to compress all missing values of g2


			do 			"${scripts_clone}/mother/utils/labpreserve.do"
			la data 	"All tiers of public official indicators averaged at the region"
			save 		"${publicofficial}/Dataset/col_po_g1_alltier.dta", replace
					restore





* By District
	preserve

		sort		countryname g1 g2
		collapse 	(mean) `district', by(countryname g1 g2)

		drop 		idpo			// this doesn't make sense when averaged
		drop if 	g2 == . 		// we don't want to compress all missing values of g2

		do 			"${scripts_clone}/mother/utils/labpreserve.do"

		la data 	"All tiers of public official indicators averaged at the district"
		save 		"${publicofficial}/Dataset/col_po_g2_alltier.dta", replace

	restore

* Now restrict the sample only certain officials

		// district-level only
			preserve

				keep if 	govt_tier == 3 		// where 3 == district officials

				sort		countryname g1 g2
				collapse 	(mean) `district', by(countryname g1 g2)

				drop 		idpo			// this doesn't make sense when averaged
				drop if 	g2 == . 		// we don't want to compress all missing values of g2

				do 			"${scripts_clone}/mother/utils/labpreserve.do"

				la data 	"District-office of public official indicators averaged at the district"
				save 		"${publicofficial}/Dataset/col_po_g2_tier3.dta", replace

			restore
