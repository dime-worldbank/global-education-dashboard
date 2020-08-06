# Mdataset.R
# appends all schools datasets and all public officials dataset (raw)

library(rio)
library(tidyverse)
library(readstata13)

                      # ----------------------------- #
                      # Load+append schools datasets  #----
                      # ----------------------------- #
vault <- file.path("A:/Countries")

# Peru
peru_school <- import(file.path(vault, 
                     "Peru/Data/Full_Data/school_indicators_data.RData"),
                    which = "school_dta_short") %>%
  select(school_code:total_enrolled)

# Jordan
jordan_school <- import(file.path(vault, 
                               "Jordan/Data/Full_Data/school_indicators_data.RData"),
                     which = "school_dta_short") %>%
  select(school_code:total_enrolled)

# Mozambique :: note there is no Rdata file. 
mozambique_school <- import(file.path(vault, 
                               "Mozambique/Data/school_inicators_data.dta")) %>%
  rename(school_name_preload = school,
         school_province_preload = province,
         school_district_preload = district,
         school_code = sch_id) %>%
  select(school_code, school_name_preload, school_province_preload, 
         school_district_preload, lat, lon)

# Rwanda
rwanda_school <- import(file.path(vault, 
                               "Rwanda/Data/Full_Data/school_indicators_data.RData"),
                     which = "school_dta_short") %>%
  select(school_code:total_enrolled)

# bind rows 
m.school <- bind_rows("Peru" = peru_school,
                      "Jordan" = jordan_school,
                      "Rwanda" = rwanda_school,
                      "Mozambique" = mozambique_school,
                      .id = "Country")






                        # ----------------------------- #
                        # Load+append officials datasets#----
                        # ----------------------------- #

tiers <- c("Ministry of Education (or equivalent)", 
           "Regional office (or equivalent)",
           "District office (or equivalent)")

# Peru
peru_po <- read.dta13(file.path(vault, 
                                "Mozambique/Data/public_officials_survey_data.dta"),
                      convert.factors = TRUE,
                      generate.factors = TRUE ,
                      nonint.factors = TRUE) 


# Jordan
jordan_po <- read.dta13(file.path(vault, 
                                  "Mozambique/Data/public_officials_survey_data.dta"),
                        convert.factors = TRUE,
                        generate.factors = TRUE ,
                        nonint.factors = TRUE) 


# Mozambique :: note there is no Rdata file. 
mozambique_po <- read.dta13(file.path(vault, 
                                  "Mozambique/Data/public_officials_survey_data.dta"),
                            convert.factors = TRUE,
                            generate.factors = TRUE ,
                            nonint.factors = TRUE) 


# Rwanda
rwanda_po <- read.dta13(file.path(vault, 
                                  "Mozambique/Data/public_officials_survey_data.dta"),
                        convert.factors = TRUE,
                        generate.factors = TRUE ,
                        nonint.factors = TRUE)  %>%
  rename(end_time = "ENUMq1") 
  # convert ENUMq1 to numeric. issue is that this is not the duration but the end time
  # (must subract from start). For now I will simply rename as new variable called "end_time"


# bind rows 
m.po <-     bind_rows("Peru"   = peru_po,
                      "Jordan" = jordan_po,
                      "Rwanda" = rwanda_po,
                      "Mozambique" = mozambique_po,
                      .id = "Country") %>%
  mutate(
    govt_tier = fct_recode(govt_tier, # recode factor levels
                           "MinEDU Central" = "Ministry of Education (or equivalent)", 
                           "Region Office" = "Regional office (or equivalent)",
                           "District Office" = "District office (or equivalent)"
                           ))





                        # ----------------------------- #
                        # Generate project ID           #----
                        # ----------------------------- #

        # the project id will be randomly generated here:
        #   dataset           |     project id  |   raw id
        #     schools          = idschool       =   school_code
        #     public officials = idpo           =   interview__id
        #     
        # and the purpose will be joined to the working datasets with the raw id 
        # before de-identification.


# generate project id for schools (idschool)
set.seed(47)
m.school$idschool <- runif(length(m.school$school_code)) %>%
  rank()

  


# generate project id for public officials (idpo)
set.seed(417)
m.po$idpo <- runif(length(m.po$interview__id)) %>%
  rank()









# save as main datasets
saveRDS(m.school,
        file = "A:/main/m-school.Rda")
saveRDS(m.po,
        file = "A:/main/m-po.Rda")
