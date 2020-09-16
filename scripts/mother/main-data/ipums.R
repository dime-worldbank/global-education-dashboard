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


# ensure there are no missing key variables 

## district number 
assert_that(sum(is.na(data$GEOLEV2)) == 0)

## weight variable
assert_that(sum(is.na(data$HHWT)) == 0)



# clean labels

## keep only labels of countries we're using
data$COUNTRY <- lbl_clean(data$COUNTRY)



# create summary data
    # this will need to be fixed later but for now
    # we'll just use one var to work code 

    
# create summary object 
sum <- data %>% group_by(COUNTRY) %>%
  dfSummary(graph.col = FALSE, na.col = TRUE, style = 'grid')


# Transform categorical varialbes into indicator 

## replace w/ NA the values that seem 'valid' in data but really mean missing 
data$urb <- lbl_na_if(data$URBAN,    ~.val >= 9) # urbanity
data$sch <- lbl_na_if(data$SCHOOL,   ~.val == 0 | .val == 9) # school attnd
data$lit <- lbl_na_if(data$LIT,      ~.val == 0 | .val == 9) # literacy 
data$edu <- lbl_na_if(data$EDATTAIN, ~.val == 0 | .val == 9) # edu attain 



# collapse by country, district; generate 'average' indicators
i.sum <- data %>%
  group_by(COUNTRY, GEOLEV2) %>%
  summarise(
    med_age   = median(AGE2, na.rm = TRUE), # median age
    pct_urban = weighted.mean((urb == 1), w = PERWT, na.rm = TRUE), # pct urban
    pct_attn  = weighted.mean((sch == 1 | sch == 3), w = PERWT, na.rm = TRUE), # pct ever attnded school
    pct_lit   = weighted.mean((lit == 2), w = PERWT, na.rm = TRUE), # pct literate
    pct_edu1  = weighted.mean((edu >= 2), w = PERWT, na.rm = TRUE), # pct complete primary
    pct_edu2  = weighted.mean((edu >= 3), w = PERWT, na.rm = TRUE) # pct complete secondary
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


# check that we didn't lose districts in the merge 
assert_that(nrow(ipumsi) == nrow(i.sum))






                      # ----------------------------- #
                      # 	        Export            	 ----
                      # ----------------------------- #


# save the full space in Dan's folder
save.image(file =
   "C:/Users/WB551206/WBG/Daniel Rogger - 2_Politics Dashboard/5. Data/ipums/ipums22/ipums-data-processed.Rdata")

#only export the geographic file to project repo.
saveRDS(ipumsi,
        file =
          file.path(repo.encrypt,
                    "main/district-conditionals.Rda"))

# remove files 
rm(ddi, ipumsi, sf_world2)
