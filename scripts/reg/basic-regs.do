* runs bivariate regs with country fixed effects and clustered standard errors

cls


log using "C:\Users\WB551206\OneDrive - WBG\Documents\Dashboard\global-edu-dashboard\out\log/basic-regs2.txt", text replace

use "C:\Users\WB551206\OneDrive - WBG\Documents\Dashboard\global-edu-dashboard\baseline\DataSets\final\merge_district_tdist.dta", clear


* loop 
foreach bi in bi national_learning_goals mandates_accountability quality_bureaucracy impartial_decision_making{


foreach s in student_knowledge ecd_student_knowledge inputs infrastructure intrinsic_motivation content_knowledge operational_manage instr_leader principal_knowl_score principal_manage {
di "`bi' vs `s'"
reg `s' `bi' i.country, vce(cluster g2)

di " "
di " "
di " "
}
}

log close 