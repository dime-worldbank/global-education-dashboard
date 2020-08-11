# Mdataset.R
# appends all schools datasets and all public officials dataset (raw)


library(tidyverse)
library(readstata13)
library(sf)
library(assertthat)
library(rio)
library(haven)
library(sjlabelled)

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
                      .id = "countryname")






                        # ----------------------------- #
                        # Load+append officials datasets#----
                        # ----------------------------- #

tiers <- c("Ministry of Education (or equivalent)",
           "Regional office (or equivalent)",
           "District office (or equivalent)")

# Peru
peru_po <- import(file.path(vault,
                            "Peru/Data/Full_Data/public_officials_indicators_data.RData"),
                  which = "public_officials_dta_clean")


# Jordan
jordan_po <- import(file.path(vault,
                              "Jordan/Data/Full_Data/public_officials_indicators_data.RData"),
                    which = "public_officials_dta_clean")


# Mozambique :: note there is no Rdata file.
mozambique_po <- read.dta13(file.path(vault,
                                  "Mozambique/Data/public_officials_survey_data.dta"),
                            convert.factors = TRUE,
                            generate.factors = FALSE ,
                            nonint.factors = FALSE)
      # will levels be same as rest by when converting from numeric to factor?
      #mozambique_po$govt_tier <- factor(mozambique_po$govt_tier, levels = tiers) %>%
                                factor()


# Rwanda
rwanda_po <- import(file.path(vault,
                              "Rwanda/Data/Full_Data/public_officials_indicators_data.RData"),
                    which = "public_officials_dta_clean")  %>%
                    rename(end_time = "ENUMq1")
  # convert ENUMq1 to numeric. issue is that this is not the duration but the end time
  # (must subract from start). For now I will simply rename as new variable called "end_time"


# bind rows
m.po <-     bind_rows("Peru"   = peru_po,
                      "Jordan" = jordan_po,
                      "Rwanda" = rwanda_po,
                      "Mozambique" = mozambique_po,
                      .id = "countryname") %>%
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
m.school <- distinct(m.school, countryname, school_code, lat, lon, student_knowledge,
           .keep_all = TRUE)  # dyplr will keep first value of dups across these vars

m.po <- distinct(m.po, countryname, interview__id, lat, lon, national_learning_goals,
           .keep_all = TRUE) # remove dups across these variables

# make sure no missings for key variables
assert_that(any(is.na(m.school$countryname)) == 0) #no country codes are missing
assert_that(any(is.na(m.school$school_code)) == 0) #no school codes are missing
assert_that(any(is.na(m.po$countryname)) == 0) #no country codes are missing
assert_that(any(is.na(m.po$interview__id)) == 0) #no school codes are missing


# generate project id for schools (idschool)
set.seed(47)
m.school$idschool <- runif(length(m.school$school_code)) %>%
  					rank()


# generate project id for public officials (idpo)
set.seed(417)
m.po$idpo <- runif(length(m.po$interview__id)) %>%
  				rank()

# generate project id for officeid (idoffice)
set.seed(417)
m.po$idoffice <- runif(length(m.po$office_preload)) %>%
					rank()

# save as main datasets
saveRDS(m.school,
        file = "A:/main/m-school.Rda")
saveRDS(m.po,
        file = "A:/main/m-po.Rda")

# gerenate gps only datasets with country id,
m.po.gps <- select(m.po,
                   countryname,
                   interview__id,
                   lon,
                   lat)

m.school.gps <- select(m.school,
                       countryname,
                       school_code,
                       lon,
                       lat)






                                # ------------------------------------- #
                                # import WB subnational geojson files   # ----
                                # ------------------------------------- #
imprt <- 0
# this takes a long time and is saved as Rda, if imprt ==0, will import rda

if (imprt == 1) {

wbpoly <-
  "C:/Users/WB551206/OneDrive - WBG/Documents/WB_data/names+boundaries/20160921_GAUL_GeoJSON_TopoJSON"

wb.poly <- st_read(file.path(wbpoly, "GeoJSON/g2015_2014_2.geojson")) %>%
  filter(ADM0_NAME == "Peru" | ADM0_NAME == "Jordan" | ADM0_NAME == "Mozambique" | ADM0_NAME == "Rwanda") %>%
  distinct(ADM2_CODE, ADM1_CODE, ADM0_CODE, .keep_all = TRUE)  # remove any possible duplicates


# check for duplicates: district code
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
  left_join(wbpoly2, by =  c("ADM0_CODE", "ADM1_CODE", "ADM2_CODE")) %>%
  distinct(g0, g1, g2, .keep_all = TRUE)

# assert that there are no duplicates of the three randomized ids
assert_that(anyDuplicated(wb.poly.m$g2,
                          wb.poly.m$g1,
                          wb.poly.m$g0) == 0)

        # we were pretty sure of this as we used distinct() above
        # but just to make be sure.

saveRDS(wb.poly.m,
         file = "A:/main/wb-poly-m.Rda")

}

if (imprt == 0) {
  wb.poly.m <- readRDS("A:/main/wb-poly-m.Rda")
}

                            # ------------------------------------- #
                            #   spatial join with main dataset      # ----
                            # ------------------------------------- #

# use st_join to match mother dataset obs to geographic location based on gps

# convert po + school dataset to sf objects

    # set geometry/point column first


po <- st_as_sf(m.po,
               coords = c("lon", "lat"),
               na.fail = FALSE)

school <- st_as_sf(m.school,
                   coords = c("lon", "lat"),
                   na.fail = FALSE)


    # set the crs of school + po as the same as the world poly crs
    st_crs(po) <- st_crs(wb.poly.m)
    st_crs(school) <- st_crs(wb.poly.m)
    st_crs(wb.poly.m)
    st_crs(po)

    st_is_longlat(po)
    st_is_longlat(wb.poly.m)


# join poly and po datasets
order <- c("ADM0_NAME", "ADM1_NAME", "ADM2_NAME",
           "ADM0_CODE", "ADM1_CODE", "ADM2_CODE",
           "g0", "g1", "g2")

main_po_data <- st_join(po, # points
                        wb.poly.m) %>% #polys
                left_join(m.po.gps, # join back to gps coords for reference
                          by = c("interview__id", "countryname")
                          ) %>%
                select(idpo, interview__id, order, everything())


# join poly and school datasets
main_school_data <- st_join(school, # points
                            wb.poly.m) %>% #polys
                    left_join(m.school.gps, # join back to gps coords for reference
                              by = c("school_code", "countryname")
                    ) %>%
                    select(idschool, school_code, order, everything())








                              # ------------------------------------- #
                              #               export                  # ----
                              # ------------------------------------- #



# save as rds/stata
save(main_po_data, main_school_data,
     m.po, m.school,
     wb.poly.m,
     tiers,
     file = "A:/main/final_main_data.Rdata")

#determine lists of vars to change length
varlist_p <- as.data.frame(colnames(main_po_data))
to.change_p <- varlist_p %>%
  filter(str_length(colnames(main_po_data)) > 26 )

varlist_to_change_p<-as.character(to.change_p$`colnames(main_po_data)`)


varlist_s <- as.data.frame(colnames(main_school_data))
to.change_s <- varlist_s %>%
  filter(str_length(colnames(main_school_data)) > 30 )

varlist_to_change_s<-as.character(to.change_s$`colnames(main_school_data)`)


# change the dataset accordingly
main_po_data_export <- main_po_data %>%
  st_set_geometry(., NULL) %>% # take out geometry
  rename_at(.vars=varlist_to_change_p, ~str_trunc(.,26,"center", ellipsis="")) %>% # rename long vars
  select(-contains("enumerator_name")) # take out enumerator name variable

main_school_data_export <- main_school_data %>%
  st_set_geometry(., NULL) %>% # take out geometry
  rename_at(.vars=varlist_to_change_s, ~str_trunc(.,30,"center", ellipsis="")) %>% # rename long vars
  select(-contains("enumerator_name")) # take out enumerator name variable

# # add varlabels
# labelled(colnames(main_po_data_export), labels = names(main_po_data_export))
# var_labels(main_po_data_export)
# is.labelled(main_po_data_export)
#
# varnames<- list(colnames(main_po_data_export))
# main_po_data_export <- set_label(main_po_data_export, varnames)




# export as dta
write_dta(data = main_po_data_export,
          path = "A:/main/final_main_po_data.dta",
          version = 14
     ) # default, leave factors as value labels, use variable name as var label


write_dta(data = main_school_data_export,
          path = "A:/main/final_main_school_data.dta",
          version = 14
) # default, leave factors as value labels, use variable name as var label

main_school_data %>% st_set_geometry(NULL) %>%
  write_dta(path = "A:/main/final_main_school_data.dta",
            version = 14 # v15 causes problems with </sortlist>
           )

# # credits: https://stackoverflow.com/questions/6986657/find-duplicated-rows-based-on-2-columns-in-data-frame-in-r
# https://gis.stackexchange.com/questions/224915/extracting-data-frame-from-simple-features-object-in-r
#
