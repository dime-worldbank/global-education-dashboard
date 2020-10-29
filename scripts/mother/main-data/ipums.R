# impums.R
# Author: Tom
# Combines impums survey data with ipums shapefiles, averages these indicators by district
#   and then matches the district-level averages to the districts in the WB polygon schema.



                        # ----------------------------- #
                        # 			     Opening	 		      ----
                        # ----------------------------- #


# settings
loadip <- 1 # default to not load data, takes up too much memory

# packages
library(ipumsr)
library(summarytools)
library(DescTools)


# load ipums data

ddi  <- read_ipums_ddi(ddi_file = file.path(ipums, "ipums24/ipumsi_00024.xml"))

if (loadip == 1) {
data <- read_ipums_micro(ddi, # calls to same directory as ddi, reads same-named data file.
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
data$WALL    <- lbl_clean(data$WALL)





# create summary objects of raw data
sum.raw <- data %>%
  dfSummary(graph.col = FALSE, na.col = TRUE, style = 'grid')

sum.raw.bycountry <- data %>% group_by(COUNTRY) %>%
  dfSummary(graph.col = FALSE, na.col = TRUE, style = 'grid')




# Transform categorical varialbes into indicator

## replace w/ NA the values that are coded as another level in data but really mean missing
data$urb   <- lbl_na_if(data$URBAN,    ~.val >= 9) # urbanity
data$school<- lbl_na_if(data$SCHOOL,   ~.val == 0 | .val == 9) # school attnd
data$lit   <- lbl_na_if(data$LIT,      ~.val == 0 | .val == 9) # literacy
data$edu   <- lbl_na_if(data$EDATTAIN, ~.val == 0 | .val == 9) # edu attain
data$age   <- lbl_na_if(data$AGE,      ~.val == 999          ) # continuous age.
data$work  <- lbl_na_if(data$LABFORCE, ~.val == 8 | .val == 9) # labor force participation
data$wall  <- lbl_na_if(data$WALL,     ~.val == 0 | .val == 999) # wall/dwelling construction
data$elec  <- lbl_na_if(data$ELECTRIC, ~.val == 0 | .val == 9) # HH electricity


## additional variable construction

### Indicator for School Age
data$schoolage <- if_else((data$age < 15 & data$age >= 6), TRUE, FALSE)


### Indicator for improved dwelling conditions
    # note: improved is coded as any time of adobe or stone, see technical note
data$dwell <- if_else(data$wall >= 524 & data$wall <= 547, true = TRUE, false = FALSE)





# collapse by country, district; generate 'average' indicators at the district level
i.sum <- data %>%
  group_by(COUNTRY, GEOLEV2) %>%
  summarise(
    med_age      = median(age, na.rm = TRUE), # median age
    pct_urban    = weighted.mean((urb == 1), w = HHWT, na.rm = TRUE), # pct urban (from HH surveys)
    pct_school   = weighted.mean((school == 1 | school == 3), w = PERWT, na.rm = TRUE), # pct ever attnded school
    pct_lit      = weighted.mean((lit == 2), w = PERWT, na.rm = TRUE), # pct literate
    pct_edu1     = weighted.mean((edu >= 2), w = PERWT, na.rm = TRUE), # pct complete primary
    pct_edu2     = weighted.mean((edu >= 3), w = PERWT, na.rm = TRUE), # pct complete secondary
    pct_work     = weighted.mean((work== 1), w = PERWT, na.rm = TRUE), # pct labor force partic
    pct_schoolage= weighted.mean((schoolage == TRUE), w = PERWT, na.rm = TRUE), # pct schoolage
    pct_dwell    = weighted.mean((dwell == TRUE), w = HHWT, na.rm = TRUE), # pct improved dwelling,
    pct_elec     = weighted.mean((elec  == 1), w = HHWT, na.rm = TRUE)  # pct access to electricity.
) %>%
	# filter out RWA since this is not being merged at the district level.
filter(COUNTRY != "Rwanda")



# collapse by country, region; generate 'average' indicators
i.sum.reg <- data %>%
  group_by(COUNTRY, GEOLEV1) %>%
  summarise(
    med_age      = median(age, na.rm = TRUE), # median age
    pct_urban    = weighted.mean((urb == 1), w = HHWT, na.rm = TRUE), # pct urban (from HH surveys)
    pct_school   = weighted.mean((school == 1 | school == 3), w = PERWT, na.rm = TRUE), # pct ever attnded school
    pct_lit      = weighted.mean((lit == 2), w = PERWT, na.rm = TRUE), # pct literate
    pct_edu1     = weighted.mean((edu >= 2), w = PERWT, na.rm = TRUE), # pct complete primary
    pct_edu2     = weighted.mean((edu >= 3), w = PERWT, na.rm = TRUE), # pct complete secondary
    pct_work     = weighted.mean((work== 1), w = PERWT, na.rm = TRUE), # pct labor force partic
    pct_schoolage= weighted.mean((schoolage == TRUE), w = PERWT, na.rm = TRUE), # pct schoolage
    pct_dwell    = weighted.mean((dwell == TRUE), w = HHWT, na.rm = TRUE), # pct improved dwelling,
    pct_elec     = weighted.mean((elec  == 1), w = HHWT, na.rm = TRUE)  # pct access to electricity.
) %>%
# filter out countries we are merging at the district level
filter(COUNTRY == "Rwanda")






# create summary object of district averages
sum.av <-
  dfSummary(i.sum,
            graph.col = TRUE, labels.col = FALSE, na.col = TRUE, style = 'multiline',
            col.widths = c(5, 40, 100, 60, 100, 40, 40)
            )




# remove data full object
rm(data)







                        # ----------------------------- #
                        # 	 Merge Micro+boundary data	 ----
                        # ----------------------------- #



# load shapfiles from zip file, select only our relevant countries %% may have to use lvl1?
sf_world2 <- read_ipums_sf(shape_file =
                             file.path(ipums, "ipums-gis/world_geolev2_2019.zip"),
                           verbose = TRUE,
                           encoding = "UTF-8")


# keep only relevant countries
sf_world2 <- sf_world2 %>%
  filter(CNTRY_CODE == 400 | # Jordan
         CNTRY_CODE == 508 | # Mozambique
         CNTRY_CODE == 604 | # Peru
         CNTRY_CODE == 646)  # Rwanda


# merge using ipums merge

## for districts
ipums.dist.sum <- ipums_shape_inner_join(
  i.sum,
  sf_world2,
  by = c("GEOLEV2" = "GEOLEVEL2")
)


## for regions
ipums.reg.sum <- ipums_shape_inner_join(
  i.sum.reg,
  sf_world2,
  by = c("GEOLEV1" = "GEOLEVEL1")
)


# check that we didn't lose districts in the merge
assert_that(nrow(ipums.dist.sum) == nrow(i.sum)) # districts
assert_that(nrow(ipums.reg.sum) == nrow(i.sum.reg)) # regions




                    # ----------------------------- #
                    # 	Save Image checkpoint 1      	 ----
                    # ----------------------------- #
                    # Here we want to save the image becuase
                    # we will have to drop some objects to
                    # save memory so we can recover objects
                    # later if/when needed. Note that this
                    # checkpoint does not include raw ipums
                    # data


# save the full space in Dan's folder
save.image(file = file.path(ipums, "ipums24/ipums-data-processed.Rdata"))


# remove files
#rm(ddi, sf_world2)







                    # ----------------------------- #
                    #     Load Main Data             ----
                    # ----------------------------- #
                    # this allows us to pull the wb world
                    # polygon data

load(file = file.path(repo.encrypt, "main/final_main_data_recovered.Rdata"))







                    # ----------------------------- #
                    #     Join geometries           ----
                    # ----------------------------- #


# 1. join ipums to wb.poly by largest overlapping feature
# note that this will not be valid for RWA because the wb.poly.m file does not have
# district polys for RWA, only districts.
district.condls <- st_join(wb.poly.m,  # wb polygons: district level
                           ipums.dist.sum,     # ipums.dist.sum summary by district
                           largest = TRUE) # match by largest overlap


## assert that the number of rows didn't change after merge.
assert_that(nrow(ipums.dist.sum) == nrow(district.condls))


## assert that every row has IPUMS data
assert_that(sum(is.na(district.condls$GEOLEV2)) == 0)


## assert that every row is unique in terms of g2
# this is important becuase we will port over the district level data
# to the project later on, after pii is removed. thereofre we will have
# to match on the anonymized district code, g2.

assert_that(nrow(district.condls) == n_distinct(district.condls$g2))





# 2. do the same as in 1 for regions.
region.condls <- st_join(wb.poly.m,  # wb polygons: district level
                           ipums.reg.sum,     # ipums.dist.sum summary by district
                           largest = TRUE) # match by largest overlap


## assert that the number of rows in wb poly dataset stayed constant
assert_that(nrow(ipums.reg.sum) == nrow(region.condls))


## assert that every row has IPUMS data
assert_that(sum(is.na(region.condls$GEOLEV1)) == 0)


## assert that every row is unique in terms of g2
# this is important becuase we will port over the district level data
# to the project later on, after pii is removed. thereofre we will have
# to match on the anonymized district code, g2.

assert_that(nrow(region.condls) == n_distinct(region.condls$g1))



                    # ----------------------------- #
                    #           Export            ----
                    # ----------------------------- #

if (export == 1) {


# select key variables to export
district.condls.export <- district.condls %>%
  select(ADM0_NAME, g0, g1, g2,
         med_age, pct_urban, pct_school, pct_lit,
         pct_edu1, pct_edu2, pct_work, pct_schoolage,
         pct_dwell, pct_elec) %>%
  rename(
    countryname = ADM0_NAME # this will match the string variable in the using data
  ) %>%
  st_drop_geometry()  # we don't need the geometries.

region.condls.export <- region.condls %>%
  select(ADM0_NAME, g0, g1,
         med_age, pct_urban, pct_school, pct_lit,
         pct_edu1, pct_edu2, pct_work, pct_schoolage,
         pct_dwell, pct_elec) %>%
  rename(
    countryname = ADM0_NAME # this will match the string variable in the using data
  ) %>%
  st_drop_geometry()  # we don't need the geometries.



# Save Rdata
# adds district conditional variable data
save.image(file = file.path(repo.encrypt, "main/final_main_data_ipums.Rdata"))



# export dta
# finally, export as dta
write_dta(data = district.condls.export,
          path = file.path(repo.encrypt, "main/school_dist_conditionals.dta"),
          version = 14
)

# finally, export as dta
write_dta(data = region.condls.export,
          path = file.path(repo.encrypt, "main/school_region_conditionals.dta"),
          version = 14
)



}
