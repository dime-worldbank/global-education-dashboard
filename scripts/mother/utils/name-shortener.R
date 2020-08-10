#rename some extra long variables and export to stata
# install/load packages using pacman
if (!require("pacman")) install.packages("pacman"); library(pacman)

library(tidyverse)
library(haven)
library(Hmisc)
library(foreign)

# load file path of raw dataset here.
RWA_public_officials_dta_clean <- read_dta("A:/Countries/Rwanda/Data/public_officials_survey_data.dta") # either load using read dta or find Rdata
MOZ_public_officials_dta_clean <- read_dta("A:/Countries/Mozambique/Data/public_officials_survey_data.dta") # either load using read dta or find Rdata
JOR_public_officials_dta_clean <- read_dta("A:/Countries/Jordan/Data/public_officials_survey_data.dta") # either load using read dta or find Rdata
PER_public_officials_dta_clean <- read_dta("A:/Countries/Peru/Data/school_indicator_dta_confidential.dta") # either load using read dta or find Rdata

# for Rwanda, 
var_list<-as.data.frame(colnames(RWA_public_officials_dta_clean))
to_change<-var_list %>%
  filter(str_length(colnames(RWA_public_officials_dta_clean))>26)

RWA_var_list_to_change<-as.character(to_change$`colnames(RWA_public_officials_dta_clean)`)

# for Mozambique, 
var_list<-as.data.frame(colnames(MOZ_public_officials_dta_clean))
to_change<-var_list %>%
  filter(str_length(colnames(MOZ_public_officials_dta_clean))>26)

MOZ_var_list_to_change<-as.character(to_change$`colnames(MOZ_public_officials_dta_clean)`)

# for Jordan, 
var_list<-as.data.frame(colnames(JOR_public_officials_dta_clean))
to_change<-var_list %>%
  filter(str_length(colnames(JOR_public_officials_dta_clean))>26)

JOR_var_list_to_change<-as.character(to_change$`colnames(JOR_public_officials_dta_clean)`)

# for Peru, 
var_list<-as.data.frame(colnames(PER_public_officials_dta_clean))
to_change<-var_list %>%
  filter(str_length(colnames(PER_public_officials_dta_clean))>26)

PER_var_list_to_change<-as.character(to_change$`colnames(PER_public_officials_dta_clean)`)


#modify variable names, for all files
# RWA
RWApublic_officials_dta_export <- RWA_public_officials_dta_clean %>%
  rename_at(.vars=RWA_var_list_to_change, ~str_trunc(.,26,"center", ellipsis="")) %>%
  select(-contains("enumerator"))

write_dta(RWApublic_officials_dta_export,
          "A:/Countries/Rwanda/Data/RWA_po_survey_data_short.dta")

#MOZ
MOZpublic_officials_dta_export <- MOZ_public_officials_dta_clean %>%
  rename_at(.vars=MOZ_var_list_to_change, ~str_trunc(.,26,"center", ellipsis="")) %>%
  select(-contains("enumerator_name"))

write_dta(MOZpublic_officials_dta_export,
          "A:/Countries/Mozambique/Data/MOZ_po_survey_data_short.dta")

#JOR
JORpublic_officials_dta_export <- JOR_public_officials_dta_clean %>%
  rename_at(.vars=JOR_var_list_to_change, ~str_trunc(.,26,"center", ellipsis="")) %>%
  select(-contains("enumerator"))

write_dta(JORpublic_officials_dta_export,
          "A:/Countries/Jordan/Data/JOR_po_survey_data_short.dta")


#Peru
PERpublic_officials_dta_export <- PER_public_officials_dta_clean %>%
  rename_at(.vars=PER_var_list_to_change, ~str_trunc(.,26,"center", ellipsis="")) %>%
  select(-contains("enumerator"))

write_dta(PERpublic_officials_dta_export,
          "A:/Countries/Peru/Data/PER_po_survey_data_short.dta")
