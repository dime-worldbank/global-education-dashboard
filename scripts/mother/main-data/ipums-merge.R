# impums-merge.R
# Author: Tom
# matches IPUMS districts to WB districts and matches district-averaged data.



                    # ----------------------------- #
                    # 			     Opening	 		      ----
                    # ----------------------------- #


# settings

# packages



# load data

## ipums by district %% where does this come from? shouldn't it load  file.path(repo.encrypt, "main/final_main_data_ipums.Rdata")?
ipumsi <- readRDS(file = file.path(repo.encrypt,
                                   "main/district-conditionals.Rda"))

## main data
load(file = file.path(repo.encrypt, "main/final_main_data.Rdata"))






                    # ----------------------------- #
                    #     Join geometries           ----
                    # ----------------------------- #

# by district ---

# 1. join ipums to wb.poly by largest overlapping feature
district.condls <- st_join(wb.poly.m, ipumsi, largest = TRUE) #joins by geometry, so reg for RWA, dist for else


## assert that the number of rows in wb poly dataset stayed constant
assert_that(nrow(wb.poly.m) == nrow(district.condls))


## assert that every row has IPUMS data
assert_that(sum(is.na(district.condls$GEOLEV2)) == 0)


## assert that every row is unique in terms of g2
    # this is important becuase we will port over the district level data
    # to the project later on, after pii is removed. thereofre we will have
    # to match on the anonymized district code, g2.

assert_that(nrow(district.condls) == n_distinct(district.condls$g2))




# by region ---

# 1. join ipums to wb.poly by largest overlapping feature
district.condls <- st_join(wb.poly.m, ipumsi, largest = TRUE) #joins by geometry, so reg for RWA, dist for else


## assert that the number of rows in wb poly dataset stayed constant
assert_that(nrow(wb.poly.m) == nrow(district.condls))


## assert that every row has IPUMS data
assert_that(sum(is.na(district.condls$GEOLEV2)) == 0)


## assert that every row is unique in terms of g2
    # this is important becuase we will port over the district level data
    # to the project later on, after pii is removed. thereofre we will have
    # to match on the anonymized district code, g2.

assert_that(nrow(district.condls) == n_distinct(district.condls$g2))







# %% here is where i might also generate an object of g1/region averages, export as sep. dta, save in image


                      # ----------------------------- #
                      #           Export            ----
                      # ----------------------------- #

# select key variables to export
district.condls.export <- district.condls %>%
  select(ADM0_NAME, g0, g1, g2,
        med_age, pct_urban, pct_school, pct_lit,
        pct_edu1, pct_edu2, pct_work, pct_schoolage,
        pct_dwell, pct_elec) %>%
  rename(
    countryname = ADM0_NAME # this will match the string variable in the using data
  ) %>%
  st_drop_geometry()  # we don't need the geometries.



# Save Rdata
save.image(file = file.path(repo.encrypt, "main/final_main_data.Rdata"))



# export dta
# finally, export as dta
write_dta(data = district.condls.export,
          path = file.path(repo.encrypt, "main/school_dist_conditionals.dta"),
          version = 14
)
