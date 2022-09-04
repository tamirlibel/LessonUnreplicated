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
working_data <- read_rds("afg_working_data_q4_otf.rds")
##Creating a working copy of working_data
WorkData <- working_data

##Splitting the WorkData by 'district2' variable
split_province_afg <- split(WorkData, WorkData$province2)

##Saving files
#Creating sub directory for provinces' .rds files
if(!dir.exists("~/.../provinces_rds")) dir.create("~/.../provinces_rds")
#Split working_data based on working_data$districts2 and writing into .rds files
lapply(names(split_province_afg), function(x){
  write_rds(split_province_afg[[x]], file = paste0("~/.../provinces_rds/","province",tolower(x),".rds"))
})

##Creating a list of provinces_rds filenames
ProFilNames <- list.files("~/.../provinces_rds")
##Validating
#Checking the first three filenames
head(ProFilNames, 3)
#Reading the first file
province_badakshan <- read_rds("~/.../provinces_rds/provincebadakhshan.rds")
#Reviewing the first file
glimpse(province_badakshan)
#Checking the last three filenames
tail(ProFilNames, 3)
#Reading the last file
province_zabul <- read_rds("~/.../provinces_rds/provincezabul.rds")
#Reviewing the last file
glimpse(province_zabul)

##Creating sub directory for provinces' violent events .rds files
if(!dir.exists("~/.../provinces_violent_events_rds")) dir.create("~/.../provinces_violent_events_rds")
##Creating a list of the files' names in subfolder 'Districts_rds'
province_files_names <- list.files("~/.../provinces_rds")

##Looping through districts_rds in order to calculate political violence events
#per districts. Output assigned to district_violent_events_rds
#Creating a progress bar
pb <- txtProgressBar(min = 0, max = length(province_files_names), style = 3)
#Looping
for (i in 1:length(province_files_names)) {
  province <- read_rds(paste0("~/.../provinces_rds/", province_files_names[i]))
  province <- province %>%
    group_by(yearmonth) %>%
    count()
  x <- province_files_names[i]
  write_rds(province, paste0("~/.../provinces_violent_events_rds/", "violent", tolower(x)))
  setTxtProgressBar(pb, i) 
}

##Using list.files() to create a list of provinces_violent_events_rds names
pro_violent_eves <- list.files("~/.../provinces_violent_events_rds")
#Checking the first three filenames
head(pro_violent_eves, 3)
#Reading the first file
province_badakshan <- read_rds("~/.../provinces_violent_events_rds/violentprovincebadakhshan.rds")
#Reviewing the first file
glimpse(province_badakshan)
##Checking the last three filenames
tail(pro_violent_eves, 3)
##Reading the last file
province_zabul <- read_rds("~/.../provinces_violent_events_rds/violentprovincezabul.rds")
#Reviewing the first file
glimpse(province_zabul)

