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
  # Repository Root Folder
repo.top       <- "C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard" # Replace This with folder path above main data folder.
  repo         <- file.path(repo.top, "global-edu-dashboard")
    wbpoly     <- file.path(repo, "GIS/20160921_GAUL_GeoJSON_TopoJSON")
    html       <- file.path(repo, "out/html")

  # Encrypted folders, same for all users
  root         <- file.path("A:") # raw data
    vault      <- file.path(root, "Countries")
    ipums      <- file.path(root, "ipums")
  repo.encrypt <- file.path("B:") # processed data, with pii
    ipumsgeo   <- file.path(repo.encrypt, "ipums-geo")
  
  # GitHub local paths
  gh           <- "C:/Users/WB551206/local/GitHub/global-edu-dashboard" # replace this with path of local github folder.
    scripts    <- file.path(gh, "scripts/mother")


}



if (user == 2) {
  # Repository Root Folder
  repo.top       <- "" # Replace This with folder path above main data folder.
    repo         <- file.path("global-edu-dashboard")
      wbpoly     <- file.path(repo, "GIS/20160921_GAUL_GeoJSON_TopoJSON")
      html       <- file.path(repo, "out/html")

  # Encrypted folders, same for all users
    root         <- file.path("A:") # raw data
      vault      <- file.path(root, "Countries")
      ipums      <- file.path(root, "ipums")
    repo.encrypt <- file.path("B:") # processed data, with pii
      ipumsgeo   <- file.path(repo.encrypt, "ipums-geo")

  # GitHub local paths
    gh           <- "" # replace this with path of local github folder.
      scripts    <- file.path(gh, "scripts/mother")


  #dataout      <- "C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/global-edu-dashboard" # depreciated.
}




# switch settings

imprtjson <- 0  # 1 = import the raw geojson file for the worldbank polys (takes ~10 min)
                # 0 = import the saved in the project encrypted folder
                # Note: this switch determines if the geoids (g1, g2, g3) will be randomly
                # generated. If imprtjson == 0, they will not be re-generated. If the switch
                # is set to 1, they will be regenerated. the individual observation ids
                # (idpo and idschool) are randomly re-generated each time mdataset.R is run
                # regardless of this switch.

savepoly  <- 1  # 1 = save the polygon file to Tom's wb folder for later use. Only applicable
                # if imprtjson == 1, but ideally savepoly should be set to 1 so when changes
                # are made, they are saved for later use. The file this saves to if savepoly
                # == 1 is what imprtjson == 0 imports.


export  <- 1  # 1 if you want to export/save the files.



# Observation Settings
    # These values are what we know the final observation count should be;
    # please change as data grow

ns       =  1060   # should be 1059 schools (or 1060 with obs that is dropped)
npo      =  721    # should be 721  public officials obs




# run script settings, set to 1 to run

## utilities (not required to be run every time)
u1 <- 0 # wb poly import/re-randomize
u2 <- 0 # runs enrollment-gps.R: only needed to be run once.

## main scripts (should be run every time)
s1 <- 0 # main dataset import, processing, construction
s2 <- 0 # recovers missing geoinformation to schools with missing gpgs coords
s3 <- 0 # runs IMPUMS data import, processing, matching to WB poly schema






                    # ----------------------------- #
                    # 			 Run Code 	 		         ----
                    # ----------------------------- #
## Run utilties
# run the importing of WB polygon files.
if (u1 == 1) { #formerly imprtjson
  source(file.path(scripts, "utils/wb-poly-import.R"))
}

# Enrollment Data creation.
if (u2 == 1) {
  source(file.path(scripts, "utils/enrollment-gps.R"))
}



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
