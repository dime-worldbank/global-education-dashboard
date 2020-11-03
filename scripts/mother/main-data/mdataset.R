# Mdataset.R
# Author: Tom
# appends all schools datasets and all public officials dataset (raw), performs basic
# 	cleaning, and does geoprocessing on gps coordinates to determine admin unit, distances etc
# 
# Note: this script assumes that you have run MAIN.R



                      # ----------------------------- #
                      # Load+append schools datasets  #----
                      # ----------------------------- #
                 # At this point we will also merge the enrollment info by
                 # using school code. since, for some schools, the roster/
                 # enrollment object has GPS coordinates for the schools, 
                 # we will rename this imported lat/long from rost_lat to 
                 # simply lat, and rename the survey-generated lat/lon 
                 # to 'survey_lat'. We will use the roster lat/lon as the 
                 # official coordinates as the data is more complete. We also 
                 # want to drop the variable n_students because this variable 
                 # is already loaded elsewhere in the survey data and the 
                 # n_students variable is really only useful for calculating 
                 # district-wide student enrollment. 

# load the enrollment data 
load(file = file.path(root, "main/enrollment.Rdata"))                      
                                  

# load each country's GDP data, except for MOZ which doesn't exist yet
peru_gdp <- import(file.path(vault,
	"Peru/Data/Full_Data/school_indicators_data.RData"),
	which = "school_gdp")

jordan_gdp <- import(file.path(vault,
	"Jordan/Data/Full_Data/school_indicators_data.RData"),
	which = "school_gdp")

rwanda_gdp <- import(file.path(vault,
	"Rwanda/Data/Full_Data/school_indicators_data.RData"),
	which = "school_gdp")

# Peru
peru_school <- import(file.path(vault,
                     "Peru/Data/Full_Data/school_indicators_data.RData"),
                    which = "school_dta_short")

peru_school <- peru_school %>%
  left_join(peru_gdp,     by = "school_code") %>%
  rename(survey_lat = lat, survey_lon = lon) %>%
  left_join(per.s.roster, by = c("school_code" = "rost_id1")) %>%
  rename(lat = rost_lat, lon = rost_lon) %>%
  mutate(total_enrolled = coalesce(total_enrolled, n_students)) %>%
  select(-n_students, -countryname) 
  



# Jordan
jordan_school <- import(file.path(vault,
                               "Jordan/Data/Full_Data/school_indicators_data.RData"),
                     which = "school_dta_short")

jordan_school <- jordan_school %>% 
  left_join(jordan_gdp, by = "school_code") %>%
  rename(survey_lat = lat, survey_lon = lon) %>%
  left_join(jor.s.roster, by = c("school_code" = "rost_id1")) %>%
  rename(lat = rost_lat, lon = rost_lon) %>%
  mutate(total_enrolled = coalesce(total_enrolled, n_students)) %>%
  select(-n_students, -countryname)
  

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

mozambique_school <- mozambique_school %>%  # not rename lat/long because we'll use survey lat/lon
  left_join(moz.s.roster, by = c("school_code" = "rost_id1"), keep = TRUE) %>% # rost_id1 is def matching id
  select(-countryname, -rost_district, -rost_province,
         -rost_id1, -rost_id2, -rost_id3) %>%
  rename(total_enrolled = n_students)  # pull enrollment data from the roster, as its not in survey,
  



# Rwanda
rwanda_school <- import(file.path(vault,
                               "Rwanda/Data/Full_Data/school_indicators_data.RData"),
                     which = "school_dta_short")

rwanda_school <- rwanda_school %>%
  left_join(rwanda_gdp, by = "school_code") %>% 
  select(-total_enrolled.y) %>% # remove this variable, (use the variable from the surey), leave lat/lon
  rename(total_enrolled = total_enrolled.x) %>%
  left_join(rwa.s.roster, by = "school_code") %>%
  mutate(total_enrolled = coalesce(total_enrolled, n_students)) %>%
  select(-n_students, -countryname)
  


# bind rows
m.school <- bind_rows("Peru" = peru_school,
                      "Jordan" = jordan_school,
                      "Rwanda" = rwanda_school,
                      "Mozambique" = mozambique_school,
                      .id = "countryname") %>%
            mutate(.,
						  ln_gdp = log(GDP)  # create log GDP
					  ) %>%
  rename(gdp = GDP)








                        # ----------------------------- #
                        # Load+append officials datasets#----
                        # ----------------------------- #

tiers <- c("Ministry of Education (or equivalent)",
           "Regional office (or equivalent)",
           "District office (or equivalent)")
newtiers <- c("MinEDU Central",
              "Region Office",
              "District Office")

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
      #                          factor()


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


# check the observation number is correct 
assert_that(nrow(m.school) == ns )
assert_that(nrow(m.po)     == npo)
                        





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
# I don't really know how to do this well in R, I want to create a random id
# for each office (office_preload) but there are multiple observations with
# the same office id, so I did this by collapsing the office IDs so that each
# row is a unique id, randomized, then merged back to the main dataset, but I'm
# sure there's a better way to do this.

of <- select(m.po, office_preload) %>% # create a subselection of offices
  group_by(office_preload) %>%
  summarise()

set.seed(417) # create random id
of$idoffice <- runif(length(of$office_preload)) %>%
					rank()

# replace missing values with office id == NA
of <- mutate(of,
    idoffice = ifelse(is.na(office_preload), NA, idoffice),
    idoffice = ifelse(office_preload == "", NA, idoffice)
  )


m.po <- left_join(m.po, of, by = "office_preload") # merge id back to full po dataset



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
					# this takes a long time and is saved as Rda, if imprtjson == 1, will import rda.
					# if imprtjson == 1, then the import of the raw geojson files will happen and the 
					# random geoids for g1 g2 and g3 will be generated. Setting imprtjson == 1 will skip
					# the creation of the wb.poly.m/skip the creation of g1, g2, g3 and simply import 
					# wb.poly.m that was previously generated. 


load(file.path(root, "main/wbpolydata.Rdata"))






                            # ------------------------------------- #
                            #   spatial join with main dataset      # ----
                            # ------------------------------------- #
					# uses st_join to match mother dataset obs to geographic
					# location based on gps
					# where do I put the part where I change the values for ADM-2 for RWA? (substitute ) (or not substitute?)

# convert po + school dataset to sf objects
po <- st_as_sf(m.po,
               coords = c("lon", "lat"), # set geometry/point column first
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

    
# set the variable order
order <- c("ADM0_NAME", "ADM1_NAME", "ADM2_NAME",
           "ADM0_CODE", "ADM1_CODE", "ADM2_CODE",
           "g0", "g1", "g2")


# join poly and po datasets  
main_po_data <- st_join(po, # points
                        wb.poly.m) %>% #polys
                left_join(m.po.gps, # join back to gps coords for reference
                          by = c("interview__id", "countryname")
                          ) %>%
                select(idpo, interview__id, idoffice, order, everything())


# join poly and school datasets
main_school_data <- st_join(school, # points
                            wb.poly.m) %>% #polys
                    left_join(m.school.gps, # join back to gps coords for reference
                              by = c("school_code", "countryname")
                    ) %>%
                    select(idschool, school_code, order, everything())







						                # ------------------------------------- #
                            #   	Additional Geoprocessing	        # ----
                            # ------------------------------------- #

# distance of each school to associated district and regional office.
	# Since each school is situated within a district and region, we want
	# to know the 'linear' distance from that school to the office in its district
	# office and its regional office (ie only for the single district and single region
	# office for each school.) since we already have joined the geographic ids to the
  # schools and public officials, we can just link the two datasets by their ADM2/ADM1
  # ids to find out which schools and offices are in the same district/region.


# assert that there is only 1 distinct value of govt tier for each office.
t <- group_by(main_po_data, idoffice) %>%
  summarize(
    unique = n_distinct(govt_tier)
  )
  # assert_that(max(t$unique == 1)) # I cant figure out how to make this assertion return
  # a logical value. I want to say that this variable 'uniuqe' is only ever == 1.

# check that there there is only 1 location for each officeid
l <- group_by(main_po_data, idoffice) %>%
  summarize(
    unique = n_distinct(ADM2_CODE)
  )


# create an office dictionary, where each obs is a unique officeid
offices <- group_by(main_po_data, idoffice) %>%
  summarise(ADM0_CODE = mean(ADM0_CODE),
            ADM1_CODE = mean(ADM1_CODE),
            ADM2_CODE = mean(ADM2_CODE),
            govt_tier = first(govt_tier), # this is a big assumption and is wrong on ~4 occasions.
            g0        = mean(g0),
            g1        = mean(g1),
            g2        = mean(g2),
            ADM0_NAME = first(ADM0_NAME),
            ADM1_NAME = first(ADM1_NAME),
            ADM2_NAME = first(ADM2_NAME),
            lon       = first(lon), # also wrong on only ~4 occasions but still wrong.
            lat       = first(lat)
            )      # now remove sf object/convert geometry to lat lon vars

regionoffices <- filter(offices, govt_tier == "Region Office",
                                is.na(ADM1_CODE) == FALSE)

districtoffices <- filter(offices, govt_tier == "District Office",
                                    is.na(ADM2_CODE) == FALSE)




                      
                      # ------------------------------------- #
                      #    Calculate distrances to offices    # ----
                      # ------------------------------------- #

          # %% for future: fix code, should be done after recover anyway.

# # Join by District, remove geometry, then region, remove geometry. 
# school.id <- select(main_school_data,
#                     
# 
# school_dist<-left_join(main_school_data, # 1. join join by district
#                       as.data.frame(districtoffices),
#                       by = "ADM2_CODE",
#                       suffix = c(".school", ".do")) %>%
#   select(idschool, idoffice, everything()) %>%
#   mutate(
#     dist_to_do = st_distance(geometry.school,
#                        geometry.do,
#                        by_element = TRUE)/1000 # we know that the pairwise elements are correct, in km
#     ) 
# 
# #rename 
# rename(.data = school_dist,
#        district_idoffice = idoffice)  # rename office id to district
# 
# # left join
# school_dist <- left_join(school_dist ,                              # 2. begin joining by region.
#                         as.data.frame(regionoffices),
#                         by = c("ADM1_CODE.school" = "ADM1_CODE"),
#                         suffix = c(".school", ".ro")) %>%
#   select(idschool, idoffice, everything()) %>%
#   mutate(
#     dist_to_ro = st_distance(geometry.school,
#                              geometry, # where geometry is the point of region since not duped
#                              by_element = TRUE)/1000 # we know that the pairwise elements are correct, in km
#   ) 
# 
# # rename + select 
# school_dist<- rename(school_dist,
#          region_idoffice = idoffice, # rename variables to be consistent
#          g0.ro = g0,
#          g1.ro = g1,
#          g2.ro = g2,
#          ADM0_NAME.ro = ADM0_NAME,
#          ADM1_NAME.ro = ADM1_NAME,
#          ADM2_NAME.ro = ADM2_NAME,
#          lon.ro = lon,
#          lat.ro = lat,
#          geometry.ro = geometry) %>%
# 	select(idschool, region_idoffice, district_idoffice, # order for reading convenience
# 		dist_to_ro, dist_to_do,
# 		everything()
# 	)



                              
                       # ------------------------------------- #
                      #    Create "match" variable            # ----
                      # ------------------------------------- #

        # we want to know from the onset how many schools are in districts with public officials, and
        # how many public officials are in districts with schools. So what we will do is extract a 
        # vector of unique ADM2 (district) codes for schools and public officials. Then, in the opposite 
        # dataset, we will create a "match" variable that indicates true for if the observation is in the 
        # same district as any other observation. 
        # 
        # %% note, this may have to be replaced with g2, not ADM2_CODE


# Extract a vector of unique ADM2 codes for schools, exclude NA values 
li.school.ad2codes = unique(main_school_data$ADM2_CODE[!is.na(main_school_data$ADM2_CODE)]) # district
li.school.ad1codes = unique(main_school_data$ADM1_CODE[!is.na(main_school_data$ADM1_CODE)]) # region


# Extract a vector of unique ADM2 Codes for the public officials, exclude NA values 
li.po.ad2codes = unique(main_po_data$ADM2_CODE[!is.na(main_po_data$ADM2_CODE)]) # district
li.po.ad1codes = unique(main_po_data$ADM1_CODE[!is.na(main_po_data$ADM1_CODE)]) # region
    
    # make the same list using only district level officials
    main_po_data.t3 <- filter(main_po_data, govt_tier == "District Office")
    
      li.po.t3.ad2codes = unique(main_po_data.t3$ADM2_CODE[!is.na(main_po_data.t3$ADM2_CODE)]) # district
    #  rm(main_po_data.t3)


# make a boolean variable for schools if that obs's adm2 code matches any code from the public official's vector
main_school_data$match_dist_po   <- main_school_data$ADM2_CODE %in% li.po.ad2codes # district
main_school_data$match_region_po <- main_school_data$ADM1_CODE %in% li.po.ad1codes # region
main_school_data$match_dist_pot3 <- main_school_data$ADM2_CODE %in% li.po.t3.ad2codes # district, matching only tier 3 po's

# make a boolean variable for public officials if that obs's adm2 code matches any code from the school's vector
main_po_data$match_dist_school   <- main_po_data$ADM2_CODE %in% li.school.ad2codes # district
main_po_data$match_region_school <- main_po_data$ADM1_CODE %in% li.school.ad1codes # region
main_po_data.t3$match_dist_school<- main_po_data.t3$ADM2_CODE %in% li.school.ad2codes # district, matching only tier 3








                              # ------------------------------------- #
                              #    replace missing "total_enrolled    # ----
                              # ------------------------------------- #
                         # some schools do not have enrollment data, so we will replace 
                         # that school enrollment with the median enrollment in that' 
                         # school's district. If this value is also 0, then we will replace 
                         # the missing with the country median (this is only the case for
                         # Mozambique)
                         # 
                         # 
                         # This may %% also have to be changed o g2 but should be ok because it's moz
# create country median of rmozambique.
med.moz <- median(moz.s.roster$n_students)


# restrict to simiply coalescing. 
by.dist.enrollment.short <- select(by.dist.enrollment, ADM2_CODE, med_stud_school, geometry) %>%
  st_drop_geometry()


# replace values
main_school_data <-
  left_join(
    main_school_data, 
    by.dist.enrollment.short,
    by = "ADM2_CODE",
    keep = FALSE) %>%
  mutate(
    total_enrolled_colsc = coalesce(total_enrolled, med_stud_school),
    total_enrolled3 = if_else( is.na(total_enrolled_colsc) == TRUE & countryname == "Mozambique",
                               med.moz, total_enrolled_colsc)
  ) %>% 
  rename(total_enrolled_old  = total_enrolled) %>%
  rename(total_enrolled      = total_enrolled3) %>%
  select(-total_enrolled_colsc, -total_enrolled_old)




     
# check that there are no missing values for total enrolled
 assert_that( sum(is.na(main_school_data$total_enrolled)) == 0)
 
 



                              # ------------------------------------- #
                              #               export                   ----
                              # ------------------------------------- #
if (export == 1) {

# save as rdata
save(main_po_data, main_school_data,
     m.po, m.school,
     wb.poly.m,
     tiers,
     newtiers,
     offices,
     file = file.path(repo.encrypt, "main/final_main_data.Rdata"))

#determine lists of vars to change length
  
  # tag all varsnames longer than 26 characters
varlist_p <- as.data.frame(colnames(main_po_data))
to.change_p <- varlist_p %>%
  filter(str_length(colnames(main_po_data)) > 26 )

  # this list is the public officials list of varnames to change
  varlist_to_change_p<-as.character(to.change_p$`colnames(main_po_data)`)

  
  #tag varsnames longer than 30 characters
varlist_s <- as.data.frame(colnames(main_school_data))
to.change_s <- varlist_s %>%
  filter(str_length(colnames(main_school_data)) > 30 )
  
# this is the list of schools varnames to change
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

peru_school_export <- peru_school %>%
	rename_at(.vars=varlist_to_change_s, ~str_trunc(.,30,"center", ellipsis="")) %>% # rename long vars
	select(-contains("enumerator_name")) # take out enumerator name variable



# export as dta
write_dta(data = main_po_data_export,
          path = file.path(repo.encrypt, "main/final_main_po_data.dta"),
          version = 14
     ) # default, leave factors as value labels, use variable name as var label


write_dta(data = main_school_data_export,
          path = file.path(repo.encrypt, "main/final_main_school_data.dta"),
          version = 14
) # default, leave factors as value labels, use variable name as var label

# export the peru schools
write_dta(data = peru_school_export,
          path = "A:/Countries/Peru/Data/PER_school_survey_data_short.dta",
          version = 14
) # default, leave factors as value labels, use variable name as var label

} # end export switch 

# # credits: https://stackoverflow.com/questions/6986657/find-duplicated-rows-based-on-2-columns-in-data-frame-in-r
# https://gis.stackexchange.com/questions/224915/extracting-data-frame-from-simple-features-object-in-r
# https://dominicroye.github.io/en/2019/calculating-the-distance-to-the-sea-in-r/

