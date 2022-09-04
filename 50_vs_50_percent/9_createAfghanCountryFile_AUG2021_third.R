##Cleaning work envirounment
rm(list = ls())

##Setting working directory
setwd("~/.../third_vs_two_thirds")

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

##Calculate political violence events in the country level. 
country <- working_data %>%
  group_by(yearmonth) %>%
  count() 
write_rds(country, "~/.../third_vs_two_thirds/violent_country_all_years.rds")                           

##Reviewing the country dataframe
head(country, 10)
tail(country, 10)


