# convert-dta.R
# converts dta files to Rda files.

library(readstata13)
library(tidyverse)

# object with outcome variables
yvars <- c("student_knowledge",
           "ecd_student_knowledge",
           "inputs",
           "infrastructure",
           "intrinsic_motivation",
           "content_knowledge",
           "operational_manage",
           "instr_leader",
           "principal_knowl_score",
           "principal_manage",
           "bi",
           "national_learning_goals",
           "mandates_accountability",
           "quality_bureaucracy",
           "impartial_decision_making"
)


condl <- c(
  "pct_urban",
  "med_age",
  "pct_school",
  "pct_lit",
  "pct_edu1",
  "pct_edu2",
  "pct_work",
  "pct_schoolage",
  "pct_elec" ,
  "pct_dwell",
  "enrolled",
  "ln_gdp",
  "ln_dist_n_stud"
)

# Table Labels 
dvlab <- c("Student Knowledge", "ECD Knowledge", "Inputs", "Intrastructure", "Teacher Motivation", "Teacher Content Knowledge", "Operational Management", "Instructional Leadership", "Pricipal Knowledge", "Principal Management")

ivlab <- c("% Urban", "Literacy Rate", "% Schoolage", "% Electricity", "% Improved Dwelling")


#load data
md <- read.dta13(file = "C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/global-edu-dashboard/baseline/DataSets/final/merge_district_tdist.dta",
                 convert.factors = TRUE) %>%
  select(idschool, countryname, g1, g2, condl, yvars)


# save as Rda. 
saveRDS(md, file = "C:/Users/WB551206/local/GitHub/global-edu-dashboard/scripts/shiny/GECD/final-by-district.Rda")
