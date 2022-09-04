##Creating folder '...'
if(!dir.exists("~/...")) dir.create("~/...")
##Creating subfolder 'data'
if(!dir.exists("~/.../data")) dir.create("~/.../data")
##Setting working directory
setwd("~/...")

##Installing packages
devtools::install_github("IQSS/dataverse-client-r", force = TRUE)
remotes::install_github("andybega/icews", force = TRUE)
##Loading libraries
library(icews)
library(dataverse)
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

#Setting key
Sys.setenv("DATAVERSE_SERVER" = "dataverse.harvard.edu")

##Dry run
download_data("~/.../Data", dryrun = TRUE)
##Fetching the data
download_data("~/.../Data", dryrun = FALSE)

##Reading the data to global environment
complete_events <- read_icews("~/.../Data")
##Writing complete_events into .csv file
write.csv(complete_events, file = "~/.../complete_cases.csv")

##Reading data
complete_events <- read_csv("~/.../complete_cases.csv")

##Subset Afghan data
afg_all <- complete_events %>%
  filter(country == "Afghanistan")
##Assign cameo code to each event
#First, splitting the CAMEO code into single elements. Each observation
#will be a list of three or four numbers
afg_all$cameo_split <- strsplit(as.character(afg_all$cameo_code), '')
#Loop over observations to assign quad code
afg_all$quad <- NA
pb <- txtProgressBar(min = 0, max = nrow(afg_all), style = 3)
for (i in 1:nrow(afg_all)){
  if (afg_all$cameo_split[[i]][1] == 2){
    afg_all$quad[i] <- 4
  } else {
    if (afg_all$cameo_split[[i]][1] == 0){
      if (afg_all$cameo_split[[i]][2] < 6){
        afg_all$quad[i] <- 1
      } else {afg_all$quad[i] <- 2}
    } else {
      if (afg_all$cameo_split[[i]][2] < 5){
        afg_all$quad[i] <- 3
      } else {afg_all$quad[i] <- 4}
    } }
  setTxtProgressBar(pb, i)
}

##Subestting only events that belong to quad 4 (=material conflict)
afg_mat_q4 <- afg_all %>%
  filter(quad == 4)

#Reverse-gecoding function
myfun = function(x,y){
  data_raw<-data.frame(Longitude=x,Latitude=y)
  coordinates(data_raw) = ~Longitude + Latitude
  proj4string(data_raw) = proj4string(data)
  return(over(data_raw, as(data,"SpatialPolygons")))
}

##District level
gadm36_AFG_2_sp <- readRDS("~/.../gadm36_AFG_2_sp.rds")
data = gadm36_AFG_2_sp
##Reverse geocoding coordinates in order to obtain districts' name
#using this to create variable 'district2'
pb <- txtProgressBar(min = 0, max = nrow(afg_mat_q4), style = 3)
for(i in 1:nrow(afg_mat_q4)){
  afg_mat_q4$district2[i] =  data@data[myfun(afg_mat_q4$longitude[i],afg_mat_q4$latitude[i] ) %>% as.numeric(),'NAME_2']
  setTxtProgressBar(pb, i)
}


##Province level
gadm36_AFG_1_sp <- readRDS("gadm36_AFG_1_sp.rds")
data = gadm36_AFG_1_sp
##Reverse geocoding coordinates in order to obtain districts' name
#using this to create variable 'province2'
pb <- txtProgressBar(min = 0, max = nrow(afg_mat_q4), style = 3)
for(i in 1:nrow(afg_mat_q4)){
  afg_mat_q4$province2[i] =  data@data[myfun( afg_mat_q4$longitude[i], afg_mat_q4$latitude[i] ) %>% as.numeric(),'NAME_1']
  setTxtProgressBar(pb, i)
}

##Write afg_working_data data into a .csv file
afg_working_data <- afg_mat_q4
write_rds(afg_working_data, "afg_working_data.rds")