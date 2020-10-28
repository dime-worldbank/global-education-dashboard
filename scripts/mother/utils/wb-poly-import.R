# wb-poly-import.R
# creates a dictionary for 4 countries in GECD based on World Bank polygon files. 
# Note that this file is where the randomized geocodes g0-g2 are created.

require(geojsonsf) # this is necessary for reading level1 files. 
require(stringr)


# import at district level (adm2 level) for all countries except RWA
wb.poly3 <- st_read(file.path(repo, "GIS/20160921_GAUL_GeoJSON_TopoJSON/GeoJSON/g2015_2014_2.geojson")) %>%
  filter(ADM0_NAME == "Peru" | ADM0_NAME == "Jordan" | ADM0_NAME == "Mozambique") %>%
  distinct(ADM2_CODE, ADM1_CODE, ADM0_CODE, .keep_all = TRUE)  # remove any possible duplicates

# import Rwa at the region levels. we must do this to get the region geometries.
rwa.poly <-
  geojson_sf(file.path(repo, "GIS/20160921_GAUL_GeoJSON_TopoJSON/GeoJSON/g2015_2014_1.geojson")) %>%
  filter(ADM0_NAME == "Rwanda") %>%
  distinct(ADM1_CODE, ADM0_CODE, .keep_all = TRUE)  # remove any possible duplicates

# remove extra long names after '/'
rwa.poly <- rwa.poly %>%
  separate(., ADM1_NAME, into = c("ADM1_NAME", 'rest'), sep =  "/", remove = TRUE) %>%
  select(-rest) # this renames the ADM1 name to be consistent with other names
  
  
# check for duplicates: region code
assert_that(anyDuplicated(rwa.poly$ADM1_CODE) == 0)


# check for duplicates: district code
assert_that(anyDuplicated(wb.poly3$ADM2_CODE) == 0)

# append the dataframes
wb.poly <- wb.poly3 %>%
  bind_rows(., rwa.poly)



                    
                    # ------------------------------------- #
                    #         random ID creation             ----
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



# create random g2 id (ADM2_CODE): district. %% must exclude NA's
wbpoly2 <- as.data.frame(select(wb.poly, ADM2_CODE, ADM1_CODE, ADM0_CODE)) %>%
  group_by(ADM2_CODE, ADM1_CODE, ADM0_CODE) %>%
  filter(is.na(ADM2_CODE) == FALSE) %>% # excludes missings
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
assert_that(anyDuplicated(wb.poly.m, by = c("g0", "g1", "g2"), na.rm = TRUE) == 0)
assert_that(anyDuplicated(wb.poly.m, by = c("g0"), na.rm = TRUE) == 0)
assert_that(anyDuplicated(wb.poly.m, by = c("g1"), na.rm = TRUE) == 0)
assert_that(anyDuplicated(wb.poly.m, by = c("g2"), na.rm = TRUE) == 0)


# assert that the only missing values for g2 are from RWA 
assert_that( sum(is.na(wb.poly.m$g2)) == nrow(rwa.poly) )
  
# switch g2 and g1 for RWA
# Here we made a methodological decision to merge Rwanda at the region level and not the district level. 
# what we will do is copy the values for Rwanda's g1 into it's g2 field (also ADM2_CODE?) so that, in 
# effect, Rwanda's "region" values become the "district" on which we will merge. The geometries are the 
# region or ADM1 polygons.
wb.poly.m$g2[wb.poly.m$ADM0_NAME %in% "Rwanda"] <- wb.poly.m$g1[wb.poly.m$ADM0_NAME %in% "Rwanda"]

#check that wb.poly.m has the correct number of observations 
assert_that(nrow(wb.poly.m) == 403)

# export
if (savepoly == 1) {
  saveRDS(wb.poly.m,
          file = file.path(root, "main/wb-poly-m.Rda"))
}
