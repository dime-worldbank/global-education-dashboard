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

# save as Rda file for now. 
saveRDS(wb.poly,
        file = "A:/main/wb-poly4.Rda")

# load Rda
wb.poly <- readRDS("A:/main/wb-poly4.Rda")


# check for duplicates
assert_that(anyDuplicated(wb.poly$ADM2_CODE) == 0)

# create random g0 id (ADM0_CODE)
set.seed(417)
wb.poly %>% 
  group_by(ADM0_CODE) %>%
  mutate( g0 = runif(length(ADM0_CODE)))  %>%
            rank()


duplicated(wb.poly$ADM1_CODE, by = c("ADM1_CODE", "ADM0_CODE"))
group_indices(wb.poly, ADM0_CODE)

