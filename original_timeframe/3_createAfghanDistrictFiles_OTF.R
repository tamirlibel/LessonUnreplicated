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

##A short EDA
glimpse(WorkData)
min(WorkData$yearmonth) #Earliest yearmonth '200102'
max(WorkData$yearmonth) #Latest year month '201203'

##Splitting the WorkData by 'district2' variable
split_district_afg <- split(WorkData, WorkData$district2)

##Saving files
#Creating sub directory for districts' .rds files
if(!dir.exists("~/.../districts_rds")) dir.create("~/.../districts_rds")
#Split working_data based on working_data$districts2 and writing into .rds files
lapply(names(split_district_afg), function(x){
  write_rds(split_district_afg[[x]], file = paste0("~/.../districts_rds/","district",tolower(x),".rds"))
})

##Validaiton
#Creating a list of district_rds filenames
DistrictRdsFiles <- list.files("~/.../districts_rds",
                               full.names = TRUE)
length(DistrictRdsFiles) #304 districts/files
head(DistrictRdsFiles)
##Trimming cases of districts_rds filenames
for (i in DistrictRdsFiles) {
  id <- basename(i)
  id <- gsub(" ", "", id)
    fname <- paste0("~/.../districts_rds", "/", id)
  file.rename(i, fname)
}

##Inspecting several district_rds files
#Creating a list.files object
FixedDisNames <- list.files("~/.../districts_rds")
#Observing the first three lines
head(FixedDisNames, 3)
#Reading first file
district_abband <- read_rds("~/.../districts_rds/districtabband.rds")
glimpse(district_abband)
#Observing the last three lines
tail(FixedDisNames, 3)
#Reading last file
district_zurmat <- read_rds("~/.../districts_rds/districtzurmat.rds")
glimpse(district_zurmat)

##Creating sub directory for districts' violent events .rds files
if(!dir.exists("~/.../districts_violent_events_rds")) dir.create("~/Thesis_two/replicating_my_results_OTF_august2021/districts_violent_events_rds")
##Creating a list of the files' names in subfolder 'Districts_rds'
district_files_names <- list.files("~/.../districts_rds")

##Looping through districts_rds in order to calculate political violence events
#per districts. Output assigned to districts_violent_events_rds
#Creating a progress bar
pb <- txtProgressBar(min = 0, max = length(district_files_names), style = 3)
#Looping
for (i in 1:length(district_files_names)) {
  district <- read_rds(paste0("~/.../districts_rds/", district_files_names[i]))
  district <- district %>%
    group_by(yearmonth) %>%
    count()
  x <- district_files_names[i]
  write_rds(district, paste0("~/.../districts_violent_events_rds/", "violent", tolower(x)))
  setTxtProgressBar(pb, i) 
}

##Using list.files() to create a list of districts_violent_events_rds names
dis_violent_eves <- list.files("~/.../districts_violent_events_rds")
##Inspecting the first three filenames in dis_violent_eve
head(dis_violent_eves, 3)
#Reading the first file
violence_abband <- read_rds("~/.../districts_violent_events_rds/violentdistrictabband.rds")
#Reviewing violence_abband
glimpse(violence_abband)
##Inspecting the last three filenames in 'files'
tail(dis_violent_eves, 3)
#Reading the first file
violence_zurmat <- read_rds("~/.../districts_violent_events_rds/violentdistrictzurmat.rds")
#Reviewing violence_zurmat
glimpse(violence_zurmat)
