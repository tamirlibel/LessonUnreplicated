##Cleaning working envirounment
rm(list = ls())

##Setting working directory
setwd("~/...")

##Installing packages
##Loading libraries
library(dplyr)
library(stringr)
library(sp)
library(tidyverse)
library(ggthemes)
library(caroline)
library(lubridate)
library(dplyr)
library(readr)
library(tidyr)
library("tidylog", warn.conflicts = FALSE)

##Setting seed
set.seed(2021)

#Reading afg_working_data
working_data <- read_rds("~/.../afg_working_data_q4_otf.rds")
##Creating a working copy of working_data
WorkData <- working_data

#Calculate political violence events in the country level. 
#Output is assigned to country_violent_events_rds folder
country <- WorkData
    country <- country %>%
      group_by(yearmonth) %>%
      count() 
write_rds(country, paste0("~/.../", "violent_country_OTF.rds"))                           

##Reviewing the country dataframe
head(country, 10)
tail(country, 10)


