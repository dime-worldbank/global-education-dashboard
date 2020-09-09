# Recover.R
# Author: Tom
# Recovers missing gps data by matching preloaded data for obs with missing coordinates to obs with gps
  # data present


              
              
              # ----------------------------- #
              # 			     load data	 		      ----
              # ----------------------------- #

  load(file = file.path(repo.encrypt, "main/final_main_data.Rdata"))          
              
              
              
              
              
              # ----------------------------- #
              # 	 Create short versions	 		 ----
              # ----------------------------- #      
              
        # Since many operations that will use these datasets don't require access to the
        # full data (only geoinfo), we'll make a version of the po and school main_ datasets 
        # with only important info and keys to link back to the full datastets if/when necessary.
        # note that these short/light datasets still have pii.
              
# make lists of vars to keep 
              
schoolkeyvars<-c("idschool", "school_code", "ADM0_NAME", 
              "ADM1_NAME", "ADM2_NAME", "ADM0_CODE", 
              "ADM1_CODE", "ADM2_CODE", "g0", 
              "g1", "g2", "countryname", 
              "school_name_preload", "school_address_preload", "school_province_preload", 
              "school_district_preload", "school_code_preload", "school_emis_preload", 
              "school_info_correct", "m1s0q2_name", "m1s0q2_code", 
              "m1s0q2_emis", "survey_time", "total_enrolled",
              "lat", "lon", "geometry") 

pokeyvars<-c("idpo", "interview__id", "idoffice", 
            "ADM0_NAME", "ADM1_NAME", "ADM2_NAME", 
            "ADM0_CODE", "ADM1_CODE", "ADM2_CODE", 
            "g0", "g1", "g2", 
            "countryname", "school_district_preload", "school_province_preload", 
            "region_code", "district_code", "district", 
            "province", "location", "govt_tier", 
            "enumerator_name", "enumerator_number", "survey_time", 
            "consent", "national_learning_goals", 
            "lat", "lon", "geometry")



# shorten the datasets 

po.l <- select(main_po_data, 
               pokeyvars)

school.l <- select(main_school_data,
                   all_of(schoolkeyvars))







              # ----------------------------- #
              # 	 Replace missing gps info	 	 ----
              # ----------------------------- #      
      # The reality is that some schools do not have gps information in the raw data, which 
      # means essentially that they are dropped from all subsequent analysis. Some of these 
      # observations without gps can be recovered because if other schools that have the same 
      # preloaded region and district do have gps info, that region/district info can be copied 
      # to the observations without gps data in the same place. 


# 1. extract a dataframe of country, region, districts that do not have gps info 
s.missing <- filter(school.l,
                    is.na(ADM2_NAME) == TRUE) 





# 2. create another dataframe with only observations that do have gps info
s.there   <- filter(school.l, is.na(ADM2_NAME) == FALSE)

  assert_that(
      nrow(s.missing) +
      nrow(s.there)   
      == nrow(main_school_data) # we shouldn't loose any obs in the splitting.
    ) 
  

  

# 3. Do a semi join to keep only a subset of the 'missing-gps' locations that have matching string locations with gps info
  # Here, we only want to find the observations with missing gps values whose string versions of their locations 
  # also exist in the main dataset, with gps coordinates. we will join by countryname and school_district_preload 
  # since the assumption is that there cannot be two same-named districts in the same country. Joining also by region 
  # will likely undermatch, as not all string variables are actually preloaded, there many be same-placed districts 
  # that don't match because of mis-spellings.
  
s.key    <- semi_join(as.data.frame(s.missing), # remove geometry
                      as.data.frame(s.there),   # remove geometry
                      by = c("countryname", "school_district_preload")) %>%
            distinct(countryname, school_district_preload) # only keep one of each match


  
# 4. merge gps info onto subset of 'missing-gps' places. this is now a key.
s.key.incomplete    <- left_join(s.key,
                      s.there,
                      by = c("countryname", "school_district_preload")) %>%
            distinct(ADM0_NAME, ADM1_NAME, ADM2_NAME, ADM0_CODE, ADM1_CODE, ADM2_CODE,
                     g0, g1, g2, countryname, school_district_preload)

# explore duplicates 
  # this object here will tell us how many cases of district preloaded variables find multiple
  # entries in the gps/wb data (the number of rows for school_district_preload),
  # and how many different entries in the gps/wb data there are (n)
preload.dups <-
  group_by(s.key.incomplete,
           school_district_preload) %>%
  summarise(n = n()) %>%
  filter(n > 1)





# 5. use the key to merge missing gps info back onto main datasets.

  # here we have run into an issue where, for school observations with missing gps coordinates, the only geographic 
  # information we have is the preloaded variables. But, for some of these 'missing-gps' observations, the preloaded 
  # variable corresponds to multiple districts according to the world bank data, so there isn't an obvious match. 
  # this leaves us with a couple of options: 
  #                 1. The simplist, leave out these schools
  #                 2. Try to pick one of the multiple corresponding WB districts to map them to
  #                   2a. Use the corresponding WB district with the closest name to the preloaded variable. 

  # I will eventually set up a switch to allow us to move between options, but for now , we will default to option 1. 

  
if (matchop == 1) {
  
  
  # 3.1 recreate the key by removing the district preloads that have multiple WB entries
  s.key.op1 <- s.key %>%
                filter(!(school_district_preload %in% preload.dups$school_district_preload))
  
  
  # 4.1 merge gps info onto subset of 'missing-gps' places. this is now a key.
  s.key.op1 <- left_join(s.key.op1,
                          s.there,
                          by = c("countryname", "school_district_preload")) %>%
    distinct(ADM0_NAME, ADM1_NAME, ADM2_NAME, ADM0_CODE, ADM1_CODE, ADM2_CODE,
             g0, g1, g2, countryname, school_district_preload)
  
  
  # 5.1 merge the key back onto the main dataset 
    # %% here we have to figure out how to replace the missing values instead of creating a new row.
    # question is, using method 1, how many schools do we get back?
  main_school_data_op1 <- left_join(main_school_data,
                                    s.key.op1,
                                    key = c("countryname", "school_district_preload"))

  
}
