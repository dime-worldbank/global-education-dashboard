# sumstats.R
# generates summary HTML docs from summary objects generated in the project

library(summarytools)
library(readstata13)
library(tidyverse)

# load main data 
load(file = file.path(repo.encrypt, "main/final_main_data_ipums.Rdata"))


# load main working stata merge-by-district dataset 
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
  "enrolled"
)


#load data
md <- read.dta13(file = "C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/global-education-dashboard/baseline/DataSets/final/merge_district_tdist.dta",
                 convert.factors = TRUE) %>%
  select(idschool, countryname, country, g1, g2, yvars, condl)

## make a last-minute summary objects
sum.main <- dfSummary(md,
           graph.col = TRUE, labels.col = FALSE, na.col = TRUE, style = 'multiline',
           col.widths = c(5, 40, 100, 60, 100, 40, 40)
)




# export summary objects
summarytools::view(sum.raw,         
                   file = file.path(html, "1-ipums-raw.html"),
                   footnote = "Raw IPUMS Data")
summarytools::view(sum.raw.bycountry,
                   file = file.path(html, "2-ipums-raw-bycountry.html"),
                   footnote = "Raw IPUMS Data by Country")
summarytools::view(sum.av,          
                   file = file.path(html, "3-ipums-district-averages.html"),
                   footnote = "IPUMS Conditional Variables Averaged by District")
summarytools::view(sum.main,        
                   file = file.path(html, "4-stata-main-district-merge.html"),
                   footnote = "Public Officials Data Averaged by District with Conditional Data from IPUMS")

