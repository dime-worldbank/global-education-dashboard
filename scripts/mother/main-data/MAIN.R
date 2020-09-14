# MAIN.R
# Author: Tom
# calls all necessary scripts for geoprocessing, etc in R


# ----------------------------- #
# 			 startup	 		          ----
# ----------------------------- #

if (!is.element("pacman", installed.packages())) {
  install.packages("pacman", dep= T)
}

pacman::p_load(tidyverse,
               readstata13,
               sf,
               assertthat,
               rio,
               haven,
               sjlabelled)


# ----------------------------- #
# 			 settings	 		          ----
# ----------------------------- #

user <- 1
# where 1 == Tom
# 		  2 == Robert


# shared data folder



# user settings
if (user == 1) {
  root  <- file.path("A:") # raw data
  repo.encrypt <- file.path("B:")
  vault <- file.path(root, "Countries")
  shared <- "C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/global-edu-dashboard/code-review"
  wbpoly <- file.path(shared, "gis/20160921_GAUL_GeoJSON_TopoJSON")
  scripts <- "C:/Users/WB551206/local/GitHub/global-edu-dashboard/scripts/mother"
}

if (user == 2) {
  root  <- file.path("") # <- insert file path here if you want to copy the files locally.
  vault <- file.path(root, "Countries")
  shared <- "C:/Users/WB551206/OneDrive - WBG/Documents/Dashboard/global-edu-dashboard/code-review"
  # replace with where you put the 'code-review' folder if you decide to run locally.
}




# code settings (for review, default values are: appendskip=1 	imprtjson=1		savepoly=2)
# to skip import of the raw json file, run: appendskip=1 	imprtjson=2		savepoly=2

imprtjson <- 0 # 1 = import the raw geojson file for the worldbank polys (takes ~10 min)
# 0 = import the saved file on tom's local folder to skip the import
# 2 = import the saved file on the shared folder to skip this.
savepoly  <- 1 # 1 = save the polygon file to Tom's wb folder for later use.
# 2 = save the file to the shared folder, should be run with imprtjson == 2 if you
# want to import the file that you save in the shared folder.
export  <- 1  # 1 if you want to export/save the files.

matchop <- 1  # 1 if we want to exclude all schools in question.


# run script settings, set to 1 to run
s1 <- 0 # mdataset
s2 <- 0 # adds missing gps cords (or some)




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
