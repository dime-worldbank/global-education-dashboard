#wb-database-query.R
# documents the querying of the wb open database to find the indicators that we need

library(tidyverse)
library(wbstats)
library(httr)
library(jsonlite)
library(WDI)

# indicator request ----


# make request to World Bank API
    # "http://api.worldbank.org/v2/sources?per_page=100&format=json" # to query to find the database/source
    # "http://api.worldbank.org/v2/indicator?per_page=500&format=json&source=6", knowing the source, find indicator

indicatorRequest <- GET(url = "http://api.worldbank.org/v2/indicator?per_page=500&format=json&source=50")
indicatorResponse <- content(indicatorRequest, as = "text", encoding = "UTF-8")

# Parse the JSON content and convert it to a data frame.
indicatorsJSON <- fromJSON(indicatorResponse, flatten = TRUE) %>%
  data.frame()

# Print and review the indicator names and ids from the dataframe
cols <- c("id","name")


# location request ----

# Make request to World Bank API
locationRequest <- GET(url = "http://api.worldbank.org/v2/country?per_page=300&format=json&source=50")
locationResponse <- content(locationRequest, as = "text", encoding = "UTF-8")

# Parse the JSON content and convert it to a data frame.
locationsJSON <- fromJSON(locationResponse, flatten = TRUE) %>%
  data.frame()

# Create a dataframe with the location codes and names
cols <- c("id","name")
locationList <- locationsJSON[,cols]

# locationList[,cols] # To see all of the locations and location codes remove the "#" at the beginning of this line
#We can view the first 25 entries below
locationList[1:25,]



# WDI ---- 

# Selecting the indicator
dataSeries = "SI.POV.NAHC"

# select location using codes 
# call to api using above, need subnational ids to pull subnational requests. 
location = c("MOZ") # only country codes work, not region codes. 

# Selecting the time frame
firstYear = 2010
lastYear = 2019

# make call to api
data = WDI(indicator=dataSeries, country=location, start=firstYear, end=lastYear)




# results ----
# Wb subnational population (only at region level)
  # sourceID = 50 
  # indicators: SP.POP.TOTL   Population, total  SP.POP.TOTL.ZS

# WB subnational poverty (region)
  # sourceID = 38
  # indicators: SI.POV.NAHC Poverty headcount ratio at national poverty lines (% of population)




# extract snippet ----

# population

#import  
wbpop <- read.csv(file = "C:/Users/WB551206/OneDrive - WBG/Documents/WB_data/wb-subnational-population/Subnational-PopulationData.csv",
         header = TRUE,
         row.names = NULL) %>%
  rename("Country.Name" = "ï..Country.Name",
         "2000" = "X2000",
         "2001" = "X2001",
         "2002" = "X2002",
         "2003" = "X2003",
         "2004" = "X2004",
         "2005" = "X2005",
         "2006" = "X2006",
         "2007" = "X2007",
         "2009" = "X2009",
         "2010" = "X2010",
         "2011" = "X2011",
         "2012" = "X2012",
         "2013" = "X2013",
         "2014" = "X2014",
         "2015" = "X2015",
         "2016" = "X2016") %>%
  select(-X)

# makerowid
  wbpop$id <- row.names(wbpop)

# subset the countries 

  #create seperate objects for each country, "^" = begins with
 rw<- wbpop %>%
    filter(str_detect(Country.Name, "^Rwanda"))
 mz<- wbpop %>%
   filter(str_detect(Country.Name, "^Mozambique"))
 jd<- wbpop %>%
   filter(str_detect(Country.Name, "^Jordan"))
 pr<- wbpop %>%
   filter(str_detect(Country.Name, "^Peru"))
 
 # bind rows, overwrite wbpop
 wbpop.4 <- bind_rows(rw, mz, jd, pr)


# split the string, use regex to match  
codes<- str_split(wbpop.4$Country.Code, "_", n=2, simplify = TRUE)

str_detect(wbpop.4$Country.Code, "._..\\..._....._.")

str_sub(wbpop.4$Country.Code,
        start = -"_",
        value = " ")
