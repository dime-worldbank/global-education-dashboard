# impums.R
# Author: Tom
# Combines impums survey data with shapefiles 


# settings 
loadip <- 0 # default to not load data, takes up too much memory

# packages 
library(ipumsr)


# load ipums data 

ddi  <- read_ipums_ddi(ddi_file = file.path(ipums, "ipums21/ipumsi_00021.xml"))

if (loadip == 1) {
ipums <- read_ipums_micro(ddi, 
                         verbose = TRUE)
}

# load shapfiles from zip file, select only our relevant countries
sf_world_2 <- read_ipums_sf(shape_file = file.path(ipums, "impus-geo/to-import"),
                           #shape_layer = c("Peru", "Jordan", "Rwanda", "Mozambique"),
                           verbose = TRUE,
                           encoding = "UTF-8",
                           bind_multiple = TRUE) %>% 
              filter( CNTRY_CODE == 400 | # Jordan
                        CNTRY_CODE == 508 | # Mozambique
                        CNTRY_CODE == 604 | # Peru
                        CNTRY_CODE == 646)  # Rwanda

jor <- filter(sf_world_2, 
              CNTRY_CODE == 400) %>%
        st_drop_geometry()

# create district list %% see vignette.
