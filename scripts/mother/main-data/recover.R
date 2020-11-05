# Recover.R
# Author: Tom
# Recovers missing gps data by matching preloaded data for obs with missing coordinates to obs with gps
  # data present


  library(readr)


  # export settings
  export     <- 1     # set to 1 to export, any other number will not export
  csv.export <- 0     # set to 1 to export csv to manually match, will overwrite



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
              "school_district_preload",
              "geometry")

pokeyvars<-c("idpo", "interview__id", "idoffice",
            "ADM0_NAME", "ADM1_NAME", "ADM2_NAME",
            "ADM0_CODE", "ADM1_CODE", "ADM2_CODE",
            "g0", "g1", "g2",
            "countryname", "school_district_preload", "school_province_preload",
            "region_code", "district_code", "district",
            "province", "location", "govt_tier",
            "enumerator_name", "enumerator_number", "survey_time",
            "consent", "national_learning_goals",
            "geometry")



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
      #
      # What will happen is I will take the full list of district names and crate a sorting hat
      # key that will tell us if schools in this district can be cleanly mapped onto existing wb
      # poly data by string value of the district name or if they have to be matched manually.
      # The criteria for being in the 'good' half of the sorting hat is that your school's district
      # mathces once and only once to a district in the wb data. If you're school's preloaded
      # district does not match at all to any wb district by string, or if it matches to multiple entries
      # then you will be in the 'bad' column and we have to match you by hand.
      #


# 1. extract a dataframe of country, region, districts that do not have gps info ----
s.missing <- filter(school.l,
                    is.na(ADM2_NAME) == TRUE)




# 2. create another dataframe with only observations that do have gps info----
s.there   <- filter(school.l, is.na(ADM2_NAME) == FALSE)

  assert_that(
      nrow(s.missing) +
      nrow(s.there)
      == nrow(main_school_data) # we shouldn't loose any obs in the splitting.
    )



# 3. create a unique list of districts in the missing dataset ----
miss.district <- distinct(as.data.frame(s.missing),
                          countryname, school_district_preload)



# 4. generate a variable that is "yes/no", default to 'no'----
miss.district$match <- FALSE



# 5. make a list of districts that can be matched internally only once, change the key to yes----

## use full join to list out all the possible match iterations
fulljoin <-  full_join(miss.district, s.there,
              by = c("countryname",
                     "school_district_preload"),
              na_matches = 'never',
              keep = TRUE,
              suffix = c(".miss", ".there"))


## find districts where each group of string district matches only leads to 1 unique answer in wb poly data
unique.matches <- fulljoin %>% # start with fulljoin that we just made
              filter(is.na(ADM2_CODE) == FALSE) %>% # take out the 'non' matches
              group_by(countryname.miss, school_district_preload.miss) %>%
              summarize(
               nuniq = n_distinct(ADM2_CODE)) %>% # generate nuniq to tell us how many wb poly values match to district
              filter(nuniq == 1)   # take only the districts that have one unique match
              # rename school_district_preload.miss ?


## change miss.district$match to TRUE if the district is in school_district_preload.miss
miss.district$match[miss.district$school_district_preload
                    %in%
                      unique.matches$school_district_preload.miss] <- TRUE


## create sorting hat object (will act as filter)
sorting.hat <- miss.district



# 6. split the missing dataset using the sorting hat----
## here we 'sort out' the districts that have a unique, direct match internally
## in the dataset (miss.copy) vs those that must be matched manually (miss.manual)

## this is the subset that we will copy from the internal data
miss.copy <- left_join(s.missing,
                       sorting.hat,
                       by = c("countryname", "school_district_preload")) %>%
             filter(match == TRUE) %>%
             st_drop_geometry()


## this is the subset that we will will match manually
miss.manual <- left_join(s.missing,
                         sorting.hat,
                         by = c("countryname", "school_district_preload")) %>%
                filter(match == FALSE) %>%
                st_drop_geometry()


## check that we didn't loose any obs in the process
assert_that(
  nrow(miss.copy) +
  nrow(miss.manual)
  == nrow(s.missing) # we shouldn't loose any obs in the splitting.
)



# 7. match the "yes" subset by string match with s.there----

## match/merge
miss.copy <- left_join(miss.copy,
                       s.there,
                       by = c("countryname", "school_district_preload"),
                       suffix = c(".x", ".y"))


## make a unique list: there should only be one ADM2 code for each school code
miss.copy <- distinct(miss.copy,
               school_code.x,
               ADM0_NAME.y, ADM1_NAME.y, ADM2_NAME.y,
               ADM0_CODE.y, ADM1_CODE.y, ADM2_CODE.y,
               g0.y, g1.y, g2.y,
               school_district_preload, countryname) %>%
            rename(
                school_code = school_code.x,
                ADM0_NAME = ADM0_NAME.y,
                ADM1_NAME = ADM1_NAME.y,
                ADM2_NAME = ADM2_NAME.y,
                ADM0_CODE = ADM0_CODE.y,
                ADM1_CODE = ADM1_CODE.y,
                ADM2_CODE = ADM2_CODE.y,
                g0        = g0.y,
                g1        = g1.y,
                g2        = g2.y
            )



# 8. match the 'no' subset by hand (export to csv, edit, then re-import) ----
#
# NOTE: in this section keep in mind that 'school_code' variable is not the
# randomly generated variable; school_code is a stable variable that does not
# change every time the code is run, so matching on this variable should never
# be a problem.

## export to csv, only export key info
if (csv.export == 1) {
# miss.manual %>%
#   select(school_code, countryname, school_province_preload, school_district_preload) %>%
#   write.csv(file = file.path(repo.encrypt, "main/match/schools-to-match.csv")
#             )

  } # end csv switch

## Import the CSV, select all relevant vars
miss.manual.key <-
  read.csv(file = file.path(repo.encrypt, "main/match/IN-schools-to-match.csv"),
                            encoding = "UTF-8") %>%
  select(.,
         school_code, countryname, school_province_preload, school_district_preload,
         trans_region, trans_district,
         District.number, Region.number, note)



## create a short version of the key
miss.manual.key.short <-
  select(miss.manual.key,
         school_code, countryname,
         District.number, Region.number)



## run a quick id check
#assert_that(nrow(wb.poly.2)             == n_distinct(wb.poly.2$ADM2_CODE)) # not needed?
assert_that(nrow(miss.manual)           == n_distinct(miss.manual$school_code))
assert_that(nrow(miss.manual.key.short) == n_distinct(miss.manual.key.short$school_code))



## Match miss.manual to csv imported, match by school code and country
miss.manual <- left_join(miss.manual,
                         miss.manual.key.short,
                         by = c("school_code", 'countryname')) %>%
               select(school_code, countryname, District.number, Region.number,
                      school_district_preload, countryname)



## use district code merge miss.manual to wb poly to recover all geoinfo
miss.manual <-
  left_join(
	  miss.manual,
	  wb.poly.dm, # merge to decision-making df
      by = c("District.number" = "ADM2_CODE"),
      keep = TRUE) %>%
  select(names(miss.copy))





# 9. append the 'yes' and 'no' subsets together with new/none geoinfo ----

## append
miss.filledin <- bind_rows(miss.copy, miss.manual )


## assert that the number of rows didn't change between beginning and end
assert_that(nrow(s.missing) == nrow(miss.filledin))




# 10.merge the appended file back onto the main school data, replace same-named info.   ----

## merge
main_school_data_mt <-
  left_join(main_school_data,
            miss.filledin,
            by = "school_code",
            suffix = c(".x", ".y")) %>%
  mutate(
      ADM0_NAME = if_else(is.na(ADM0_NAME.x) & !is.na(ADM0_NAME.y), ADM0_NAME.y, ADM0_NAME.x),
      ADM1_NAME = if_else(is.na(ADM1_NAME.x) & !is.na(ADM1_NAME.y), ADM1_NAME.y, ADM1_NAME.x),
      ADM2_NAME = if_else(is.na(ADM2_NAME.x) & !is.na(ADM2_NAME.y), ADM2_NAME.y, ADM2_NAME.x),
      ADM0_CODE = if_else(is.na(ADM0_CODE.x) & !is.na(ADM0_CODE.y), ADM0_CODE.y, ADM0_CODE.x),
      ADM1_CODE = if_else(is.na(ADM1_CODE.x) & !is.na(ADM1_CODE.y), ADM1_CODE.y, ADM1_CODE.x),
      ADM2_CODE = if_else(is.na(ADM2_CODE.x) & !is.na(ADM2_CODE.y), ADM2_CODE.y, ADM2_CODE.x),
      g0        = if_else(is.na(g0.x)        & !is.na(g0.y)       , g0.y       , g0.x),
      g1        = if_else(is.na(g1.x)        & !is.na(g1.y)       , g1.y       , g1.x),
      g2        = if_else(is.na(g2.x)        & !is.na(g2.y)       , g2.y       , g2.x)) %>%
  rename(
      countryname = countryname.x,
      school_district_preload = school_district_preload.x) %>%
  select(
     -ADM0_NAME.x, -ADM0_NAME.y,
     -ADM1_NAME.x, -ADM1_NAME.y,
     -ADM2_NAME.x, -ADM2_NAME.y,
     -ADM0_CODE.x, -ADM0_CODE.y,
     -ADM1_CODE.x, -ADM1_CODE.y,
     -ADM2_CODE.x, -ADM2_CODE.y,
     -g0.x,        -g0.y,
     -g1.x,        -g1.y,
     -g2.x,        -g2.y,
     -countryname.y,
     -school_district_preload.y)



## confirm the correct number of rows
assert_that(nrow(main_school_data) == nrow(main_school_data_mt))


## compare the number of schools with missing geo info
remain1 <- sum(is.na(main_school_data$ADM2_NAME)) # n miss=180, now 90
remain2 <- sum(is.na(main_school_data_mt$ADM2_NAME)) ##  n miss=83; now 68,

### by country
remainingmiss <- filter(main_school_data_mt,
                        is.na(ADM2_CODE) == TRUE) %>%
  group_by(countryname) %>%
  summarise(
    nmiss = n()
  )




# 11.create a new match variable

# we want to know from the onset how many schools are in districts with public officials, and
# how many public officials are in districts with schools. So what we will do is extract a
# vector of unique ADM2 (district) codes for schools and public officials. Then, in the opposite
# dataset, we will create a "match" variable that indicates true for if the observation is in the
# same district as any other observation.


## Extract a vector of unique ADM2 codes for schools, exclude NA values
li.school.ad2codes = unique(main_school_data_mt$ADM2_CODE[!is.na(main_school_data_mt$ADM2_CODE)]) # district
li.school.ad1codes = unique(main_school_data_mt$ADM1_CODE[!is.na(main_school_data_mt$ADM1_CODE)]) # region


## Extract a vector of unique ADM2 Codes for the public officials, exclude NA values
li.po.ad2codes = unique(main_po_data$ADM2_CODE[!is.na(main_po_data$ADM2_CODE)]) # district
li.po.ad1codes = unique(main_po_data$ADM1_CODE[!is.na(main_po_data$ADM1_CODE)]) # region

## make the same list using only district level officials
main_po_data.t3 <- filter(main_po_data, govt_tier == "District Office")

li.po.t3.ad2codes = unique(main_po_data.t3$ADM2_CODE[!is.na(main_po_data.t3$ADM2_CODE)]) # district
#  rm(main_po_data.t3)


## make a boolean variable for schools if that obs's adm2 code matches any code from the public official's vector
main_school_data_mt$match_dist_po   <- main_school_data_mt$ADM2_CODE %in% li.po.ad2codes # district
main_school_data_mt$match_region_po <- main_school_data_mt$ADM1_CODE %in% li.po.ad1codes # region
main_school_data_mt$match_dist_pot3 <- main_school_data_mt$ADM2_CODE %in% li.po.t3.ad2codes # district, matching only tier 3 po's
### we should get max 320 school observations when merged under these parameters


# 12.save and export. ----


if (export == 1) {



                            # ----------------------------- #
                            # 			     file export	 		  #
                            # ----------------------------- #

      # Here we will do 2 things: add the newly generated school datasets to the main R
      # environemtn and, also, export the main school dataset as another .dta version.


# save important contents
save(main_po_data, main_school_data, # original datasets
     main_school_data_mt, # matched school datasets
     m.po, m.school,
     miss.copy, miss.manual, miss.filledin, miss.manual.key, # missing dataset progression
     sorting.hat, unique.matches,
     po.l, school.l, # new: 'light' datasets
     s.missing, s.there, # new:
     tiers,
     newtiers,
     offices,
     file = file.path(repo.encrypt, "main/final_main_data_recovered.Rdata"))


# export main school dataset as another version

    #tag varsnames longer than 30 characters
    varlist_s <- as.data.frame(colnames(main_school_data_mt))
    to.change_s <- varlist_s %>%
      filter(str_length(colnames(main_school_data_mt)) > 30 )

    # this is the list of schools varnames to change
    varlist_to_change_s<-as.character(to.change_s$`colnames(main_school_data_mt)`)

    # chang the dataset accordinly
    main_school_data_mt_export <- main_school_data_mt %>%
      st_set_geometry(., NULL) %>% # take out geometry
      rename_at(.vars=varlist_to_change_s, ~str_trunc(.,30,"center", ellipsis="")) %>% # rename long vars
      select(-contains("enumerator_name")) # take out enumerator name variable

    # finally, export as dta
    write_dta(data = main_school_data_mt_export,
              path = file.path(repo.encrypt, "main/final_main_school_data_mt.dta"),
              version = 14
            )


  }  # end export switch
