# gaul.R
# maps wb-official sub-national boundaries to gps coordinates 

pacman::p_load(tidyverse,
               sf)

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

world <- st_read("C:/Users/WB551206/OneDrive - WBG/Documents/WB_data/names+boundaries/20160921_GAUL_GeoJSON_TopoJSON/GeoJSON/g2015_2014_2.geojson")


