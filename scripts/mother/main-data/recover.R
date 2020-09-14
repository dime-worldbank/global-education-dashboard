# Recover.R
# Author: Tom
# Recovers missing gps data by matching preloaded data for obs with missing coordinates to obs with gps
  # data present


  library(readr)            
              
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
  # that don't match because of mis-spellings. && replace with step 3.1 below.
  
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





# use the key to merge missing gps info back onto main datasets ----

  # here we have run into an issue where, for school observations with missing gps coordinates, the only geographic 
  # information we have is the preloaded variables. But, for some of these 'missing-gps' observations, the preloaded 
  # variable corresponds to multiple districts according to the world bank data, so there isn't an obvious match. 
  # this leaves us with a couple of options: 
  #                 1. The simplist, leave out these schools
  #                 2. Try to pick one of the multiple corresponding WB districts to map them to
  #                   2a. Use the corresponding WB district with the closest name to the preloaded variable. 

  # I will eventually set up a switch to allow us to move between options, but for now , we will default to option 1. 

  
if (matchop == 1) {
  
  
  # 3.1 recreate the key by removing the district preloads that have multiple WB entries &&
  s.key.op1 <- s.key %>%
                filter(!(school_district_preload %in% preload.dups$school_district_preload))
  
  
  # 4.1 merge gps info onto subset of 'missing-gps' places. this is now a key.
  s.key.op1 <- left_join(s.key.op1,
                          s.there,
                          by = c("countryname", "school_district_preload")) %>%
    distinct(ADM0_NAME, ADM1_NAME, ADM2_NAME, ADM0_CODE, ADM1_CODE, ADM2_CODE,
             g0, g1, g2, countryname, school_district_preload)
  
  
  # 5.1 merge the key back onto the main dataset && change _op1 to simply main_school_data
    # question is, using method 1, how many schools do we get back?
  main_school_data_op1a <- left_join(main_school_data,
                                    s.key.op1,
                                    by    = c("countryname", "school_district_preload"),
                                    suffix = c('.x', '.y')) # for missings in x, we want to overwrite with y
  
  
  ## 5.1.1 replace missings in .x if there's a non-missing in y (ie, update)
    # since we can't 'update' the geovars, we have two copies: a .x (from main dataset) and 
    # .y (from) the key we just made. for most obs, .x is correct and will be kepts, but 
    # now we have to now replace .x with .y is .x is missing and theres something in .y
  main_school_data_op1<- mutate( 
    main_school_data_op1a,
      ADM0_NAME = if_else(is.na(ADM0_NAME.x) & !is.na(ADM0_NAME.y), ADM0_NAME.y, ADM0_NAME.x),
      ADM1_NAME = if_else(is.na(ADM1_NAME.x) & !is.na(ADM1_NAME.y), ADM1_NAME.y, ADM1_NAME.x),
      ADM2_NAME = if_else(is.na(ADM2_NAME.x) & !is.na(ADM2_NAME.y), ADM2_NAME.y, ADM2_NAME.x),
      ADM0_CODE = if_else(is.na(ADM0_CODE.x) & !is.na(ADM0_CODE.y), ADM0_CODE.y, ADM0_CODE.x),
      ADM1_CODE = if_else(is.na(ADM1_CODE.x) & !is.na(ADM1_CODE.y), ADM1_CODE.y, ADM1_CODE.x),
      ADM2_CODE = if_else(is.na(ADM2_CODE.x) & !is.na(ADM2_CODE.y), ADM2_CODE.y, ADM2_CODE.x),
      g0        = if_else(is.na(g0.x)        & !is.na(g0.y)       , g0.y       , g0.x),
      g1        = if_else(is.na(g1.x)        & !is.na(g1.y)       , g1.y       , g1.x),
      g2        = if_else(is.na(g2.x)        & !is.na(g2.y)       , g2.y       , g2.x)
                                ) %>%
  select(-ADM0_NAME.x, -ADM0_NAME.y, 
         -ADM1_NAME.x, -ADM1_NAME.y,
         -ADM2_NAME.x, -ADM2_NAME.y,
         -ADM0_CODE.x, -ADM0_CODE.y,
         -ADM1_CODE.x, -ADM1_CODE.y,
         -ADM2_CODE.x, -ADM2_CODE.y,
         -g0.x,        -g0.y,
         -g1.x,        -g1.y,
         -g2.x,        -g2.y)

  
  # compare missing value rates
 remain1 <- sum(is.na(main_school_data$ADM2_NAME)) # n miss=180
 remain2 <- sum(is.na(main_school_data_op1$ADM2_NAME)) ##  n miss=148; gains 32 schools! 
}








                            # ----------------------------- #
                            # 			   manual matching	 		 ----
                            # ----------------------------- #

                  # as object `remain1` indciates we still have 148 schools that
                  # cannot be matched to the world bank poly data using either the 
                  # direct GPS method or by copying known geodata from schools in 
                  # the same district (above). The final method will be manual matching: 
                  # I will export a list of districts that remain empty of geodata and 
                  # match them to district names in the WB polygon dataset in excel, then
                  # reimport them and continue filling in missing geodata. This will be done 
                  # by hand for two reasons: 1) the number of unique districts amongst the 148 
                  # observations will be reasonably low, and 2) this avoids potential errors
                  # with string matching via programs (such as "Washington, DC, The capital" 
                  # might be matched to a much longer-named city than "Washington" in programs).

# 1. Export a list of unique country-districts of the remained 148 observations.

districts_to_match <- main_school_data_op1 %>%
  filter(is.na(ADM2_CODE) == TRUE) %>%    # take only those schools with no WB district data
  st_drop_geometry() %>%                   # remove geometry column
  distinct(countryname, school_province_preload, school_district_preload)  # make a list of unique country-districts



# # Do not run, will overwrite. 
# write.csv(districts_to_match,
#           file = file.path(repo.encrypt, "main/districts-to-match.csv"),
#           fileEncoding = "UTF-8")


wbp <- wb.poly.m %>% #searchable easily
  st_drop_geometry()




# 2. Import the manually-matched list

if (matchop == 1) {
  
manual_match_import <- read_csv(file = file.path(repo.encrypt, "main/IN-districts-to-match.csv"),
                         col_names   = TRUE
                         ) 
    # select variables
    man.key <- select(manual_match_import,
                      countryname, school_province_preload, school_district_preload,
                      district_number, 
                      region_number
                      )
    
    
    
# 3. Use the man.key to link missing districts in main dataset with wb poly info

    # 4.1 merge gps info onto subset of 'missing-gps' places. this is now a key.
    man.key <- left_join(man.key,
                           wb.poly.m,
                           by = c(
                                  "region_number"  = "ADM1_CODE",
                                  "district_number"= "ADM2_CODE"),
                           keep = TRUE)  %>% 
      # then filter out entries with missing values 
      filter(is.na(ADM1_CODE) == FALSE)  %>%
      # then keep only necessary columns 
      select(countryname, school_province_preload, school_district_preload, 
             ADM2_CODE, ADM1_CODE, ADM2_NAME, ADM1_NAME, ADM0_CODE, ADM0_NAME,
             g0, g1, g2)
  

}






# 4. Match key back to maindataset, rename columns for same-named variablbes. 

main_school_data_op1b <- left_join(main_school_data_op1,
                                   man.key,
                                   by    = c("school_district_preload"),
                                   suffix = c('.x', '.y')) # for missings in x, we want to overwrite with y
      ## %%here, there are two schools that aren't matching based on the string match: school code preload: 296012; 444869

## 4.1. replace missings in .x if there's a non-missing in y
# since we can't 'update' the geovars, we have two copies: a .x (from main dataset) and 
# .y (from) the key we just made. for most obs, .x is correct and will be kepts, but 
# now we have to now replace .x with .y is .x is missing and theres something in .y
main_school_data_op1<- mutate( 
  main_school_data_op1b,
  ADM0_NAME = if_else(is.na(ADM0_NAME.x) & !is.na(ADM0_NAME.y), ADM0_NAME.y, ADM0_NAME.x),
  ADM1_NAME = if_else(is.na(ADM1_NAME.x) & !is.na(ADM1_NAME.y), ADM1_NAME.y, ADM1_NAME.x),
  ADM2_NAME = if_else(is.na(ADM2_NAME.x) & !is.na(ADM2_NAME.y), ADM2_NAME.y, ADM2_NAME.x),
  ADM0_CODE = if_else(is.na(ADM0_CODE.x) & !is.na(ADM0_CODE.y), ADM0_CODE.y, ADM0_CODE.x),
  ADM1_CODE = if_else(is.na(ADM1_CODE.x) & !is.na(ADM1_CODE.y), ADM1_CODE.y, ADM1_CODE.x),
  ADM2_CODE = if_else(is.na(ADM2_CODE.x) & !is.na(ADM2_CODE.y), ADM2_CODE.y, ADM2_CODE.x),
  g0        = if_else(is.na(g0.x)        & !is.na(g0.y)       , g0.y       , g0.x),
  g1        = if_else(is.na(g1.x)        & !is.na(g1.y)       , g1.y       , g1.x),
  g2        = if_else(is.na(g2.x)        & !is.na(g2.y)       , g2.y       , g2.x),
  school_province_preload = if_else(is.na(school_province_preload.x) & !is.na(school_province_preload.y),
                                    school_province_preload.y, school_province_preload.x) 
) %>%
  select(-ADM0_NAME.x, -ADM0_NAME.y, 
         -ADM1_NAME.x, -ADM1_NAME.y,
         -ADM2_NAME.x, -ADM2_NAME.y,
         -ADM0_CODE.x, -ADM0_CODE.y,
         -ADM1_CODE.x, -ADM1_CODE.y,
         -ADM2_CODE.x, -ADM2_CODE.y,
         -g0.x,        -g0.y,
         -g1.x,        -g1.y,
         -g2.x,        -g2.y,
         -school_province_preload.x, 
         -school_province_preload.y)


# compare missing value rates
remain1 <- sum(is.na(main_school_data$ADM2_NAME)) # n miss=180
remain3 <- sum(is.na(main_school_data_op1$ADM2_NAME)) ##  n miss=148; gains 32 schools! 

miss <- filter(main_school_data_op1,
               is.na(ADM2_CODE) == TRUE) %>%
  st_drop_geometry()










                            # ----------------------------- #
                            # 			     file export	 		 ----
                            # ----------------------------- #

      # Here we will do 2 things: add the newly generated school datasets to the main R
      # environemtn and, also, export the main school dataset as another .dta version.


# save important contents
save(main_po_data, main_school_data,
     m.po, m.school,
     wb.poly.m,
     po.l, school.l, # new: 'light' datasets
     preload.dups, s.key, s.key.op1, s.missing, s.there, # new: 
     main_school_data_op1, # new school dataset
     tiers,
     newtiers,
     offices,
     school_dist,
     file = file.path(repo.encrypt, "main/final_main_data.Rdata"))


# export main school dataset as another version 

    #tag varsnames longer than 30 characters
    varlist_s <- as.data.frame(colnames(main_school_data_op1))
    to.change_s <- varlist_s %>%
      filter(str_length(colnames(main_school_data_op1)) > 30 )
    
    # this is the list of schools varnames to change
    varlist_to_change_s<-as.character(to.change_s$`colnames(main_school_data_op1)`)
    
    # chang the dataset accordinly 
    main_school_data_op1_export <- main_school_data_op1 %>%
      st_set_geometry(., NULL) %>% # take out geometry
      rename_at(.vars=varlist_to_change_s, ~str_trunc(.,30,"center", ellipsis="")) %>% # rename long vars
      select(-contains("enumerator_name")) # take out enumerator name variable
    
    # finally, export as dta
    write_dta(data = main_school_data_op1_export,
              path = file.path(repo.encrypt, "main/final_main_school_data_op1.dta"),
              version = 14
            )
    
    
    
    