imprtjson# Mdataset.R
# Author: Tom
# appends all schools datasets and all public officials dataset (raw), performs basic
# 	cleaning, and does geoprocessing on gps coordinates to determine admin unit, distances etc


					# ----------------------------- #
					# 			 startup	 		#----
					# ----------------------------- #

if (!is.element("pacman", installed.packages())) {
    install.packages("pacman", dep= T)
  }

pacman::p_load(tidyverse,
       readstata13,
       sf,
       assertthat,
       rio,
       haven,
       sjlabelled)


					# ----------------------------- #
					# 			 settings	 		#----
					# ----------------------------- #

user <- 1
# where 1 == Tom
# 		2 == Robert


# shared data folder



# user settings
if (user == 1) {
root  <- file.path("A:") #
vault <- file.path(root, "Countries")
shared <- "C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/global-edu-dashboard/code-review"
wbpoly <- file.path(shared, "gis/20160921_GAUL_GeoJSON_TopoJSON")
}

if (user == 2) {
root  <- file.path("") # <- insert file path here if you want to copy the files locally.
vault <- file.path(root, "Countries")
shared <- "C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/global-edu-dashboard/code-review"
  # replace with where you put the 'code-review' folder if you decide to run locally.
}




# code settings (for review, default values are: appendskip=1 	imprtjson=1		savepoly=2)
				# to skip import of the raw json file, run: appendskip=1 	imprtjson=2		savepoly=2

appendskip <- 1 # 1 if we want to skip creation of real, pii dataset and use the sample dataset instead.
                # will also output files to shared folder instead.
imprtjson <- 1 # 1 = import the raw geojson file for the worldbank polys (takes ~10 min)
				# 0 = import the saved file on tom's local folder to skip the import
				# 2 = import the saved file on the shared folder to skip this.
savepoly  <- 2 # 1 = save the polygon file to Tom's wb folder for later use.
				# 2 = save the file to the shared folder, should be run with imprtjson == 2 if you
						# want to import the file that you save in the shared folder.





                      # ----------------------------- #
                      # Load+append schools datasets  #----
                      # ----------------------------- #

if (appendskip != 1) { 		# note that the reviewer won't be reviewing this section as it has pii and will be
							# superceded by importing the fake data below in line ~197.

# load each country's GDP data
peru_gdp <- import(file.path(vault,
	"Peru/Data/Full_Data/school_indicators_data.RData"),
	which = "school_gdp")

jordan_gdp <- import(file.path(vault,
	"Jordan/Data/Full_Data/school_indicators_data.RData"),
	which = "school_gdp")

# note there is no moz GDP yet

rwanda_gdp <- import(file.path(vault,
	"Rwanda/Data/Full_Data/school_indicators_data.RData"),
	which = "school_gdp")

# Peru
peru_school <- import(file.path(vault,
                     "Peru/Data/Full_Data/school_indicators_data.RData"),
                    which = "school_dta_short")
peru_school <- left_join(peru_school, peru_gdp, by = "school_code") # should keep all obs in main

# Jordan
jordan_school <- import(file.path(vault,
                               "Jordan/Data/Full_Data/school_indicators_data.RData"),
                     which = "school_dta_short")
jordan_school <- left_join(jordan_school, jordan_gdp, by = "school_code") # should keep all obs in main


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
rwanda_school <- left_join(rwanda_school, rwanda_gdp, by = "school_code") %>% # should keep all obs in main
                select(-(c("total_enrolled.x", "total_enrolled.y")))


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

} # end appendskip switch





# load fake dataset if appendskip switch == 1
if (appendskip == 1) {

	# load public official dataset
	m.po <- read.csv(file.path(shared,
	                           "sample-data/sample-po.csv"),
	                 header = TRUE
	                 )

	# convert factors
	newtiers <- c("MinEDU Central",
	              "Region Office",
	              "District Office")
	m.po$govt_tier <- factor(m.po$govt_tier,
	                         levels = c(1, 2, 3),
	                         labels = newtiers,
	                         ordered = TRUE)



	# load school dataset
	m.school <- read.csv(file.path(shared,
	                           "sample-data/sample-schools.csv"),
	                     header = TRUE) %>%
	  rename("countryname" = "countryname")

}


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


# save as main datasets (only if we are running the real data. Reviewer's code will not run this)
if (appendskip != 1) {

saveRDS(m.school,
        file = file.path(root, "main/m-school.Rda"))
saveRDS(m.po,
        file = file.path(root, "main/m-po.Rda"))
}


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
					# this takes a long time and is saved as Rda, if imprtjson ==0, will import rda.
					# however, I'm having the reviewer import the raw geojson file because this code
					# is an important step. (sorry!)
					# however, i've made a switch you adjust in the introduction up top where, after you run
					# or check the code once, you can save an rda file and reimport it to save time when
					# running the code again.

if (imprtjson == 1) {

wb.poly <- st_read(file.path(shared, "gis/g2015_2014_2.geojson")) %>%
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
if (savepoly == 1) {
saveRDS(wb.poly.m,
        file = file.path(root, "main/wb-poly-m.Rda"))
}
if (savepoly == 2) {
saveRDS(wb.poly.m,
        file = file.path(shared, "out/wb-poly-m.Rda"))
}


} # end imprtjson switch

if (imprtjson == 0) {
  wb.poly.m <- readRDS(file.path(root, "main/wb-poly-m.Rda"))
}
if (imprtjson == 2) {
  wb.poly.m <- readRDS(file.path(shared, "out/wb-poly-m.Rda"))
}

                            # ------------------------------------- #
                            #   spatial join with main dataset      # ----
                            # ------------------------------------- #
					# uses st_join to match mother dataset obs to geographic
					# location based on gps

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


# Join by District, remove geometry, then region, remove geometry.
school_dist<-left_join(main_school_data, # 1. join join by district
            as.data.frame(districtoffices),
            by = "ADM2_CODE",
            suffix = c(".school", ".do")) %>%
  select(idschool, idoffice, everything()) %>%
  mutate(
    dist_to_do = st_distance(geometry.school,
                       geometry.do,
                       by_element = TRUE)/1000 # we know that the pairwise elements are correct, in km
    ) %>%
  rename(district_idoffice = idoffice) %>%  # rename office id to district
  left_join(                                # 2. begin joining by region.
            as.data.frame(regionoffices),
            by = c("ADM1_CODE.school" = "ADM1_CODE"),
            suffix = c(".school", ".ro")) %>%
  select(idschool, idoffice, everything()) %>%
  mutate(
    dist_to_ro = st_distance(geometry.school,
                             geometry, # where geometry is the point of region since not duped
                             by_element = TRUE)/1000 # we know that the pairwise elements are correct, in km
  ) %>%
  rename(region_idoffice = idoffice, # rename variables to be consistent
         g0.ro = g0,
         g1.ro = g1,
         g2.ro = g2,
         ADM0_NAME.ro = ADM0_NAME,
         ADM1_NAME.ro = ADM1_NAME,
         ADM2_NAME.ro = ADM2_NAME,
         lon.ro = lon,
         lat.ro = lat,
         geometry.ro = geometry) %>%
	select(idschool, region_idoffice, district_idoffice, # order for reading convenience
		dist_to_ro, dist_to_do,
		everything()
	)






                              # ------------------------------------- #
                              #               export                  # ----
                              # ------------------------------------- #


if (appendskip == 1) { # save output in shared folder if appendskip ==1
  save(main_po_data, main_school_data,
       m.po, m.school,
       wb.poly.m,
       newtiers,
       offices,
       school_dist,
       file = file.path(shared, "out/final_main_data.Rdata"))
}


if (appendskip != 1) { # run only if not running in shared folder

# save as rds/stata
save(main_po_data, main_school_data,
     m.po, m.school,
     wb.poly.m,
     tiers,
     newtiers,
     offices,
     school_dist,
     file = file.path(root, "main/final_main_data.Rdata"))

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

peru_school_export <- peru_school %>%
	rename_at(.vars=varlist_to_change_s, ~str_trunc(.,30,"center", ellipsis="")) %>% # rename long vars
	select(-contains("enumerator_name")) # take out enumerator name variable



# export as dta
write_dta(data = main_po_data_export,
          path = "A:/main/final_main_po_data.dta",
          version = 14
     ) # default, leave factors as value labels, use variable name as var label


write_dta(data = main_school_data_export,
          path = "A:/main/final_main_school_data.dta",
          version = 14
) # default, leave factors as value labels, use variable name as var label

# export the peru schools
write_dta(data = peru_school_export,
          path = "A:/Countries/Peru/Data/PER_school_survey_data_short.dta",
          version = 14
) # default, leave factors as value labels, use variable name as var label

} # end appendskip switch

# # credits: https://stackoverflow.com/questions/6986657/find-duplicated-rows-based-on-2-columns-in-data-frame-in-r
# https://gis.stackexchange.com/questions/224915/extracting-data-frame-from-simple-features-object-in-r
# https://dominicroye.github.io/en/2019/calculating-the-distance-to-the-sea-in-r/
