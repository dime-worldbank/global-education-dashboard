# Global Education Dashboard

## Overview
The Global Education Dashboard (GECD) runs two surveys in each country that participates: a public officials survey and a school-level survey. The Public Official (PO) survey interviews civil servants in the ministry of education at various levels (central MinEDU, regional offices, and district offices). The School survey takes averaged measures of school infrastructure, teacher quality, and student test scores at the school level (thus the unit of observation is the individual school). The goal is to tell a story of if/how bureuacratic quality at MinEDU relates to school-level outcomes.

### Geography 
Geography and administrative regions are central to our anlysis. While names for different administrative levels will vary between countries, we refer to the first-level disaggregation below the country as the region, and the second-level disaggregation as the district. The sampling for the two survyes is also geography-dependent: First a subsample of schools is selected at random from a country-wide registry provided by the Ministry of Education. Then, from the districts in which this subsample of schools reside, a subsample of these districts are selected for interviews of public officials and in the Ministry of Education. Therefore, the district-level sampling overlap is theoretically one-way: each public official sampled is in a district with a school sampled, but each school does not necessarily have a public official survey in the same district. Where schools do not have any public officials in the same district, they are dropped from analysis. Please see sampling notes for more details.

### Final Dataset Construction
The goal is to create a dataset with school level observations and associated school survey data, combined with district-level aggregates of bureaucratic indicator from the public officials survey. We also want to minimize the attrition of school-level observations due to the absence of public official data. We create bureaucratic scores by averaging all data from district-level officials; then we merge these averaged scores to schools in the same distrist. This creates the basis for our final anlysis dataset

### Incorporating Outside Data
In order to control for noise and between-country variation, we have also introduced a series of conditional variables (such as population, electrification rate) at the district level, which are also incorproated into the final analysis dataset. More will be described below in Data Sources <br> 

## Data Sources
While the primary data source is raw survey data, there are a number of auxililary data sources that each require various degrees of cleaning or harmonizing before incorporating. 

1. Raw Survey Data: for each country, there is raw survey data for the following: <br>
    - School Survey: taken from .Rdata files and stata <br>
    - Public Officials Survey: taken from .Rdata and stata files <br>
2. World Bank Polygon Data: this is used to harmonize gps coordinates and locations between databases. In other words, the World Bank Polygons and associated names are used as the authoritiative determinant of place names and the real-world geometric shapes of those areas. <br>
3. IPUMS outside survey data: IPUMS is a database of national census and survey data that has been harmonized and optimized from cross-country comparability. The IPUMS thus far has been stored as Rdata but data for additional countries will require making additional requests.
4. GDP Data: The GDP data was generated from nightlight algorithms that produce GDP estimates within a certain kilometer radius of the individual schools. The data GDP data is generally included in the Rdata files. 



## Workflow


The workflow is a bit odd here. Because geography is important (i.e., knowing exacting where each observation is located in relation to others observations in terms of administrative regions), Kris suggested that I begin by creating a "master" dataset that contains only the raw ids, project ids, and geographic data so that I can refer/merge back to this at various points in the repo. The raw data contain gps coordinates, which are used by the simple features package map points in polygons and extract information from the polygons. I use the World Bank subnational boundaries geojson file to obtain the polygones. It's not terribly complicated but all this has to be perfect. <br>

 Also, since the data at this stage is raw, I've created a sample dataset in csv form that mimics key variables and features of the raw datasets. You'll note that there are many points with missing data, and this is somewhat intentional and realistic of my actual data. <br>



## Running the code
The entire repository can be reproduced in a few as two clicks: one for the R portion and one for the Stata portion. I chose to make this a two- or few-click repository in stead of one- because things can get funky when you try to run Stata code from R etc. I'm also much for comfortable doing high-stakes data cleaning and maniuplation in Stata, otherwise I would have done the whole thing in R. The only reason to not translate the Stata portion to R is that there is a key package that is (as of now) only available in R called `iecodebook`, which harmonizes variable labels, names, value labels, etc very quickly and with human-readable documentation. So for now we have, first, the geoprocessing in R, then data cleaning in Stata. 

### R: Geoprocessing and IPUMS 
The first half of the repository is done is R, and can be run with `MAIN.R`, which calls the following scripts in order: `mdataset.R`, `recover.R`, `ipums.R`, and, optionally, `sumstats.R`. Please not the following settings and notes for each of the scripts: <br>
- MAIN.R: You will need to make the following decisions and set the parameters accordingly: <br>
    - If you want to re-process the World Bank World Polygon Shapefiles. This takes a long time computationally (~10 minutes) and *regenerates the randomized geographic variables `g1`, `g2`, and `g3`*, which means that the *entire* rest of the repository will need to be run, including the stata and analysis parts. <br>
        - if *yes*, rerun shapefile regeneration: set `imprtjson == 0` and ensure `savepoly == 1`. It is reccommended you do this the first time you run the repository, then set the settings to `no` as below. <br>
        - if *no*, don't rerun shapefile regeneration: set `imprtjson == 1` and ensure that `savepoly == 1` still. This will skip the ~10 min-long generation of the shapefiles and simply import the R file you saved if you ran under the `yes` parameters. <br>
    - If you want to export/save the files: this is mostly just a saftey mechanism incase you want to test some code without overwriting files. 
        - If *yes*, export and save .Rdata and .dta files: set `export == 1`. Otherwise, <br>
        - If *no*, don't export or save .Rdata and .dta files: set `export == 0` <br>
    - Finally, if you only want to run select scripts, change the following values to: <br>
        - `1` if you want to run the script, and <br>
        - `0` if you don't want to run the scripts, for:: 
```r,
s1 <- 1 # mdataset.R: main dataset import, processing, construction
s2 <- 1 # recover.R:  recovers missing geoinformation to schools with missing gpgs coords
s3 <- 1 # impums.R:   runs IMPUMS data import, processing, matching to WB poly schema
```


## World Bank Shapefile and Polygon Data 
The National-level World Bank Shapefiles are public, but not the subnational files. Those are availabile only on the World Bank Intranet. They are included in the encrypted folder as .geojson files and the Simple Features package can read them, among others. 

### Geoprocessing
I have created a workflow that relies almost entirely on the Simple Features (sf) package, because it can do wonders, and is compatible with most common file types. I suggest you read a bit about the package here: https://r-spatial.github.io/sf/ if you don't know much about it. The only downside of the sf package is that it's somewhat new, and I don't find the available documentation particularly helpful for what we're doing in this repository, which is actually sort of basic in relation to what the package can do. I have not found an equally powerful or comprehensive package in Stata, so the first half of the repository is in R for this main reason. 


## IPUMS data 
Dan has an account with IPUMS which we have used to generate all data extracts. IPUMS has way too much data to just download all of it. Instead, you get IPUMS data by 'shopping' or browsing through their website (https://international.ipums.org/international/). You log in, create a 'cart' or set of countries and variable selections, and then download the associated files. This download instruction page is very helpful (https://international.ipums.org/international/extract_instructions.shtml). Note that you will be able to read the file you download directly from R if you include the .xml and ddi files in the same directory. 

### Maniuplating IPUMS data 
The IPUMS data comes in as "raw", insofar as you get **all** the observations for the criteria you selected, usually at the individual person level. It's not really raw because the actuall raw survey data has been transformed into their categorization schema. The data also includes person and household weights, so make note of these. You should not try to manipulate the data as you normally do with base R or dplyr, etc because IPUMS have produced their own R package for interacting with the data first. To install and look at the introductory package vignette, run

```r, 
install.packages("ipumsr")
vignette("ipums", package = "ipumsr")
```

I highly reccommend you follow the suggested workflow from 
```r,
vignette("ipums-geography", package = "ipumsr")
```
as this describes what to do with NA values, value labels, and the IPUMS geographic data. Note, for example, that NA values are often coded as a factor level (or various factor levels) in IPUMS, and you may not want that. You'll see from my code that I follow the workflow as described in the vignette.

### Incorporating IPUMS data to the World Bank administrative schema by geography. 
Now the only minor issue with the IPUMS data is that they use their own global administrative schema and not that of the World Bank, which is all well and good, except there's no way to automatically match an IPUMS district to a World Bank district, even though most district names and shapes should be roughly the same. The way I join these (in ipums.R) is by use of the Simple Features (sf) package: `st_join()` can connect two features by largest area overlap and, conveniently, the IPUMS package can import shapefiles to interact with the sf package with `read_ipums_sf()`. See the geography vignette for a detailed tour of this. What you end up with in this repo is a key `district.condls` (as R object) or `school_dist_conditionals.dta` (equivalent Stata version) that has links the WB district codes/names with the "matched" IPUMS district and its aggregated indicators by district. This can then be used to match to districts later in the repository.



