# wb-poly-import.R
# creates a dictionary for 4 countries in GECD based on World Bank polygon files. 
# Note that this file is where the randomized geocodes g0-g2 are created.


wb.poly <- st_read(file.path(repo, "GIS/20160921_GAUL_GeoJSON_TopoJSON/GeoJSON/g2015_2014_2.geojson")) %>%
  filter(ADM0_NAME == "Peru" | ADM0_NAME == "Jordan" | ADM0_NAME == "Mozambique" | ADM0_NAME == "Rwanda") %>%
  distinct(ADM2_CODE, ADM1_CODE, ADM0_CODE, .keep_all = TRUE)  # remove any possible duplicates


# check for duplicates: district code
assert_that(anyDuplicated(wb.poly$ADM2_CODE) == 0)



                    
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


