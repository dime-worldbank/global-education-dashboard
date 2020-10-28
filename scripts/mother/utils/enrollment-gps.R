# enrollment-gps.R
# extracts school-level enrollment and gps data and saves as Robjects for later incorporation 
#   into repository. This script is designed to be run/sourced within the mdataset.R script.


# Explanation 
# 
# because the school administrative data is received differently 
# from each country's respective ministries, there is no standard 
# way incorproate each excel/csv into the respository. the purpose of 
# this script is to serve as an intermediary between the raw csv data
# and the repository. The script will create a standardized r object
# with the following key variables: school_code will be the matching
# varible with the rest of the school-level data. 
# 
# 
#    __________
#   | Table A. |
#    
#   
#   school_code   | lon | lat |   sch_tot_enroll  | public | Country | Region  | District
#   
#   
#   
#  However, the data preparation upon creation of this table is not 
#  yet complete because the variable we are really after is the 
#  total number of students enrolled in each district (and likewise,
#  how many students are enrolled in the whole country). Because we 
#  cannot rely on the data in the csv's to be good enough to determine
#  district groupings (mispellings, extra spaces, etc), and becuase 
#  we use the World Bank's administrative data to determine districts,
#  we will need to validate this table above with the world bank polygon
#  data created in mdataset.R. We cannot just append this data directly
#  to the main dataset we create because the data here in enrollment-gps.R
#  includes all schools in each country, and the working sample in mdataset.R
#  is actually a subset of this national register. -- so if we matched 
#  by school_code we would drop most of the schools and would have no way of 
#  knowing how many students are enrolled in schools not in our sample. 
#  
#  Therefore, we will have to match by gps coordinate using sf package 
#  functions to determine the location and administrative positioning of 
#  the school in relation to the World Bank scheme, as in Table B. Not all 
#  countries have GPS coordinates; where coordinates are absent, we'll have 
#  to match by closest string name. 
#  
#  
#    __________
#   | Table B. |
#    
#   
#   school_code   |  lon  .|.|.|.. sch_tot_enroll | WB District Code | WB country code 
#   
#   
#   
#   We can use Table B to map WB admin data to the school level observations more reliably 
#   than using survey GPS data, since the data in Table B comes from ministries.
#   
#   
#   We will then have to summarize/collapse by the WB district code to sum the total number 
#   of students enrolled by (world bank) district, which would look like this.
#   
#   
#    __________
#   | Table C. |
#    
#   
#    total_district_enrollment | total_country_enrollment | WB District Code | WB country code 
#   
#   






# PLAN2 
# Ok now because there's such a discrepency of gps/location information avaialable 
# for each country, what the plan is not is to create an object for each country that will be 
# mapped onto each country's portion of the main dataset and geoprocessing there. the main 
# goal now will be to produce this for each country 
# 
# id1 | id2 | id3 | countryname | n_students | public | lat | lon
# 
# and match by one of the id codes to the main dataset




                    # ----------------------------- #
                    # 			 startup	 		          ----
                    # ----------------------------- #
     
library(tidyverse)
library(readr)
library(readxl)
library(fuzzyjoin)
library(stringi)



# load wb poly data 
wb.poly.m <- readRDS(file = file.path(root, "main/wb-poly-m.Rda"))



                    # ----------------------------- #
                    # By-country data extraction	    ----
                    # ----------------------------- #
              # Note: rost_  prefix indicates from the school roster data but 
              #       that also may change/be inaccurate. We may have double or 
              #       even triple variables that indicate the same thing.
              #       
              #       %% keep nightshift school variables. 

# vectors of column names to keep 
jor.raw.keep <- c("Organization code", "Supervisory authority", "longitude", "Latitude",
                  "Foundation period", "Total students", "Total male students", 
                  "Total female students", "Directorate", "Governorate")

rwa.raw.keep <- c("SCHOOL NAME", "DISTRICT", "SECTOR", "STATUS", "PROVINCE",
                  "Female students", "Male students", "Total  students", "school_code")

moz.raw.keep <- c("codigo", "turno", "ensino", "id", "school", 
                  "alu_hm_1", "alu_hm_2", "alu_hm_3", "alu_hm_4", "alu_hm_5",
                  "alu_m_1",  "alu_m_2",  "alu_m_3",  "alu_m_4",  "alu_m_5",
                  "orig_n_students", "orig_distrito", "orig_province", "orig_name")

per.raw.keep <- c("CODIGO MODULAR", "CODIGO LOCAL", "DEPARTAMENTO", "PROVINCIA", "DISTRITO",
                  "longitude", "latitude", "TOTAL-boys", "TOTAL-girls",
                  "D_GESTION")
                  
              

# Jordan: import, select columns, rename variables, fix variable types
jor.s.roster <-
  read_xlsx(
    path = file.path(vault,
                     "enrollment/List of all schools - Jordan - Arabic filled_EnglishTranslated.xlsx"),
    col_names = TRUE,
    sheet = "Sheet1") %>%
  select(jor.raw.keep) %>%
  rename(
    rost_id1      = "Organization code",
    rost_lat      = "Latitude",
    rost_lon      = "longitude", 
    n_students    = "Total students", 
    n_male        = "Total male students",
    n_female      = "Total female students",
    rost_district = "Directorate",  
    rost_region   = "Governorate" 
  ) %>%
  replace_na(list(n_male = 0, n_female =0)) %>%
  mutate(
    period        = as.factor(`Foundation period`),
    countryname   = "Jordan",
    n_students    = n_male + n_female,
    type          = as.factor(`Supervisory authority`)
  ) %>%
  select(-"Foundation period")


# Rwanda: import, select columns, rename variables
rwa.s.roster <- 
  read_xlsx(
    path = file.path(vault,
                     "enrollment/list of primary schools - Rwanda-import.xlsx"),
    col_names = TRUE,
    skip = 1,  # don't read the first merged cell, no info here.
    sheet = "ALL") %>%
  select(rwa.raw.keep) %>%
  rename(
    rost_name      = "SCHOOL NAME",
    rost_district  = "PROVINCE",  # "DISTRICT" corresponds to admin2 code in WB poly, "PROVINCE" to region/adm1
    n_students     = "Total  students",
    n_male         = "Male students",
    n_female       = "Female students"
  ) %>%
  mutate(
    countryname = "Rwanda",
    type        = as.factor(STATUS)
  )


# Mozambique: import, select columns, rename variables, create N_students
# # The  thing about Mozambique is that the data broken down by grade level 
# does not seem reliable. in most cases, the original variable for n_students 
# (orig_n_students) does not == the sum of the by-grade breakdown, and in most
# cases the by-grade breakdown is greater than orig_n_students. However, in a few
# cases, the by-grade-breakdown actually sums to 0, but the orig_n_students 
# variable is greater than 0. we will use the sum in cases where the sum is 
# greater than the orig_n_students and we will use the _orig_n_students in 
# cases where that is greater.
moz.s.roster <- 
  read_csv(
    file = file.path(vault,
                     "enrollment/list of schools - Mozambique.csv"),
    col_names = TRUE) %>%
  select(moz.raw.keep) %>%
  rename(
    rost_name      = "orig_name",
    rost_district  = "orig_distrito",
    rost_province  = "orig_province",
    rost_n_students= "orig_n_students",
    rost_id1       = "codigo",
    rost_id2       = "id",
    rost_id3       = "school"
  ) %>%
  replace_na(list(alu_hm_1 = 0, alu_hm_2 =0, alu_hm_3 =0, alu_hm_4 =0, alu_hm_5 =0,
                    alu_m_1 =0,  alu_m_2 =0,  alu_m_3 =0,  alu_m_4 =0,  alu_m_5=0)) %>%
  mutate(
    n_students.sum = alu_hm_1 + alu_hm_2 + alu_hm_3 + alu_hm_4 + alu_hm_5 +
                     alu_m_1 +  alu_m_2 +  alu_m_3 +  alu_m_4 +  alu_m_5,
    n_students     = if_else(n_students.sum >= rost_n_students,
                             true  = n_students.sum,
                             false = rost_n_students), 
    countryname    = "Mozambique",
    type           = as.factor(ensino),
    turno          = as.factor(turno)
    
  )



# Peru import, select columns, rename variables,
per.s.roster <- 
  read_csv(
    file = file.path(vault,
                     "enrollment/list of schools - Peru.csv"),
    col_names = TRUE) %>%
  select(per.raw.keep) %>%
  rename(
    rost_province  = "DEPARTAMENTO",
    rost_district  = "PROVINCIA",
    rost_subdist   = "DISTRITO",
    n_male         = "TOTAL-boys",
    n_female       = "TOTAL-girls",
    rost_id1       = "CODIGO MODULAR",
    rost_id2       = "CODIGO LOCAL",
    rost_lat       = "latitude",
    rost_lon       = "longitude"
  )  %>%
  replace_na(list(n_male = 0, n_female =0)) %>%
  mutate(
    n_students     = n_male + n_female,
    countryname    = "Peru",
    type           = as.factor(D_GESTION)
  )










                    # ----------------------------- #
                    #  Finalize each country's data 	 ----
                    # ----------------------------- #
      # here we will create an indicator variable that is TRUE if public and false 
      # otherwiese, and further trim down datasets 
      
# create nightshift school. (night) 
jor.s.roster$night <- if_else(jor.s.roster$period == "Evening", true = TRUE, false = FALSE) # insert varname and value that refers to nightshift school
rwa.s.roster$night <- FALSE # there is no variable for RWA so we assume all are day
moz.s.roster$night <- if_else(moz.s.roster$turno == "Diurno", true = FALSE, false = TRUE) # where diurno means "day"
per.s.roster$night <- FALSE # same for peru we assume that all are day



# create public variable
jor.s.roster$public <- if_else(jor.s.roster$type == "Private", true = FALSE, false = TRUE)
rwa.s.roster$public <- if_else(rwa.s.roster$type == "PRIVATE", true = FALSE, false = TRUE)
moz.s.roster$public <- TRUE # here moz only has one level: "Publica"
per.s.roster$public <- TRUE # here the UTF8 formatting is off, but all schools are public



# check for missings, assert that none is missing
assert_that(sum(is.na(jor.s.roster$public)) == 0 )
assert_that(sum(is.na(rwa.s.roster$public)) == 0 )
assert_that(sum(is.na(moz.s.roster$public)) == 0 )
assert_that(sum(is.na(per.s.roster$public)) == 0 )



# simplify variables and order 
jor.s.roster <- jor.s.roster %>%
  select(countryname, rost_id1, n_students, public, night, rost_lat, rost_lon)

rwa.s.roster <- rwa.s.roster %>%
  select(countryname, rost_name, school_code, rost_district, night, n_students, public)

moz.s.roster <- moz.s.roster %>%
  select(countryname, rost_district, rost_province,
         rost_id1, rost_id2, rost_id3, rost_district, night, n_students, public)

per.s.roster <- per.s.roster %>%
  select(countryname, rost_id1, rost_id2, n_students, public, night, rost_lat, rost_lon)



                    # ----------------------------- #
                    #  Create total students/district	  ----
                    # ----------------------------- #
              # The strategy will be to collapse the country enrollment data by 
              # country and distrct and create a variable that totals the number 
              # of students in each district. the tricky part is that we will have
              # to convert the preloaded district names in the rosters to the 
              # names used in the world bank data, either before or after the
              # collapse... 
              # 
              # First we will use the world bank polygon data to retreive the 
              # district names for those rosters with gps coordinates
              # 
              # Second, we will have to match district names by string to the 
              # world bank polygon data 

# match obs with gps coordinates to wb polygon 

## set as sf objects 
per.s.roster.sf <- st_as_sf(per.s.roster,
                            coords = c("rost_lon", "rost_lat"), # set geometry/point column first
                            na.fail = FALSE)

jor.s.roster.sf <- st_as_sf(jor.s.roster,
                            coords = c("rost_lon", "rost_lat"), # set geometry/point column first
                            na.fail = FALSE)

## set the crs as the same as the world poly crs
st_crs(per.s.roster.sf) <- st_crs(wb.poly.m)
st_crs(jor.s.roster.sf) <- st_crs(wb.poly.m)


## set the variable order
order <- c("ADM0_NAME", "ADM1_NAME", "ADM2_NAME",
           "ADM0_CODE", "ADM1_CODE", "ADM2_CODE",
           "g0", "g1", "g2")


## join poly and po datasets
per.s.roster.sf <- per.s.roster.sf %>%
  st_join(wb.poly.m) %>% 
  select(rost_id1, n_students, public, order)

jor.s.roster.sf <- jor.s.roster.sf %>%
  st_join(wb.poly.m) %>% 
  select(rost_id1, n_students, public, order)




## Group by district and summarize 
per.s.roster.sum <- per.s.roster.sf %>%
  filter(is.na(g2) == FALSE) %>%
  group_by(g0, g1, g2, ADM2_CODE) %>%
  summarise(
    dist_n_stud    = sum(n_students),
    ln_dist_n_stud = if_else(dist_n_stud > 0, log(dist_n_stud), 0),
    n_schools      = n(),
    med_stud_school= median(n_students)
  )

jor.s.roster.sum <- jor.s.roster.sf %>%
  filter(is.na(g2) == FALSE) %>%
  group_by(g0, g1, g2, ADM2_CODE) %>%
  summarise(
    dist_n_stud    = sum(n_students),
    ln_dist_n_stud = if_else(dist_n_stud > 0, log(dist_n_stud), 0),
    n_schools      = n(),
    med_stud_school= median(n_students)
  )
                        




# Match by string for Rwanda and Mozambique

## subset wb.poly 
#### The reason we're doing this is because there is a chance that if
#### we merged on the full 4 country polygon dataset that there are 
#### two districts in two different countries with the same name. There 
#### is of course this chance within one country but that chance is much
#### lower, so we split up the polygons to minimize cross-country
#### pollenation.
rwa.wb.poly <- wb.poly.m %>%
  filter(ADM0_NAME == "Rwanda")
moz.wb.poly <- wb.poly.m %>%
  filter(ADM0_NAME == "Mozambique")


## Group by district and summarize 
### RWA
rwa.s.roster.sf <- rwa.s.roster %>%
  filter(is.na(rost_district) == FALSE) # note that this is really filtering by region as rost_district is set to the region var

rwa.s.roster.sum <-
  mutate(rwa.s.roster.sf, # change to title case
         rost_dist_titl = str_to_title(rwa.s.roster.sf$rost_district)) %>%
  group_by(rost_dist_titl) %>%
  summarise(
    dist_n_stud    = sum(n_students),
    ln_dist_n_stud = if_else(dist_n_stud > 0, log(dist_n_stud), 0),
    n_schools      = n(),
    med_stud_school= median(n_students)
  ) %>%
  left_join(rwa.wb.poly,
            by = c("rost_dist_titl" = "ADM1_NAME"),
            keep = TRUE) %>% # where 'rost_dist_titl' == name of region, fomerly ADM2_CODE
  select(dist_n_stud, ln_dist_n_stud, n_schools, med_stud_school, g0, g1, g2, ADM2_CODE, ADM1_CODE, geometry) %>%
  st_as_sf() # rwa will be matched by ADM2_CODE



### MOZ
#### eliminate obs with missing district info
moz.s.roster.sf <- moz.s.roster %>%
  filter(is.na(rost_district) == FALSE)

# change encoding to remove accents 
moz.s.roster.sf <- moz.s.roster.sf %>%
  mutate( # change to title case, remove accents
         rost_dist_titl = stri_trans_general(str_to_title(moz.s.roster.sf$rost_district), "latin-ascii")
  ) 


#### make manual corrections 
moz.s.roster.sf$rost_dist_titl <- str_replace(moz.s.roster.sf$rost_dist_titl, "Bilene - Macia", "Bilene")
moz.s.roster.sf$rost_dist_titl <- str_replace(moz.s.roster.sf$rost_dist_titl, "Lichinga - Distrito", "Lichinga")
moz.s.roster.sf$rost_dist_titl <- str_replace(moz.s.roster.sf$rost_dist_titl, "Manjacaze - Dingane", "Mandlakaze")
moz.s.roster.sf$rost_dist_titl <- str_replace(moz.s.roster.sf$rost_dist_titl, "Nacala - Porto", "Nacala")
moz.s.roster.sf$rost_dist_titl <- str_replace(moz.s.roster.sf$rost_dist_titl, "Nacala - Velha", "Nacala-A-Velha")
moz.s.roster.sf$rost_dist_titl <- str_replace(moz.s.roster.sf$rost_dist_titl, "Namapa - Erati", "Erati")
moz.s.roster.sf$rost_dist_titl <- str_replace(moz.s.roster.sf$rost_dist_titl, "Nampula - Distrito", "Nampula")
moz.s.roster.sf$rost_dist_titl <- str_replace(moz.s.roster.sf$rost_dist_titl, "Pemba - Metuge", "Pemba")
moz.s.roster.sf$rost_dist_titl <- str_replace(moz.s.roster.sf$rost_dist_titl, "Xai-Xai Distrito", "Xai-xai")
moz.s.roster.sf$rost_dist_titl <- str_replace(moz.s.roster.sf$rost_dist_titl, "Cidade Da Maxixe", "Maxixe")

#### There are a lot of non-matching obs with ones that start with "municipal": looking at the world bank 
#### polygons, we can infer that all o these belong in th district of "Cidade de Maputo" because  every single
#### string that beings with "municpal" is listed in the roster with the "region" of "Cidade de Maputo", and this
#### is in fact a district with the same name according to the Wold Bank poly 

#### replace districts that start with Municipal with Cidade de Maputo
moz.s.roster.sf$rost_dist_titl <- str_replace_all(moz.s.roster.sf$rost_dist_titl,"^Municipal.+", "Cidade de Maputo")






#### collapse and re-add for same named districts 
moz.s.roster.sum <- moz.s.roster.sf %>%
  group_by(rost_dist_titl) %>%
  summarise(
    dist_n_stud    = sum(n_students, na.rm = TRUE), # this will cause all other districts to show 0 when really NA
    ln_dist_n_stud = if_else(dist_n_stud > 0, log(dist_n_stud), 0),
    n_schools      = n(),
    med_stud_school= median(n_students)
    ) 

#### replace 0 values with NA
#moz.s.roster.sum$dist_n_stud <- na_if(moz.s.roster.sum$dist_n_stud, 0)


### Merge to wb poly
moz.s.roster.sum <-
  stringdist_left_join(moz.s.roster.sum, moz.wb.poly, by = c("rost_dist_titl" = "ADM2_NAME"), max_dist = 1) 

#### export to csv, will reimport the removed rows
moz.s.roster.sum %>%
  select(rost_dist_titl, ADM2_NAME, ADM2_CODE) %>%
  write_csv(path = file.path(vault,
                             "enrollment/moz-district-matches.csv"))

#### import from csv, removed when drop == 1 
moz.s.roster.fltr <-
  read_csv(file = file.path(vault, "enrollment/moz-district-matches-in.csv")) %>%
  filter(is.na(drop) == FALSE)

#### filter our dropped obs 
moz.s.roster.sum <- moz.s.roster.sum %>%
  anti_join(moz.s.roster.fltr, by = c("rost_dist_titl", "ADM2_NAME", "ADM2_CODE")) %>%
  select(rost_dist_titl, dist_n_stud, ln_dist_n_stud, n_schools, med_stud_school, 
         g0, g1, g2, ADM2_CODE, geometry) %>%
  st_as_sf()

### assert that the incoming rost_dist_title is unique/not duplicated
assert_that(n_distinct(moz.s.roster.sum$rost_dist_titl) == nrow(moz.s.roster.sum))




# Append all country objects 
by.dist.enrollment <- bind_rows(moz.s.roster.sum, rwa.s.roster.sum, per.s.roster.sum, jor.s.roster.sum) %>%
  select(-rost_dist_titl)


                        
                        
                        # ----------------------------- #
                        #            Export	      ----
                        # ----------------------------- #
if (export == 1) {

# save Rdata
save(jor.s.roster, rwa.s.roster, moz.s.roster, per.s.roster,
     by.dist.enrollment,
     file = file.path(root, "main/enrollment.Rdata"))

# export as dta
## remove geometry
by.dist.enrollment %>%
  st_drop_geometry() %>%
  write_dta(
          path = file.path(repo.encrypt, "main/by-district-enrollment.dta"),
          version = 14
 )


}