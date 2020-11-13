* runs bivariate regs with country fixed effects and clustered standard errors

cls

cap log close
log using "C:\Users\WB551206\OneDrive - WBG\Documents\Dashboard\global-education-dashboard\out\log/basic-regs3.txt", text replace

use "C:\Users\WB551206\OneDrive - WBG\Documents\Dashboard\global-education-dashboard\baseline\DataSets\final\merge_district_tdist.dta", clear


* loop 
foreach bi in bi national_learning_goals mandates_accountability quality_bureaucracy impartial_decision_making{


foreach s in student_knowledge ecd_student_knowledge inputs infrastructure intrinsic_motivation content_knowledge operational_manage instr_leader principal_knowl_score principal_manage {
di "`bi' vs `s'"

* Model specification
reg 	`s' /// outcome variable, one of school variables above
		`bi' /// buracuracy indicator as main explanatory variable
		pct_urban pct_lit pct_schoolage pct_elec pct_dwell /// district conditionals
		i.enrolled i.country 	/// enrollment size category and country as factor variables 
		, vce(cluster g2) 		// cluster on district
		


di " "
di " "
di " "
}
}

log close 