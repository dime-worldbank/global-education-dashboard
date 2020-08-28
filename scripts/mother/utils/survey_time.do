* survey_time.do
* converts incoming survey time to stata-readable time, and doy, dom formats

/* note that for privacy reasons, we will only geneate the dow/day of week
variable by default but if we flip the switch we can generate other time variables,
but note that if you do this you should edit the code to remove this in the final version.
 */


* remove "T" that separates date from time, replace with " " space.
gen survey_time2 = subinstr(survey_time, "T", " ", 1)

* convert into %tC format f
gen double datetime = clock(survey_time2, "YMD hms")

* gen year, mo, day etc vars
format 			datetime %tc

	// generate a %td variable (without time)
	gen 			date = date(survey_time2, "YMD###")
	format 			date %td

	// define day of week value labels
	la def dow 		0 "Sunday" 1 "Monday" 2 "Tuesday" 3 "Wednesday" 4 "Thursday" ///
	 				5 "Friday" 6 "Saturday"

	// generate Day of Week Variable.
	gen 			dow : dow = dow(date)
	la var 			dow "interview day of week"

* drop time vars that were needed to generate dow
drop 				survey_time2 datetime date


* Generate Raw Dates 
/* 	This section generates actual dates that the survey was conducted. If you
	generate this it becomes PII, so there's a switch, s5, that is set by default
	to NOT generate these date variables by default. */

if (`s5' == 1) {
	// generate year, mo, day etc
	gen				year = year(date)
	gen 			month : month = month(date)
	gen 			day = day(date)

	gen 			hour = hh(datetime)
	gen 			min = mm(datetime)

	gen 			quarter = quarter(date)
	gen 			week = week(date)
	gen 			doy = doy(date)

	// var labels
	la var 			datetime 	"date and time"
	la var 			date 		"date"
	la var 			year 		"year"
	la var 			month 		"month"
	la var 			day 		"day"
	la var 			hour 		"hour"
	la var 			min 		"minute"
	la var 			quarter		"quarter of year"
	la var 			week 		"week of year"
	la var 			doy 		"day of year"
}
