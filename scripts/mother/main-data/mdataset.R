# Mdataset.R
# appends all schools datasets and all public officials dataset (raw)

library(rio)
library(tidyverse)

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
vault <- file.path("A:/Countries")

# Peru
peru_po <- import(file.path(vault, 
                                "Peru/Data/Full_Data/public_officials_indicators_data.RData"),
                      which = "public_officials_dta_clean") %>%
  select(interview__id:director_hr, ORG1q1a:ENUMq8)

# Jordan
jordan_po <- import(file.path(vault, 
                              "Jordan/Data/Full_Data/public_officials_indicators_data.RData"),
                    which = "public_officials_dta_clean") %>%
  select(interview__id:director_hr, ORG1q1a:ENUMq8)

# Mozambique :: note there is no Rdata file. 
mozambique_po <- import(file.path(vault, 
                                  "Mozambique/Data/public_officials_survey_data.dta")) %>%
  select(interview__id:director_hr, ORG1q1a:ENUMq8) %>%
   # convert to factor, alter factor levels fct_recode?

# Rwanda
rwanda_po <- import(file.path(vault, 
                              "Rwanda/Data/Full_Data/public_officials_indicators_data.RData"),
                    which = "public_officials_dta_clean") %>%
  select(interview__id:director_hr, ORG1q1a:ENUMq8) %>%
  rename(end_time = "ENUMq1")
  # convert ENUMq1 to numeric. issue is that this is not the duration but the end time
  # (must subract from start). For now I will simply rename as new variable called "end_time"

# bind rows 
m.po <-     bind_rows("Peru"   = peru_po,
                      "Jordan" = jordan_po,
                      "Rwanda" = rwanda_po,
                      #"Mozambique" = mozambique_po,
                      .id = "Country")
# type convert




