# gaul.R
# maps wb-official sub-national boundaries to gps coordinates 

pacman::p_load(tidyverse,
               sf,
               assertthat)

    # for now, this will only test on one country's dataset to see how coding works, 
    # which means that the script will pull raw files from the Rdata file that Brian 
    # shared.




                        # ------------------------------------- # 
                        # load + prepare dataset                # ----
                        # ------------------------------------- # 


# open raw data, create new environment to not overwrite
load("A:/Countries/Rwanda/Data/Full_Data/school_indicators_data.RData", snb<- new.env())
    
    # our main dataset will be $school_dta_short


# create an object out of schoolid, lat long
points <- select(snb$school_dta_short, 
                 school_code:school_info_correct, lat, lon
                 )



                        # ------------------------------------- # 
                        # import WB subnational geojson files    # ----
                        # ------------------------------------- # 
wbpoly <- "C:/Users/WB551206/OneDrive - WBG/Documents/WB_data/names+boundaries/20160921_GAUL_GeoJSON_TopoJSON"

wb.poly <- st_read(file.path(wbpoly, "GeoJSON/g2015_2014_2.geojson")) %>%
  filter(ADM0_NAME == "Peru" | ADM0_NAME == "Jordan" | ADM0_NAME == "Mozambique" | ADM0_NAME == "Rwanda")

# check for duplicates
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
  left_join(wbpoly2, by =  c("ADM0_CODE", "ADM1_CODE", "ADM2_CODE"))

# assert that there are no duplicates of the three randomized ids
assert_that(anyDuplicated(wb.poly.m$g2,
                          wb.poly.m$g1,
                          wb.poly.m$g0) == 0)





                          # ------------------------------------- # 
                          #   spatial join with main dataset      # ----
                          # ------------------------------------- # 



saveRDS(wb.poly,
        file = "A:/main/wb-poly4.Rda")
