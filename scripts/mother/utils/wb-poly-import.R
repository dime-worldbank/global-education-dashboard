# wb-poly-import.R
# creates a dictionary for 4 countries in GECD based on World Bank polygon files.
# Note that this file is where the randomized geocodes g0-g2 are created.


                    # ------------------------------------- #
                    #        explanation 		            ----
                    # ------------------------------------- #

			# For methodological purposes we will need both the region and
			# district level geometries, but the shapes of each is only
			# included in the region or district level .geojson files. We
			# will thus import both region and district files, and, since the
			# district level files contain the region names and ids, we will
			# bind columns to essentially add a second geometry column in the
			# district level dataset for "region" level geometries


require(geojsonsf) # this is necessary for reading geojson files quickly.
require(stringr)


# import at district level (adm2 level)
wb.poly.2 <- geojson_sf(file.path(repo, "GIS/20160921_GAUL_GeoJSON_TopoJSON/GeoJSON/g2015_2014_2.geojson")) %>%
  filter(
    ADM0_NAME == "Peru" |
  	ADM0_NAME == "Jordan" |
		ADM0_NAME == "Mozambique" |
		ADM0_NAME == "Rwanda"
		) %>%
  distinct(ADM2_CODE, ADM1_CODE, ADM0_CODE, .keep_all = TRUE)  # remove any possible duplicates



# remove extra long region names after '/'
wb.poly.2 <- wb.poly.2 %>%
  separate(., ADM1_NAME, into = c("ADM1_NAME", 'rest'), sep =  "/", remove = TRUE) %>%
  select(-rest) # this renames the ADM1 name to be consistent with other names


# import at region levels for region geometries (adm1 levels)
wb.poly.1 <-
  geojson_sf(file.path(repo, "GIS/20160921_GAUL_GeoJSON_TopoJSON/GeoJSON/g2015_2014_1.geojson")) %>%
  filter(	ADM0_NAME == "Peru" |
    		ADM0_NAME == "Jordan" |
  			ADM0_NAME == "Mozambique" |
  			ADM0_NAME == "Rwanda") %>%
  distinct(ADM1_CODE, ADM0_CODE, .keep_all = TRUE)  # remove any possible duplicates


# check for duplicates: region code
assert_that(anyDuplicated(wb.poly.1$ADM1_CODE) == 0)


# check for duplicates: district code
assert_that(anyDuplicated(wb.poly.2$ADM2_CODE) == 0)





                    # ------------------------------------- #
                    #         random ID creation             ----
                    # ------------------------------------- #
              # we only need to randomly generate ids for one of the
              # two dataframes, so I will use the district one


# create random g0 id (ADM0_CODE): country
wbpoly0 <- as.data.frame(select(wb.poly.2, ADM0_CODE)) %>%
  group_by(ADM0_CODE) %>%
  summarize()   #collapse by unique value of ADM0_code

set.seed(417)
wbpoly0$g0 <-
  runif(length(wbpoly0$ADM0_CODE)) %>%  # generate a random id based on seed
  rank()



# create random g1 id (ADM1_CODE): region
wbpoly1 <- as.data.frame(select(wb.poly.2, ADM1_CODE, ADM0_CODE)) %>%
  group_by(ADM1_CODE, ADM0_CODE) %>%
  summarize()    #collapse by unique value of ADM0_code

set.seed(417)
wbpoly1$g1 =  runif(length(wbpoly1$ADM1_CODE))  %>% # generate a random id based on seed
  rank()



# create random g2 id (ADM2_CODE): district.
wbpoly2 <- as.data.frame(select(wb.poly.2, ADM2_CODE, ADM1_CODE, ADM0_CODE)) %>%
  group_by(ADM2_CODE, ADM1_CODE, ADM0_CODE) %>%
  filter(is.na(ADM2_CODE) == FALSE) %>% # excludes missings
  summarize()    #collapse by unique value of ADM0_code

set.seed(417)
wbpoly2$g2 =  runif(length(wbpoly2$ADM2_CODE))  %>% # generate a random id based on seed
  rank()






              # -   -    -    -    -    -    -    -    -   -   -  #
              # Bind random ids to main datasets (districts) ----


# district level
wb.poly.2 <-
  left_join(wb.poly.2, wbpoly0, by = "ADM0_CODE") %>%
  left_join(wbpoly1, by = c("ADM0_CODE", "ADM1_CODE")) %>%
  left_join(wbpoly2, by =  c("ADM0_CODE", "ADM1_CODE", "ADM2_CODE")) %>%
  distinct(g0, g1, g2, .keep_all = TRUE)



# assert that there are no duplicates of the three randomized ids
assert_that(anyDuplicated(wb.poly.2, by = c("g0", "g1", "g2"), na.rm = TRUE) == 0)
assert_that(anyDuplicated(wb.poly.2, by = c("g0"), na.rm = TRUE) == 0)
assert_that(anyDuplicated(wb.poly.2, by = c("g1"), na.rm = TRUE) == 0)
assert_that(anyDuplicated(wb.poly.2, by = c("g2"), na.rm = TRUE) == 0)






                # -   -    -    -    -    -    -    -    -   -   -  #
                #   Bind random ids to main datasets (region)  ----


wb.poly.1 <- left_join(wb.poly.2, wb.poly.1,
                     by = c("ADM01_CODE"),
                     suffix = c(".d", ".r"))



#check that wb.poly.m has the correct number of observations
assert_that(nrow(wb.poly) == 403) # should be back to 428 yeah? no. should be back to total numbers of districts.










                # -   -    -    -    -    -    -    -    -   -   -  #
                #   Make a decision-making level dataset      ----

            # in practicality, the decision-making level for the education ministries differs
            # by country, so in the project we will merge by different admin levels. this
            # dataset is contains the level at which we will merge.
            #
            # For the countries so far, the dm level is:
            #       Peru: district      (adm2)
            #     Jordan: district      (adm2)
            # Mozambique: district      (adm2)
            #     Rwanda: region   (adm1)

# first make the country-specific objects selected from the decision-making level
per <- wb.poly.2 %>%
  select(ADM0_NAME == "Peru")

jor <- wb.poly.2 %>%
  select(ADM0_NAME == "Jordan")

moz <- wb.poly.2 %>%
  select(ADM0_NAME == "Mozambique")

rwa <- wb.poly.1 %>%
  select(ADM0_NAME == "Rwanda")


# append rows
wb.poly.dm <- # read: dm = decision-making
  bind_rows(per, jor, moz, rwa)








              # -   -    -    -    -    -    -    -    -   -   -  #
              #     Create a lightweight dictionary       ----

          # this will include randomized ids and also wb polygon ADM* codes
          # and should facilitate merging in the future.
          #
          # note that we only need to subset/select columns from the district
          # level dataset because this "lowest" admin level down contains
          # all of the information

polykey <-
  wb.poly.2 %>%
  select(ADM0_CODE, ADM1_CODE, ADM2_CODE,
         g0, g1, g2)







              # -   -    -    -    -    -    -    -    -   -   -  #
              #                         Export          ----


if (savepoly == 1) {
  save(wb.poly.1,
       wb.poly.2,
       wb.poly.dm,
	   polykey,
          file = file.path(root, "main/wbpolydata.Rdata"))
}
