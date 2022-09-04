##Cleaning work envirounment
rm(list = ls())

##Setting working directory
setwd("~/.../50_percents_vs_50_percents")

##Loading packages
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
WorkData <- read_rds("~//afg_working_data_q4.rds")

##Splitting the WorkData by 'province2' variable
split_province_afg <- split(WorkData, WorkData$province2)

##Saving files
#Creating folder for provinces' .rds files
if(!dir.exists("~/.../50_percents_vs_50_percents/provinces_rds")) dir.create("~/.../50_percents_vs_50_percents/provinces_rds")
#Split working_data based on working_data$districts2 and writing into .rds files
lapply(names(split_province_afg), function(x){
  write_rds(split_province_afg[[x]], path = paste0("~/.../50_percents_vs_50_percents/provinces_rds/","province",tolower(x),".rds"))
})

##Creating a list of provinces_rds filenames
ProFilNames <- list.files("~/.../50_percents_vs_50_percents/provinces_rds")
##Validating
#Checking number of files
length(ProFilNames) #34 provinces files
#Checking the first three filenames
head(ProFilNames, 3) 
#Reading the first file
province_badakshan <- read_rds("~/.../50_percents_vs_50_percents/provinces_rds/provincebadakhshan.rds")
#Reviewing the first file
glimpse(province_badakshan)
#Checking the last three filenames
tail(ProFilNames, 3)
#Reading the last file
province_zabul <- read_rds("~/.../50_percents_vs_50_percents/provinces_rds/provincezabul.rds")
#Reviewing the last file
glimpse(province_zabul)

##Creating folder for provinces_violent_events_rds files
if(!dir.exists("~/.../50_percents_vs_50_percents/provinces_violent_events_rds")) dir.create("~/.../50_percents_vs_50_percents/provinces_violent_events_rds")
##Creating a list of the files' names in subfolder 'provinces_rds'
province_files_names <- list.files("~/.../50_percents_vs_50_percents/provinces_rds")
length(province_files_names) #34
##Looping through districts_rds in order to calculate political violence events
#per provinces. Output assigned to district_violent_events_rds
#Creating a progress bar
pb <- txtProgressBar(min = 0, max = length(province_files_names), style = 3)
#Looping
for (i in 1:length(province_files_names)) {
  province <- read_rds(paste0("~/.../50_percents_vs_50_percents/provinces_rds/", province_files_names[i]))
  province <- province %>%
    group_by(yearmonth) %>%
    count()
  x <- province_files_names[i]
  write_rds(province, paste0("~/.../50_percents_vs_50_percents/provinces_violent_events_rds/", "violent", tolower(x)))
  setTxtProgressBar(pb, i) 
}

##Using list.files() to create a list of provinces_violent_events_rds names
pro_violent_eves <- list.files("~/.../50_percents_vs_50_percents/provinces_violent_events_rds")
#Validating
length(pro_violent_eves) #34 files
#Checking the first three filenames
head(ProFilNames, 3)
#Reading the first file
province_badakshan <- read_rds("~/.../50_percents_vs_50_percents/provinces_rds/provincebadakhshan.rds")
#Reviewing the first file
glimpse(province_badakshan)



