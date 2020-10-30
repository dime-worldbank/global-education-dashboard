# sf-geoms.R 
# sandbox to try to merge multiple sf geometry columns 


# Motivation/Explanation
# Sf or Simple Features arranged a dataframe such that there are regular columns (attributes) and geometry columns, or the 'features'. 
# when you join by column with the sf package, you use some sort of spatial join via st_join that finds which finds overlaps, distrances, 
# etc between the two data frames' geometry columns. But what I want to do is a dplyr style merge by matching two non-geometry 
# attribute columns, ie, region id, and keep both geometry columns. But
# acording to what I could find on the sf github repo, it seems that it is impossible to merge dplyr style -- but the last
# post on this was 3 years ago, so let's see if it's still not possible. 

# packages + file paths 
library(tidyverse)
library(sf)
library(geojsonsf) # reads large .geojson files as sf objects much faster than sf's st_read()

wbgis <- "C:/Users/WB551206/OneDrive - WBG/Documents/WB_data/names+boundaries/20160921_GAUL_GeoJSON_TopoJSON"



# load wb polygon data 

## import at district level (adm2 level)
rwa2 <- geojson_sf(
  file.path(wbgis, "GeoJSON/g2015_2014_2.geojson") # where _2 has district level polys
  ) %>%
  filter( ADM0_NAME == "Rwanda") %>%
  distinct(ADM2_CODE, ADM1_CODE, ADM0_CODE, .keep_all = TRUE)  # remove any possible duplicates

## import at district level (adm1 level)
rwa1 <- geojson_sf(
  file.path(wbgis, "GeoJSON/g2015_2014_1.geojson") # where _1 has region-level polys
  ) %>%
  filter( ADM0_NAME == "Rwanda") %>%
  distinct(ADM1_CODE, ADM0_CODE, .keep_all = TRUE)  # remove any possible duplicates

## keep only the adm0 code and the geometry column.
rwa1 <- rwa1 %>%
  select(ADM1_CODE, geometry)



# plot to show different geometries: rwa1 has 5 regions and rwa has 30 districts 
rwa1 %>% select(ADM1_CODE) %>% plot(., main = 'region geometry')
rwa2 %>% select(ADM2_CODE) %>% plot(., main = 'district geometry')



# merge dplyr style
# ideally I want two geometry columns .1 and .2 for region and district.
# if this were just dplyr I'd use left join(rwa1, rwa2, by = "ADM1_CODE") and this would essentially be a m:1 join 

## try via dplyr
rwa <- 
  left_join(rwa2, rwa1, 
            by = "ADM1_CODE")
### error: y should not have class sf; for spatial joins, use st_join


## try via sf with st_join 
rwa <- 
  st_join(rwa2, rwa1,
          join = st_intersects,
          suffix = c(".2", ".1"),
          largest = TRUE)

### this works but keeps only "left-hand" / rwa2 / district geometry. I want both geometry columns.
rwa %>% select(ADM1_NAME) %>% plot(., main = 'merged geometry')
