# impums.R
# Author: Tom
# Combines impums survey data with ipums shapefiles 



                        
                        # ----------------------------- #
                        # 			     Opening	 		      ----
                        # ----------------------------- #

                        
# settings 
loadip <- 1 # default to not load data, takes up too much memory

# packages 
library(ipumsr)
library(assertthat)
library(summarytools)


# load ipums data 

ddi  <- read_ipums_ddi(ddi_file = file.path(ipums, "ipums22/ipumsi_00022.xml"))

if (loadip == 1) {
data <- read_ipums_micro(ddi, # calls to same directory as ddi
                         verbose = TRUE)
}


                        

                        
                        
                        # ----------------------------- #
                        # 	 Data Transformation	 		   ----
                        # ----------------------------- #


# ensure there are no missing district level obs 
assert_that(sum(is.na(data$GEOLEV2)) == 0)


# clean labels

## keep only labels of countries we're using
data$COUNTRY <- lbl_clean(data$COUNTRY)



# create summary data
    # this will need to be fixed later but for now
    # we'll just use one var to work code 

    
# create summary object 
sum <- data %>% group_by(COUNTRY) %>%
  dfSummary(graph.col = FALSE, na.col = TRUE, style = 'grid')


# collapse by country, district; generate 'average' indicators
i.sum <- data %>%
  group_by(COUNTRY, GEOLEV2) %>%
  summarise(
    pct.urban = mean((URBAN == 1))
  )


# remove data full object
rm(data)



                        # ----------------------------- #
                        # 	 Merge Micro+boundary data	 ----
                        # ----------------------------- #



# load shapfiles from zip file, select only our relevant countries
sf_world2 <- read_ipums_sf(shape_file = 
                            file.path(ipums,
                                      "impus-geo/to-import/world_geolev2_2019.zip"),
                           verbose = TRUE,
                           encoding = "UTF-8")


# keep only relevant countries
sf_world2 <- sf_world2 %>%
  filter(CNTRY_CODE == 400 | # Jordan
         CNTRY_CODE == 508 | # Mozambique
         CNTRY_CODE == 604 | # Peru
         CNTRY_CODE == 646)  # Rwanda


# merge using ipums merge 
ipumsi <- ipums_shape_inner_join(
  i.sum,
  sf_world2,
  by = c("GEOLEV2" = "GEOLEVEL2")
)






                      # ----------------------------- #
                      # 	        Export            	 ----
                      # ----------------------------- #


# save the full space in Dan's folder
save.image(file =
   "C:/Users/WB551206/WBG/Daniel Rogger - 2_Politics Dashboard/5. Data/ipums/ipums22/ipums-data-processed.Rdata")

# only export the geographic file to project repo.
# saveRDS(ipumsi,
#         file = 
#           file.path(repo.encrypt,
#                     "main/district-conditionals.Rda"))