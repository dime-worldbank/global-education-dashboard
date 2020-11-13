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
			drop if 	g1 == . 		// we don't want to compress all missing values of g2


			do 			"${scripts_clone}/mother/utils/labpreserve.do"
			la data 	"All tiers of public official indicators averaged at the region"
			save 		"${publicofficial}/Dataset/col_po_g1_alltier.dta", replace
					restore
 * should also restrict the same to only region level officials as well.





							* | By District | *

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








							* | By Decision-Making Level | *

					/* all countries except for rwa = district; rwa = region */
					/* keep only officials that match with the decision-making level */

* District-level Counties: PER, MOZ, JOR


		// district-level only
			preserve

				keep if  	countryname 	== "Peru" /// 	keep only countries agg'd at district level
							| countryname 	== "Jordan" ///
							| countryname	== "Mozambique"

				keep if 	govt_tier == 3 		// where 3 == district officials

				sort		countryname g1 g2
				collapse 	(mean) `district', by(countryname g1 g2)

				drop 		idpo			// this doesn't make sense when averaged
				drop if 	g2 == . 		// we don't want to compress all missing values of g2

				do 			"${scripts_clone}/mother/utils/labpreserve.do" // relabel


				// create tempfile; append later
				tempfile 	dmdistrict
				save 		`dmdistrict'

			restore




* Region-level countries: RWA


		// region-level only
			preserve

				keep if  	countryname 	== "Rwanda" // 	keep only countries agg'd at district level

				keep if 	govt_tier == 2 		// where 3 == district officials

				sort		countryname g1
				collapse 	(mean) `region', by(countryname g1)

				drop 		idpo			// this doesn't make sense when averaged
				drop if 	g1 == . 		// we don't want to compress all missing values of g2

				do 			"${scripts_clone}/mother/utils/labpreserve.do" // relabel


				// create tempfile; append later
				tempfile 	dmregion
				save 		`dmregion'

			restore




* Append region and district tempfiles to create decision-making dataset

clear 						// clear D_po

use 		 `dmdistrict' 	// use the district dataset
append using `dmregion' 	// append with the region-level dataset


 // save
la data 	"Decision-Making level dataset with only officials kept at decision-making level"
save 		"${publicofficial}/Dataset/col_po_dm.dta", replace

clear
