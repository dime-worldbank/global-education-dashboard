# MAIN.R
# Author: Tom
# calls all necessary scripts for geoprocessing, etc in R

                   

 
                    # ----------------------------- #
                    # 			 startup	 		          ----
                    # ----------------------------- #

# if (!is.element("pacman", installed.packages())) {
#   install.packages("pacman", dep= T)
# }
library(tidyverse)
library(readstata13)
library(sf)
library(assertthat)
library(rio)
library(haven)
library(sjlabelled)

                    
                    

                    
                    # ----------------------------- #
                    # 			 settings	 		          ----
                    # ----------------------------- #

user <- 1
# where 1 == Tom
# 		  2 == Other



# user settings
if (user == 1) {
  root         <- file.path("A:") # raw data
    vault      <- file.path(root, "Countries")
  repo.encrypt <- file.path("B:")
  repo         <- file.path("C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/global-edu-dashboard")
    wbpoly     <- file.path(repo, "GIS/20160921_GAUL_GeoJSON_TopoJSON")
    html       <- file.path(repo, "out/html")
  scripts      <- "C:/Users/WB551206/local/GitHub/global-edu-dashboard/scripts/mother"
  ipums        <- "C:/Users/WB551206/WBG/Daniel Rogger - 2_Politics Dashboard/5. Data/ipums"
}

if (user == 2) {
  root  <- file.path("") # <- insert file path here if you want to copy the files locally.
  vault <- file.path(root, "Countries")
  # replace with where you put the 'code-review' folder if you decide to run locally.
}




# switch settings

imprtjson <- 0  # 1 = import the raw geojson file for the worldbank polys (takes ~10 min)
                # 0 = import the saved in the project encrypted folder
                # Note: this switch determines if the geoids (g1, g2, g3) will be randomly 
                # generated. If imprtjson == 0, they will not be re-generated. If the switch
                # is set to 1, they will be regenerated.
 
savepoly  <- 1  # 1 = save the polygon file to Tom's wb folder for later use. Only applicable 
                # if imprtjson == 1, but ideally savepoly should be set to 1 so when changes
                # are made, they are saved for later use. The file this saves to if savepoly 
                # == 1 is what imprtjson == 0 imports.


export  <- 1  # 1 if you want to export/save the files.



# run script settings, set to 1 to run

s1 <- 0 # main dataset import, processing, construction
s2 <- 0 # recovers missing geoinformation to schools with missing gpgs coords
s3 <- 0 # runs IMPUMS data import, processing, matching to WB poly schema





                    
                    # ----------------------------- #
                    # 			 Run Code 	 		         ----
                    # ----------------------------- #

# Run Mdataset.R
if (s1 == 1) {
  source(file.path(scripts, "main-data/mdataset.R"))
}

# Recover missing GPS obs
if (s2 == 1) {
  source(file.path(scripts, "main-data/recover.R"))
}

# IPUMS data import/processing/merging
if (s3 == 1) {
  source(file.path(scripts, "main-data/ipums.R"))
}
