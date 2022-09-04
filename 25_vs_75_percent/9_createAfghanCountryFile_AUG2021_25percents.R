##Cleaning work envirounment
rm(list = ls())

##Setting working directory
setwd("~/.../25_percents_VS_75_percents")

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
working_data <- read_rds("~/.../afg_working_data_q4.rds")
##Creating a working copy of working_data
WorkData <- working_data

##Calculate political violence events in the country level. 
country <- WorkData %>%
  group_by(yearmonth) %>%
  count() 
write_rds(country, "~/.../25_percents_VS_75_percents/violent_country_all_years.rds")                           

##Reviewing the country dataframe
head(country, 10)
tail(country, 10)


