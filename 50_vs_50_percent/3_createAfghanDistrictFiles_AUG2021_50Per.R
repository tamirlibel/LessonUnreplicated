##Cleaning work envirounment
rm(list = ls())

##Setting working directory
setwd("~/.../50_percents_vs_50_percents")

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
WorkData <- read_rds("~/.../afg_working_data_q4.rds")

##Splitting the WorkData by 'district2' variable
split_district_afg <- split(WorkData, WorkData$district2)

##Saving files
#Creating sub directory for districts' .rds files
if(!dir.exists("~/.../50_percents_vs_50_percents/districts_rds")) dir.create("~/.../50_percents_vs_50_percents/districts_rds")
#Split working_data based on working_data$districts2 and writing into .rds files
lapply(names(split_district_afg), function(x){
  write_rds(split_district_afg[[x]], path = paste0("~/.../50_percents_vs_50_percents/districts_rds/", x, ".rds"))
  })

##Creating a list of districts_rds filenames
dis_list <- list.files("~/.../50_percents_vs_50_percents/districts_rds",
                       full.names = TRUE)
length(dis_list) #317
##Trimming and lowering cases of districts_rds filenames
for (i in dis_list) {
  id <- basename(i)
  id <- gsub(" ", "", id)
  id <- tolower(id)
  fname <- paste0("~/.../50_percents_vs_50_percents/districts_rds/", "/", id)
  file.rename(i, fname)
}

##Inspecting several district_rds files
#Creating a list.files object
FixedDisNames <- list.files("~/.../50_percents_vs_50_percents/districts_rds")
#Validating length
length(FixedDisNames) #316 files/districts
#Observing the first three lines
head(FixedDisNames, 3)
#Reading first file
district_abband <- read_rds("~/.../50_percents_vs_50_percents/districts_rds/abband.rds")
glimpse(district_abband)
#Observing the last three lines
tail(FixedDisNames, 3)
#Reading last file
district_zurmat <- read_rds("~/.../50_percents_vs_50_percents/districts_rds/zurmat.rds")
glimpse(district_zurmat)

##Creating folders for counts of violent events per month
#districts_violent_events_rds
if(!dir.exists("~/.../50_percents_vs_50_percents/districts_violent_events_rds")) dir.create("~/.../50_percents_vs_50_percents/districts_violent_events_rds")


##Creating a list of the files' names in subfolder 'Districts_rds'
district_files_names <- list.files("~/.../50_percents_vs_50_percents/districts_rds")
length(district_files_names) #316 files/districts

##Looping through districts_rds in order to calculate political violence events
#per districts. Output assigned to districts_violent_events_rds
#Creating a progress bar
pb <- txtProgressBar(min = 0, max = length(district_files_names), style = 3)
#Looping
for (i in 1:length(district_files_names)) {
  district <- read_rds(paste0("~/.../50_percents_vs_50_percents/districts_rds/", district_files_names[i]))
  district <- district %>%
    group_by(yearmonth) %>%
    count()
  x <- district_files_names[i]
  write_rds(district, paste0("~/.../50_percents_vs_50_percents/districts_violent_events_rds/", "violent", tolower(x)))
  setTxtProgressBar(pb, i) 
}

##Using list.files() to create a list of districts_violent_events_rds 
#filenames
files <- list.files("~/.../50_percents_vs_50_percents/districts_violent_events_rds", recursive = TRUE,
  full.names = TRUE)
length(files) #316 files/districts
##Inspecting the first three filenames in 'files'
head(files, 3)
#Reading the first file
violentadraskan <- read_rds("~/.../50_percents_vs_50_percents/districts_violent_events_rds/violentadraskan.rds")
#Reviewing violence_abband
glimpse(violentadraskan)
##Inspecting the last three filenames in 'files'
tail(files, 3)
#Reading the first file
violence_zurmat <- read_rds("~/.../50_percents_vs_50_percents/districts_violent_events_rds/violentzurmat.rds")
#Reviewing violence_zurmat
glimpse(violence_zurmat)

