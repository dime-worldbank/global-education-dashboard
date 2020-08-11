* bi-reconstruct.do
* reconstructs all the Bureaucracy indicators from the raw questions. no bysorting is needed since all egen

*::: 2.A: Generate and checking the bureaucracy indicators  :::::::::::::::::::::::

	/*
	This script is designed to take the raw data from the survey of public officials and create all the tertiary, secondary, and primary indicator (s) for the Bureaucracy Indicators. Note, assumptions:
		1) This script assumes 	that all raw survey questions will be under the varnames below.
		2) '' 					that the math for creating each indicator stays constant over time.
		3) '' 					that variables that, for whatever reason, are not included in a specific survey, they will simply be excluded from both the average numerator and denominator.

		4) ''					that all data from the spreadsheet from which the document pulls is up to date.


		*/

	* 1 -> Load the spreadsheet with bi information
	preserve
		import excel using "C:\Users\WB551206\OneDrive - WBG\Documents\Dashboard\Edu+Dashboard\globaldocs\bi\EduDashboard_Country+Overview.xlsx", firstrow sheet(dataset_wide) clear


	* 2 -> create local lists of elements for each indicator
		ds
		local 		varlist = r(varlist)							// store a list of all variables in varlist

		foreach var of local varlist {
			qui:	levelsof `var', clean local(`var'_els)			// store a list of all the elements in locals
			}

	restore
	* 3 -> generate missing bi variables
		/*Note that the varlist of variables from the country overview excel is in a sense a master list of all the bi variables. a dataset should only contain exactly the same or fewer bi variables
				than this varlist. in the jordan dataset, for example, there is no QB4q3 in the dataset but it obviously appears in the master as it is a real question. what we will do here is create
				a list that contains the bi variables found in the master but not in the dataset and then generate these variables in the dataset as entirely missing. note that we must do this after
				searching/cleaning all missing values/vars because doing so after here would mean that it eliminates necessary bi vars.
			old variable = xyz1
			new variable = xyz0
		variable we keep = xyz

				*/


	*	----> create a list of all vars in po dataset
			ds
			local 	povarlist = r(varlist)

	*	----> generate a varlist of those variables that are found in teh master list but not in the povarlist
			local 	missing_bi: list questions_els - povarlist

	*	----> take all the elements in the list and generate missing variables with them (all should be numeric)
			foreach v of local missing_bi {
				gen `v' = .
				}


	* 3 -> create the averages

	* 	----> rename the bi variables in dataset
		/*	`v' 	the original variable, is left aside since it will be changed
			`v'0 	a copy of the original variable
			`v'1 	the new constructed variable
		*/
				foreach v of local all_els {
					clonevar `v'0 = `v'
					}

	*	----> first doing tertiary indicators...
	* 	--------> pure averages
				foreach tertiary of local tertiary_els {
					egen `tertiary'1 = rowmean(``tertiary'_els')			// average each element or question in tertiary indicators, removing missing observations from the numerator and denominator
					}
	* 	--------> special averages
				* > delete the pure average for motivation and attitudes
				drop motivation_attitudes1

				* > create the special average for motivation and attitudes.
					/*Note: the motivation and attitudes tertiary indicator has 11 total questions under it, but QB4q4a-H (8 total questions) are asking the same question about diferent hypothetical sitations. the
							overall structure for the averaging will go below as follows:

							motivation_attitudes =  [	( (QB4q1 + QB4q2 + QB4q3) / 3 ) + ( ( QB4q4a + QB4q4b + QB4q4c + QB4q4d + QB4q4e + QB4q4f + QB4q4g + QB4q4h ) / 8 )		]
							where each sub element is a scale of 1-5; thus motivation_attitudes has a maxium of 5 total points.
							*/

					* 1: create an average for the QB4q4a-H questions
							egen 	qb4q4av 				= rowmean(QB4q4a	QB4q4b	QB4q4c	QB4q4d	QB4q4e	QB4q4f	QB4q4g	QB4q4h)

							assert 	qb4q4av			 		<= 5 | qb4q4av == . // we know that this has to be true

					* 2: create an average for all QB4 questions (aka motivation_attitudes)
							egen 	motivation_attitudes1 	= rowmean(QB4q1	QB4q2 QB4q3 qb4q4av)
							assert  motivation_attitudes1	<= 5	// at this point there really should be no missing values.

	*	----> ...then, secondary indicators (all are pure averages)
				foreach secondary of local secondary_els {
					egen `secondary'1 = rowmean(``secondary'_els'1)
					}

	*	----> generate the overall bureaucracy indicator
				egen bi1 = rowmean(`bi_els'1)



	* 4. -> check everything

			// check that and that all tertiary vars are less than 5 and not equal to 0, or that they are missing.
			foreach tertiary of local tertiary_els {
				assert (`tertiary'1 	<= 5	& `tertiary'1 > 0 ) | (`tertiary'1 == .)
					}
			// check that and that all secondary vars are less than 5 and not equal to 0; there should be no secondary indicators missing.
			foreach secondary of local secondary_els {
				assert `secondary'1 	<= 5	& `secondary'1 != .
					}
			// check that the overall bi index is less than 5 and not equal to 0; there should be no missings.
				assert bi1 	<= 5	& bi1 > 0




	* gen differences from mine vs dataset's

		foreach v of local all_els {
			gen dif_`v' = `v'1 - `v'0					// create a variable that measures the differences and direction of the variable I generated, `v', compared to the one in the dataset `v'0
			replace `v' = `v'1							// replace this variable with the values from the one I generated
			gen dif2_`v' = abs(`v' - `v'1)				// create a new difference variable that verify that the two variables are equal
			sum dif2_`v'
			assert r(max) == 0							// check that replacing went well; that these two variables are equal. their differences should	be 0.
			drop dif_* dif2_* `v'1							// drop the difference vars
			}

	* ----> drop the original variables and `v'1, the constructed variable now changed.
				foreach v of local all_els {
					drop `v'0
					}

	* ---> do the same for bi except there's no bi0
			rename bi1 bi
