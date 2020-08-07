# Mdataset.R
# appends all schools datasets and all public officials dataset (raw)

library(rio)
library(tidyverse)
library(readstata13)
library(sf)
library(assertthat)

                      # ----------------------------- #
                      # Load+append schools datasets  #----
                      # ----------------------------- #
vault <- file.path("A:/Countries")

# Peru
peru_school <- import(file.path(vault, 
                     "Peru/Data/Full_Data/school_indicators_data.RData"),
                    which = "school_dta_short") 

# Jordan
jordan_school <- import(file.path(vault, 
                               "Jordan/Data/Full_Data/school_indicators_data.RData"),
                     which = "school_dta_short")

# Mozambique :: note there is no Rdata file. 
mozambique_school <- import(file.path(vault, 
                               "Mozambique/Data/school_inicators_data.dta")) %>%
  rename(school_name_preload = school,
         school_province_preload = province,
         school_district_preload = district,
         school_code = sch_id,
         ecd_student_knowledge = ecd,
         principal_knowledge_score = school_knowledge,
         principal_management = management_skills) %>%
  select(school_name_preload:lon)

# Rwanda
rwanda_school <- import(file.path(vault, 
                               "Rwanda/Data/Full_Data/school_indicators_data.RData"),
                     which = "school_dta_short")

# bind rows 
m.school <- bind_rows("Peru" = peru_school,
                      "Jordan" = jordan_school,
                      "Rwanda" = rwanda_school,
                      "Mozambique" = mozambique_school,
                      .id = "country")






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
                      .id = "country") %>%
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

# determine that each row is unique 
any(duplicated(m.school, by = c("school_code", "country")))
  # remove the one obs of mozambique that is duplicated %%
m.school$dups <- duplicated(m.school, by = c("school_code", "country"))



anyDuplicated(m.school$school_code, m.school$country)
assert_that(any(is.na(m.school$country)) == 0)
assert_that(any(duplicated(m.school$school_code,
                          m.school$country)) == 0)

# generate project id for schools (idschool)
set.seed(47)
m.school$idschool <- runif(length(m.school$school_code)) %>%
  rank()

  
# determine that each row is unique
any(duplicated(m.po, by = c("interview__id", "country")))


# generate project id for public officials (idpo)
set.seed(417)
m.po$idpo <- runif(length(m.po$interview__id)) %>%
  rank()



# save as main datasets
saveRDS(m.school,
        file = "A:/main/m-school.Rda")
saveRDS(m.po,
        file = "A:/main/m-po.Rda")






                                # ------------------------------------- # 
                                # import WB subnational geojson files   # ----
                                # ------------------------------------- # 
wbpoly <-
  "C:/Users/WB551206/OneDrive - WBG/Documents/WB_data/names+boundaries/20160921_GAUL_GeoJSON_TopoJSON"

wb.poly <- st_read(file.path(wbpoly, "GeoJSON/g2015_2014_2.geojson")) %>%
  filter(ADM0_NAME == "Peru" | ADM0_NAME == "Jordan" | ADM0_NAME == "Mozambique" | ADM0_NAME == "Rwanda")

# check for duplicates
assert_that(anyDuplicated(wb.poly$ADM2_CODE) == 0)





                                # ------------------------------------- # 
                                #         random ID creation            # ----
                                # ------------------------------------- # 
                                

# create random g0 id (ADM0_CODE): country
wbpoly0 <- as.data.frame(select(wb.poly, ADM0_CODE)) %>%
  group_by(ADM0_CODE) %>%
  summarize()   #collapse by unique value of ADM0_code

set.seed(417)
wbpoly0$g0 <- 
  runif(length(wbpoly0$ADM0_CODE))  %>% # generate a random id based on seed
  rank()



# create random g1 id (ADM1_CODE): region
wbpoly1 <- as.data.frame(select(wb.poly, ADM1_CODE, ADM0_CODE)) %>%
  group_by(ADM1_CODE, ADM0_CODE) %>%
  summarize()    #collapse by unique value of ADM0_code

set.seed(417)
wbpoly1$g1 =  runif(length(wbpoly1$ADM1_CODE))  %>% # generate a random id based on seed
  rank()



# create random g2 id (ADM2_CODE): district
wbpoly2 <- as.data.frame(select(wb.poly, ADM2_CODE, ADM1_CODE, ADM0_CODE)) %>%
  group_by(ADM2_CODE, ADM1_CODE, ADM0_CODE) %>%
  summarize()    #collapse by unique value of ADM0_code

set.seed(417)
wbpoly2$g2 =  runif(length(wbpoly2$ADM2_CODE))  %>% # generate a random id based on seed
  rank()



# merge id's back to world poly
wb.poly.m <- 
  left_join(wb.poly, wbpoly0, by = "ADM0_CODE") %>%
  left_join(wbpoly1, by = c("ADM0_CODE", "ADM1_CODE")) %>%
  left_join(wbpoly2, by =  c("ADM0_CODE", "ADM1_CODE", "ADM2_CODE"))

# assert that there are no duplicates of the three randomized ids
assert_that(anyDuplicated(wb.poly.m$g2,
                          wb.poly.m$g1,
                          wb.poly.m$g0) == 0)




                            
                            # ------------------------------------- # 
                            #   spatial join with main dataset      # ----
                            # ------------------------------------- # 

# use st_join to match mother dataset obs to geographic location based on gps 






saveRDS(wb.poly,
        file = "A:/main/wb-poly4.Rda")

