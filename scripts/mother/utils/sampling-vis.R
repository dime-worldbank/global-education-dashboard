# sampling-vis.R
# A lightweight script that generates graphs about sampling overlap in each country

# packages 

library(plotly)



# load data 
load(file = file.path(repo.encrypt, "main/final_main_data_ipums.Rdata"))
wbpoly <- readRDS(file = file.path(root, "main/wb-poly-m.Rda"))     
     
# extract crs of wb poly 
crs <- st_crs(wbpoly)

# check crs / convert to sf
po_s <-
  st_as_sf(m.po.gps,
          coords = c("lon", "lat"), # set geometry/point column first
          na.fail = FALSE) %>%
  st_set_crs(., crs)
  
school_s  <-
  st_as_sf(m.school.gps,
           coords = c("lon", "lat"), # set geometry/point column first
          na.fail = FALSE) %>%
  st_set_crs(., crs)

# start creating a merged dataset 
## all we need to do is create counts of obs that lie within the wb poly.
## Note this is different than before because we are using the wbpoly as the
## 'left' object whereas in mdataset.R we used the schools or po's as the 'left' 
## 
## join using m.school.gps and m.po.gps
ovr <- 
  st_join(wbpoly, po_s,
          join = st_within)

# %% start here, now we have a merge so summarize.





# start plotting 
## sf
plot(st_geometry(wbpoly[wbpoly$ADM0_NAME %in% "Peru", "g2"]), 
     col = sf.colors(10, categorical = TRUE))

## ggplot 
ggplot() + 
  geom_sf(data = wbpoly[wbpoly$ADM0_NAME %in% "Peru", ], aes(fill = g1)) 

## plotly
