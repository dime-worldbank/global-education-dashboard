# impums-merge.R
# Author: Tom
# matches IPUMS districts to WB districts and matches district-averaged data. 



                    # ----------------------------- #
                    # 			     Opening	 		      ----
                    # ----------------------------- #


# settings 

                    
# packages 



# load data 

## ipums by district 
ipumsi <- readRDS(file = file.path(repo.encrypt,
                                   "main/district-conditionals.Rda"))

## main data
load(file = file.path(repo.encrypt, "main/final_main_data.Rdata"))     






                    # ----------------------------- #
                    #     Join geometries           ----
                    # ----------------------------- #

# join by largest overlapping feature
join <- st_join(wb.poly.m, ipumsi, largest = TRUE) #%>%
  #select(ADM0_NAME, COUNTRY, ADM2_NAME, ADMIN_NAME)


# assert that the number of rows in wb poly dataset stayed constant
assert_that(nrow(wb.poly.m) == nrow(join))


# assert that every row has IPUMS data 
assert_that(sum(is.na(join$GEOLEV2)) == 0)




