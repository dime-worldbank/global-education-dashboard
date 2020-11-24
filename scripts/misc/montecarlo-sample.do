/*_________________________________________________________________________________________________
Name: montecarlo.do
Description: runs full monte carlo simulations and creates output graphs
Date modified: June, 2020
Author: Tom Mosher
__________________________________________________________________________________________________*/



	/*
	The main question is how sensitive is our data to the number of people
	interviewed in each department. If we randomly removed 1, 2, 3, or n people
	from each department, how much would our main outcome variable change?

	I have created a program to address this, which is really four programs nested into one
	that perform four steps necessary.

	S or Sequoia: prepares the merged public official dataset by trimming away
							unnecessary govt_tier and administrative levels

	A or Acadia: creates one full 'column' by keeping n obs (starting with 1 obs) and recalculating
					outcome mean after each iteration of seed. the number of observations to
					keep/drop is determiend by a random number generator

	B or Biscayne: repeats program A for y number of columns/pulls. in each new column, the appropriate seed
	 				is maintained so that each "row" has data enerated from the same seed number.
					Outputs: full matrix (saved) and single row of
					averaged columns. also generated variables that include the std deviation
					of every keep/pull number.

	C or Canyonlands: repeats this process the above process for all countries and produces an
						appended matrix where one row represents the averaged indicators for
						each country.

	D or Denali: 	takes the output files from canyonlands and reshapes them to a suitable form for graphs

	E or Everglades: graphs the adjusted output files from Denali

	G or Glacier: 	repeats Canyonlands, Denali, and Everglades for all outcome variables of interest at all
					government tiers


	*/





**** Globals

// public official dataset 
gl 	GLOBE_po 			`"${reprex}/reprex.dta"'  // same as the de-identified dataset


// top path for all folders
gl 	GLOBE_pomcdta		"${reprex}/out"		// set to outcome folder

gl lvls 				1 2 3 4 5 6 7 8 9 

// countrynames 
gl 	pos_1 				"Atlantis"
gl 	pos_2				"Gaia"


// scatterplot path 
gl 	scatters			`"${GLOBE_pomcdta}/scatters"'


	clear




/*_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
	 _-_-_-_-_-_--_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
	 	Monte Carlo Simulations  _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	 _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	*/




***
	**
		* Program Sequoia: A setup program that is only run once.
			/* The program prepares a dataset to be used by subsequent programs. It copies the
				global public official dataset, keeps the appropriate governmnet tier and
				administrative levels, and generates a constant variable, called m0 representing the average
				bi for each country.
			 */


		**
			* A0.  Opening
			cap program 	drop sequoia
			program 		sequoia, rclass
			version 		15.1


			* A1. Define Syntax
			syntax, 		[gov(integer 1)		/// govt_tier, default MINEDU
							l(	integer 1)		/// administrative level, default region(==1)
							cty(	numlist ascending integer)] /// country, default is 1 == Peru
							var(	namelist)	// must specify a numeric variable


	quietly {
			// 0. make `main': Load global PO dataset, create initial stubs

			use 		"${GLOBE_po}", clear		// will globals work?
			preserve


			// 1. keep only appropriate gov level and country

			keep if		country == `cty'

			keep if 	govt_tier == `gov' 		/// 1==minedu
						& g`l' != .

			**(temporary changes-- perhaps outdated by cleaning this country's repo?)
			*replace 	g1 = 102 	if country == 2 & govt_tier == 1

			levelsof 	g`l', clean local(lvls)
			loc 	lvls 	`lvls'					// store all the levels in a global for other programs
			loc nolvls : list sizeof lvls 		// store no of levels in local

			keep 		idpo country g1 g2 g3 govt_tier `var'




			// 2. store average BI for MinEDU, by country and admin level, begin loop

			sort 		country g`l'

			by country g`l': egen m0 		= mean(`var')

			save 		"${GLOBE_pomcdta}/`var'/main-g`l'-gov`gov'-`cty'.dta", replace 	// replace with preserve



			// 3. collapse, create m0

			sort 		idpo country g1 g2 g3 govt_tier `var' m0
			collapse 	(count) count=idpo 		///		create count of obs by specified id called count
						(mean) govt_tier `var' m0, ///		generate the mean of these variables
								by(country g`l')

			*---> store all m0 values in globals
			foreach lvl of local lvls {
				sum 		m0 	if g`l' == `lvl'
				loc m0_g`l'_`lvl' 		= r(mean)
			}


			save 		`"${GLOBE_pomcdta}/`var'/m0_g`l'_gov`gov'_${pos_`cty'}.dta"', replace 	// replace with preserve
			restore
		}
			/* end quietly */

		end














***
	**
		* Program A: simulates bisim`n'



	**
		* A0.  Opening

		cap program 	drop acadia
		program 		acadia, rclass
		version 		15.1


		* A1. Define Syntax

		syntax, 		[n(	integer	30)		/// no of ppl pulled, deault == 1 (note: cumulative)
						cty(numlist ascending integer)		/// NOT USED country, default is peru
						gov(integer 1)		/// NOT USED govt_tier, default MINEDU
						l(	integer 1)		/// administrative level, default region(==1)
						seed(integer 123)	/// seed, constant not used here but carried from prog B
						reps(integer 100)]	/// NOT USED no of reps,	carried over from prog B
						var( namelist) // requires a varlist whose variable values are numeric

		* A2. Define postfile details

		tempname 	simacadia
		postfile 	`simacadia' 		///
					seed g`l' bisim`n' nkeep	str500(droplist)	///		stats to be calculated, name of variables
					using "${GLOBE_pomcdta}/`var'/${pos_`cty'}/acadia_cty`cty'_g`l'_gov`gov'_n`n'.dta", replace ///	file to be saved as.


					/* note that the raw file this creates will be long form, where row _n
					 	is equivalent to the number of people that remain. at the end of the
						program we will reshape to wide form and label each variable suffix
						with the `n' that represents the bi average with `n' ppl remaining. */




		/*Begin loop */
		use 			`"${GLOBE_pomcdta}/`var'/main-g`l'-gov`gov'-`cty'.dta"', clear 	// use country specific m0

		set seed 		`seed'	// start the base seed as defined in syntax


		* A?. Preserve, Loop through all the iterations of seed with same n pull
		qui forvalues v = 1/`reps' {

			// preserve
			preserve

			// change the seed to [base seed ] + 1
			loc 		newseed = `v' + `seed'		// define value of new seed
			set seed 	`newseed'					// set seed to this value


		* A3. randomly sort by id, within organization/district

			// drop, generate runiform by admin level
			cap drop 	r

			bysort 		g`l':	///
				gen 	r = runiform()

			sort 		g`l' r



		* A4. remove bottom `n' variables

			// generate drop var, default is 1, meaning will drop it
			gen willdrop = 1


			// tag which obs will be kept by group
			bysort 		g`l':	///
				replace willdrop = 0 	///
				if _n <= `n'		// same as saying: keep if _n <= `n'

			// store which variables will be dropped in a local
			levelsof idpo 		/// store all the numeric ids in concatenated varlist in local droplist
				if willdrop == 1 ///
				, local(droplist) clean


			// Then drop, this drop is repeated up to `n'
			bysort 		g`l':	///
				keep 	if _n <= `n' 			// start 'backwards', keep only 1 obs per group then ascend
			* same as 	drop if willdrop == 1
			gen 		n = `n'					// constant, indicates the current n kept

		// A5. recalculate outcome variable

			collapse 	(mean) `var' m0 n			/// where mean of m0 reamins constant, `var' mean altered by drop
						, by(g`l')				// should be 1 in most cases for minedu

		// A6. return mean, seed and iteration %% maybe store the levels here?
		
				// store levels of g`l'
			levelsof	g`l', clean local(lvls)
			
			foreach lvl of local lvls {

			sum 		`var' 	if g`l' == `lvl'	// summarize the new `var' after drop `n'
			post 		`simacadia' 			///		post the results from sum into the summary dataset
						(`newseed') (`lvl') (r(mean)) (`n') ("`droplist'")	// post constant = `n' and mean of `var', v is the n pulled that time
			}
			/* close lvl loop */

			restore

		}
		/*end forvalues loop */


			postclose 	`simacadia'					// closes the simulation file

		end













***
	**
		* Program B: repeats program A to generate multiple "columns": outputs full matrix and averaged
						* "row" of all matrix columns



		* B0. Opening

		cap program drop biscayne
		program 	biscayne, rclass

		version 	15.1


		* B1. Define Syntax

		syntax, [n(integer	1)	/// max no of ppl pulled, deault == 1 (note: cumulative)
				cty(numlist ascending integer)	/// country, default is peru
				gov(integer 1)	/// govt_tier, default MINEDU
				l(integer 	1)	/// administrative level, default region(==1)
				reps(integer 100)	/// repetitions, default is 100
				seed(integer 123)]	/// set random seed
				var( namelist) // requires a varlist whose values are numeric



		* B3. repeat acadia for cumulative N times, each different n.
		quietly {

		loc counter = 1

		forvalues v = 1/`n' {


			// run acadia
				acadia, n(`v')			/// max no of ppl pulled, deault == 1 (note: cumulative)
						cty(`cty')		/// country, default is peru
						gov(`gov')		/// govt_tier, default MINEDU
						l(	`l')		/// administrative level, default region(==1)
						reps(`reps')	/// no of rows/repetitions
						seed(`seed')	/// add 1 to the seed each new row/rep
						var(`var')		// enter the main outcome variable

			// take long output,


			if `counter' == 1	{
				use 	"${GLOBE_pomcdta}/`var'/${pos_`cty'}/acadia_cty`cty'_g`l'_gov`gov'_n`v'.dta", clear	// where `v' is first `n'
				tempfile simmat
				save 	`simmat', replace
			}
			else { 		// otherwise save add it to the cumulative matrix (else won't work?) /if `counter' >= 2
				use 			`simmat', replace
				merge 			1:1 seed g`l'			///
								using 	"${GLOBE_pomcdta}/`var'/${pos_`cty'}/acadia_cty`cty'_g`l'_gov`gov'_n`v'.dta" ///
								, keepus(bisim`v' nkeep ) /// don't merge droplist as it ovrittes each merge (cuz cols)
								assert(3) nogen			// asserts that results must merge.
				save 			`simmat', replace
			}

			// add 1 to counter
			loc counter = `counter' + 1

		}
		/* end forvals loop */


		* B4. Variable creation/maniuplation

		// merge with dataset that has actual `var' mean %% assert(3) messes up.
		merge 	m:1 	g`l' ///
						using `"${GLOBE_pomcdta}/`var'/m0_g`l'_gov`gov'_${pos_`cty'}.dta"' ///
						, keepus(count m0)		/// only keep the original mean
						assert(3)				// everything must match perfectly

		// max no of pulls
		ds 			bisim*				// store all pull vars
		loc vars 	= r(varlist)		// store the list in local
		loc pulls 	: list sizeof vars 	// store no of words == total pulls
		gen pulls 	= `pulls'			// where `pulls' is the cumulative number of poeple pulled.

		cap drop 	droplist			// this becomes uninformative with column merge

		// generate a difference variable, mean sd of that difference var
		forvalues v = 1/`pulls' {
			gen 	d_bisim`v'		= abs(m0 - bisim`v')	// generate an absolute value difference var
			gen 	dd_bisim`v'		= m0 - bisim`v'			// generate a real difference var
			bysort g`l': ///
					egen 	mean_error`v'	= mean(d_bisim`v')		// this is the mean dif btw sim and real `var'
			bysort g`l': ///
					egen 	sd_error`v' 	= sd(d_bisim`v')		// this is the sd of the dif btw sim and real `var'
			bysort g`l': ///
					gen 	m1sd`v'			= mean_error`v' + sd_error`v' // this is the upper estimate of error, 1 std dev
			bysort g`l': ///
					gen 	m2sd`v'			= mean_error`v' + 2*(sd_error`v') // this is the upper estimate of error, 2 std dev
			gen 	meantop_error`v'= mean_error`v' + sd_error`v' 	// upper bounds est of mean error
			gen 	meanlow_error`v'= mean_error`v' - sd_error`v' 	// lower bounds est of mean error
			bysort g`l': ///
					egen 	p25_error`v' 	= pctile(d_bisim`v') , p(25) // 25th percentile of difference
			bysort g`l': ///
					egen 	p75_error`v'	= pctile(d_bisim`v') , p(75) // 75th percentile of difference

			}

			/*Note, the problem here is that you can get a negative value for meanlow_error if the mean error
				is small and the std deviation is large. Should I square instead of taking abs value? %%*/

			order 	seed m0 count nkeep ///
					mean_error* sd_error* bisim* meantop_* meanlow_* p25_* p75_* d_* dd_* m1sd* m2sd*



		// save matrix
		save 		`"${GLOBE_pomcdta}/`var'/${pos_`cty'}/mcmatrix_g`l'_gov`gov'_${pos_`cty'}.dta"', replace

		// collapse keeping only constants by region.
		collapse (mean) m0 count mean_error* sd_error* meantop_* meanlow_*  p25_* p75_* m1sd* m2sd* ///
					, by(g`l')
		save 		`"${GLOBE_pomcdta}/`var'/mcrow_g`l'_gov`gov'_${pos_`cty'}.dta"', replace



		// collapse keeping only constants (egen'd vars) // why do we need this??
		collapse (mean) m0 mean_error* sd_error* meantop_* meanlow_*  p25_* p75_* m1sd* m2sd*
		save 		`"${GLOBE_pomcdta}/`var'/mcrow_gov`gov'_${pos_`cty'}.dta"', replace


		}
		/* end quietly */


	end

















***
	**
		* Program C: (canyonlands) repeats program S, A, and B foreach country

			* C0.  Opening
			cap program 	drop canyonlands
			program 		canyonlands, rclass
			version 		15.1

			* C1. Define Syntax
			syntax, 		[n(	integer	60)		/// max no of ppl pulled, deault == 30 (note: cumulative)
							cty(numlist ascending integer)	/// countries allowed in number form
							gov(integer 1)		/// govt_tier, default MINEDU
							l(	integer 1)		/// administrative level, default region(==1)
							reps(integer 100)	/// no of reps/rows
							seed(integer 123)]	/// sets first random seed
							var( namelist ) // requires a varlist of variables w values that are numeric
							//measure(string d_*)]	// measurement, default is mean abs difference.




			* C2. Run programs for each country

			// macro manipulations
			local last: list sizeof cty			// where `last' refers to the size of teh list
			tokenize `cty'
			// note that ``last'' refers to the last tokenized element of `cty'

			// gen local with value of mincity+1
			loc 	next = `mincty' + 1
`'

			foreach val of local cty {

				*0. sequoia = setup (is not run by Biscayne, need to run once for each country)
				sequoia, 	gov(`gov') 	///	govt_tier == MINEDU
							l(`l')	///	admin level == region
							cty(`val')	/// country == PERU
							var(`var')	// outcome variable set to `var'


				* 2. biscayne, which runs acadia.

				biscayne, 	cty(`val') 		/// where country is the value in the loop
							gov(`gov')		///	govt_tier
							l(	`l')		///	admin level
				 			n(`n') 			///	max no of pulls
							reps(`reps') 	///	no of rows/reps
							seed(123)		///	beginning seed
							var(`var')		// outcome variable set to `var'

			* C3. create country variable, resave
			use 			`"${GLOBE_pomcdta}/`var'/mcrow_gov`gov'_${pos_`val'}.dta"', clear
			gen 			country = `val'
			save 			`"${GLOBE_pomcdta}/`var'/mcrow_gov`gov'_${pos_`val'}.dta"', replace

			use 			`"${GLOBE_pomcdta}/`var'/mcrow_g`l'_gov`gov'_${pos_`val'}.dta"', clear
			gen 			country = `val'
			save			`"${GLOBE_pomcdta}/`var'/mcrow_g`l'_gov`gov'_${pos_`val'}.dta"', replace


			}
			/* end forvalues loop */

			* C4. then append all files, starting with first file


				// for 'onerow' datasets, again, why do we need this.
				use `"${GLOBE_pomcdta}/`var'/mcrow_gov`gov'_${pos_`1'}.dta"', clear		// use the first file

					// the followin loop will only work if govt_tier is >1 (ie, is not minedu)

				if (`gov' > 1)	{

					forvalues i = `2'/``last'' {					// from the second value to the last value
					append using `"${GLOBE_pomcdta}/`var'/mcrow_gov`gov'_${pos_`i'}.dta"'
					}
					/*end maxcity loop*/
				}
				/*end if/gov switch*/

					order country

					save  "${GLOBE_pomcdta}/`var'/mc_gov`gov'_final.dta", replace



				// for 'by-each-glevel datasets'
				use `"${GLOBE_pomcdta}/`var'/mcrow_g`l'_gov`gov'_${pos_`1'}.dta"', clear		// use the first file

				// the followin loop will only work if govt_tier is >1 (ie, is not minedu)

				if (`gov' > 1)	{	// here we have to create a dif loop cuz not all countries have region office

					forvalues i = `2'/``last'' {
					append using `"${GLOBE_pomcdta}/`var'/mcrow_g`l'_gov`gov'_${pos_`i'}.dta"'
					}
						/* end forvalues loop*/
				}
					/*end gov>1 loop*/
				if (`gov' == 1) {	// here we know that all countries have minedu so we just loop through all.

					forvalues i = 2/``last'' {
					append using `"${GLOBE_pomcdta}/`var'/mcrow_g`l'_gov`gov'_${pos_`i'}.dta"'
					}
						/* end forvalues loop */
				}
					/*end gov>1 loop*/



					order country

					save  "${GLOBE_pomcdta}/`var'/mc_g`l'_gov`gov'_final.dta", replace




		end















***
	**
		* Program D: Denali: converts the output files from Canyonlands to a graphable form.


	/*Note, because stata is annoying and won't let you reshape in multiple iterations in one go,
	we have to split up the dataset by country and statistic, reshape independently for each statistic,
	then merge and then append.  */


* D0. Opening

cap program drop denali
program 	denali, rclass

version 	15.1


* D1. Define Syntax

syntax, max(integer	1)	/// max no of countries
		gov(integer 1)	/// govt_tier, default MINEDU
		l  (integer 1)	/// admin level
		var( namelist) // requires a varlist whose values are numeric


										/* _____________________________

											Set locals/settings

											____________________________*/



	*local max = 4 		// set to max no of countries
	*local gov = ${gov}
	*local var ${var}






										/* _____________________________

											D2. Run for minedu

											____________________________*/



// ___________________________ declare tempfiles

tempfile c1 c2 c3 c4 ///
			mean sd p25 p75 meantop meanlow

// ___________________________ use the final wide dataset

use "${GLOBE_pomcdta}/`var'/mc_gov`gov'_final.dta", clear


// ___________________________ begin the country loop

forvalues c = 1/`max' {
	preserve						// disaster prevention

		keep 	if country == `c'

		save 	`c`c'', replace

		// begin the stat loop
		foreach stat in mean sd p25 p75 meantop meanlow {
			use 	`c`c'', clear
			keep 	country `stat'_error*


			reshape long `stat'_error, i(country) j(nkeep)
			save 	``stat'', replace

		}
		/*end stat loop*/

		use 	`mean', clear

		// begin merge loop
		foreach stat in sd p25 p75 meantop meanlow {
			merge 1:1 nkeep using ``stat'' ///
					, assert(3) nogen		// ensures all obs will match
		}
		/*end merge loop*/

		save `c`c'', replace

	restore						// restores to final wide dataset for repeat
}
/*end forvals/country loop */



// ___________________________ append all countries

use 	`c1', clear

append 	using ///
		`c2' `c3' `c4'


// ___________________________ export

save "${GLOBE_pomcdta}/`var'/mc_gov`gov'_finallong.dta", replace


tempfile drop 		c1 c2 c3 c4 ///				drop tempfiles for easy recycle later
			mean sd p25 p75 meantop meanlow







									/* _____________________________

										D3. Run for by-Regions (most from
											now on)

										____________________________*/



/* This script does exactly as ~reshape except it accounts for the new scripts
	that make the datasets grouped by admin region */

* region-specific settings
*local max 	= 4 		// set to max no of countries
*local g 	= ${admin}	// point to the administrative level (1=region, 2=district, etc)





// ___________________________ declare tempfiles

tempfile c1 c2 c3 c4 ///
		mean sd p25 p75 meantop meanlow

// ___________________________ use the final wide dataset

use "${GLOBE_pomcdta}/`var'/mc_g`l'_gov`gov'_final.dta", clear


// ___________________________ begin the country loop

forvalues c = 1/`max' {
preserve						// disaster prevention

	keep 	if country == `c'

	save 	`c`c'', replace

	// begin the stat loop
	foreach stat in mean sd p25 p75 meantop meanlow {
		use 	`c`c'', clear
		keep 	country g`l' `stat'_error* count


		reshape long `stat'_error, i(country g`l' count) j(nkeep) // should be country-g1
		save 	``stat'', replace

	}
	/*end stat loop*/

	use 	`mean', clear

	// begin merge loop
	foreach stat in sd p25 p75 meantop meanlow {
		merge 1:1 nkeep count g`l' using ``stat'' ///
				, assert(3) nogen		// ensures all obs will match
	}
	/*end merge loop*/

	save `c`c'', replace

restore						// restores to final wide dataset for repeat
}
/*end forvals/country loop */



// ___________________________ append all countries

use 	`c1', clear

append 	using ///
	`c2' `c3' `c4'

sort 	country g`l' nkeep


// ___________________________ export

save "${GLOBE_pomcdta}/`var'/mc_g`l'_gov`gov'_finallong.dta", replace


tempfile drop 		c1 c2 c3 c4 ///				drop tempfiles for easy recycle later
			mean sd p25 p75 meantop meanlow




end






















***
	**
		* Program E: Everglades: graphs the adjusted output files from Denali


	/*Note, because stata is annoying and won't let you reshape in multiple iterations in one go,
	we have to split up the dataset by country and statistic, reshape independently for each statistic,
	then merge and then append.  */


* E0. Opening

cap program drop everglades
program 	everglades, rclass

version 	15.1


* E1. Define Syntax

syntax, max(integer	1)	/// max no of countries
		gov(integer 1)	/// govt_tier, default MINEDU
		l  (integer 1)	/// admin level
		var( namelist) // requires a varlist whose values are numeric



								/* - - - - - - - - - - - - - - - -
									Table of Contents
									1. MC simulations for MINEDU



								- - - - - - - - - - - - - - - - - */


	set 	graph off

	* locals
	loc 		max = 4 		// set to max no of countries
	loc 		var ${var}



	* 		%% redo this section when you loop through all govt tiers and countries and outcome vars
	// set to 1 if you want to run that graph set
	loc			minedu25 = 0	// MinEDU with 25/75 pctile bands
	loc 		minedusd = 0	// MinEDU with +/- 1 sd bands
	loc 		region 	 = 0 	// Regional offices points
	loc 		district = 1	// District offices points

	loc 		regioncountries = "1 2"
	loc 		districtcountries = "1 2"


	// change settings according to predefined globals
		if 	"`var'" == "minedu" {

		loc		minedu25 = 0	// MinEDU with 25/75 pctile bands
		loc 	minedusd = 1	// MinEDU with +/- 1 sd bands
		loc 	region 	 = 0 	// Regional offices points
		loc 	district = 0	// District offices points
		}

		if 	"`var'" == "region" {

		loc		minedu25 = 0	// MinEDU with 25/75 pctile bands
		loc 	minedusd = 0	// MinEDU with +/- 1 sd bands
		loc 	region 	 = 1 	// Regional offices points
		loc 	district = 0	// District offices points
		}

		if 	"`var'" == "district" {

		loc		minedu25 = 0	// MinEDU with 25/75 pctile bands
		loc 	minedusd = 0	// MinEDU with +/- 1 sd bands
		loc 	region 	 = 0 	// Regional offices points
		loc 	district = 1	// District offices points
		}






							/* - - - - - - - - - - - - - - - -
								E3. dot-plot with +/- 1 std dev bands

							- - - - - - - - - - - - - - - - - */


	if (`minedusd' == 1) {

	// load dataset

	use 	"${GLOBE_pomcdta}/`var'/mc_g1_gov1_finallong.dta", clear

	preserve

	drop 	if nkeep > count 	// drop obs where the number of ppl kept is greater than the no ppl in dept





foreach v of global contcombo {


	twoway 		rcap ///
				meantop_error meanlow_error nkeep /*x*/ ///
				if country == `v'					///
				, scheme(plotplain)  			///
				title("${pos_`v'}: Monte Carlo Simulation of MinEdu Sampling Sensitivity") ///
				${set_mc_graph2}		///
				||								///		starting scatter 2
				scatter mean_error nkeep /*x*/	///
				if country == `v'				///
				, m(smcircle)

				graph export 	"${scatters}/mc/sd/`var'/mc_${var}_${pos_`v'}_minedu.png", replace

			}
			/* end forvals/ country loop */

	restore

	}
	/* end minedusd switch */




							/* - - - - - - - - - - - - - - - -
								E4. dot-plot for g1 (region)


							- - - - - - - - - - - - - - - - - */



						/* 												*/
							This plot will create a 'bubble' for each
						  	district/region-level mean for a given no
							of observations kept/dropped. the y axis
							or bubble will measure deviation from the
							mean bi in the district in which it belongs.
						/*												*/
							* here a 'bubble' means literal dots.


if (`region' == 1) {


	// load dataset

	use 	"${GLOBE_pomcdta}/`var'/mc_g1_gov2_finallong.dta", clear

	preserve

	drop 	if nkeep > count 	// drop obs where the number of ppl kept is greater than the no ppl in dept


foreach v of global contcombo {


	twoway 		scatter	///
	 			mean_error 			///	 yvar
				nkeep 				///	 xvar
				if country == `v'					///
				, scheme(plotplain)  			///
				title("${pos_`v'}: Monte Carlo Simulation of Regional Offices' Sampling Sensitivity") ///
					${set_mc_graph3}

				graph export 	"${scatters}/mc/sd/`var'/mc_g1_${var}_${pos_`v'}_region.png", replace

			}
			/* end forvals/ country loop */


	restore

		}
		/* close region switch */




								/* - - - - - - - - - - - - - - - -
									E5. dot-plot for g2 (district)


								- - - - - - - - - - - - - - - - - */



								/* 												*/
								This plot will create a 'bubble' for each
								district/region-level mean for a given no
								of observations kept/dropped. the y axis
								or bubble will measure deviation from the
								mean bi in the district in which it belongs.
								/*												*/
								* here a 'bubble' means literal dots.


if (`district' == 1) {


	// load dataset

	use 	"${GLOBE_pomcdta}/`var'/mc_g2_gov3_finallong.dta", clear

	preserve

	drop 	if nkeep > count 	// drop obs where the number of ppl kept is greater than the no ppl in dept


		foreach v of global contcombo {



		twoway 		scatter	///
					mean_error 			///	 yvar
					nkeep 				///	 xvar
					if country == `v'					///
					, scheme(plotplain)  			///
					title("${pos_`v'}: Monte Carlo Simulation of District Offices' Sampling Sensitivity") ///
					${set_mc_graph4}

					graph export 	"${scatters}/mc/sd/`var'/mc_g2_${var}_${pos_`v'}_district.png", replace

		}
		/* end forvals/ country loop */


	restore

	}
	/* close district switch */



end



















***
	**
		* Program G: Glacier: repeats all programs for all possible iterations



		* G0. Opening

		cap program drop glacier
		program 	glacier, rclass

		version 	15.1


		* G1. Define Syntax/arguments


		args 	outcome1 outcome2 	// any combindation of arglist as varlist is

		syntax varlist [, ///
				reps(integer 100)	/// repetitions, default is 100
				NMINedu(integer 100)	/// no of people pulled at minedu central office
				NREGion(integer 30)		///	no of people pulled at region offices
				seed(integer 	123)	/// set random seed
				NDISTrict(integer 	30)]		/// no of people pulled at district offices
				GOVtier(namelist min=1)	// any combination of "minedu", "region" or "district", default is all 	minedu region district; must be specified/no default values



			/* maniuplations to arguments
			local k = 1 				// define counter

			while "`outcome`k''" != "" { 		// while there was an entry for this argument
			local ++k 					// increase the local k by 1
			}

			local --k 					// take one away from k
*/

			// more
			local varlist "`outcome1' `outcome2' `outcome3'  `outcome4' `outcome5' "
			di "`varlist'"
			tokenize `varlist'

			/* begin loop 1: govt_tier loop */
			foreach gov of local govtier {



				* change/define govt tier specific settings
				if 	"`gov'" == "minedu" {

					loc govt 	= 1
					loc admin	= 1
					loc contcombo "1 2"		
					loc pull 	= `nminedu'		// transform no pulled to same-named local
					loc size 	: list sizeof contcombo // store no of countries
				}

				if 	"`gov'" == "region" {

					loc govt 	= 2
					loc admin	= 1
					loc contcombo "1 2"		
					loc pull 	= `nregion' 	// transform no pulled to same-named local
					loc size 	: list sizeof contcombo // store no of countries

				}

				if 	"`gov'" == "district" {

					loc govt 	= 3
					loc admin	= 2
					loc contcombo "1 2"		
					loc pull 	= `ndistrict' 	// transform no pulled to same-named local
					loc size 	: list sizeof contcombo // store no of countries

				}




				/* begin loop 2: outcome variable loop */
				foreach var of local varlist { 		// = 1(1)`k'

					/*then we list var as ``var'' since:

											``var'' -> `1' -> [varname]

					 */




		* G2: (canyondlands runs earlier programs necessary for each country)
			* generates matrix for each country given specific tier and outcome var



			canyonlands,	n(`pull')		/// max no of ppl pulled, deault == 30 (note: cumulative); SETTINGS
							cty(`contcombo')	/// separte with commas; SETTINGS
							gov( `govt')		/// govt_tier, default MINEDU; SETTINGS
							l(	 `admin')		/// administrative level, default region(==1); district == 2; SETTINGS
							reps(`reps')	/// no of reps/rows; COMMAND
							seed( `seed')	/// sets first random seed; COMMAND
							var(`var')		// set outcome variable; COMMAND



		* G3: run Denali and Everglades to generate the graphs for all counties, 1 tier and 1 outcome variable.



			denali, 		max(`size')	/// max no of countries %% may just have to write 4 here. SETTINGS
							gov(`govt')	/// govt_tier; SETTINGS
							l  (`admin')	/// admin level, region ==1 district == 2; SETTINGS
							var( `var') // requires a varlist whose values are numeric; COMMAND


			everglades, 	gov(`govt')	/// govt_tier, default MINEDU; SETTINGS
							l  (`admin')	/// admin level;  SETTINGS
							var( `var') // requires a varlist whose values are numeric; COMMAND





			}
			/* end outcome variable loop  */

	}
	/* end govt_tier loop */




end















***			***			***			***			***			***			***			***
	**			**			**			**			**			**			**			**
*	*	* 	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
	**			**			**			**			**			**			**			**
***			***			***			***			***			***			***			***



***			***			***			***			***			***			***			***
	**			**			**			**			**			**			**			**
*	*	* 	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*


	*loc 	type 	"minedu"		// set to either: minedu, region, district, no we want to run for all
	loc 	var 	outcome1	 // set to the main outcome variable

*	*	* 	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
	***			***			***			***			***			***			***			***
		**			**			**			**			**			**			**			**
/*
	if 	"${type}" == "minedu" {

		loc gov 	= 1
		loc admin	= 1
		loc contcombo "1 2 3 4"	// replace with all countries
		loc pull 	= 85
		loc reptns 	= 100
	}

	if 	"${type}" == "region" {

		loc gov 	= 2
		loc admin	= 1
		loc contcombo "1 3 4"	// exclude JOR
		loc pull 	= 30
		loc reptns 	= 100
	}

	if 	"${type}" == "district" {

		loc gov 	= 3
		loc admin	= 2
		loc contcombo "1 2 3"	// exclude RWA
		loc pull 	= 30
		loc reptns 	= 100
	}
*/

							timer clear // clear previous timers
							timer on 1	// turn on timer 1
 use "${GLOBE_po}", clear

	glacier outcome1 outcome2, 	/// bi national_learning_goals mandates_accountability quality_bureaucracy impartial_decision_making 
				gov(minedu) /// set to 'minedu', 'district' or 'region'
				nminedu(5)		/// max no of ppl pulled, deault == 30 (note: cumulative) `pull'
				nregion(5)	///
				ndistr(5) ///
				seed( 123)	/// sets first random seed





							timer 	off 1 // turn timer 1 off
							timer 	list 1 // list results for timer1
							loc 		t_c	= r(t1)/60		// store value of timer in global in min
