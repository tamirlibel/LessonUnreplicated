##Cleaning work envirounment
rm(list = ls())

##Setting working directory
setwd("~/.../third_vs_two_thirds")

#Loading libraries 
library(zonator)
library(chron)
library(zoo)
library(lubridate)
library(dplyr)
library(stringr)
library(readr)
library(tidyr)
library(data.table)
library(qdapTools)
library(forecast)
library("tidylog", warn.conflicts = FALSE)
library(Metrics)
library(forecast)

##Setting seed
set.seed(2021)

##Creating sub directory for districts_forecasts' .rds files
if(!dir.exists("~/.../third_vs_two_thirds/districts_forecasts")) dir.create("~/.../districts_forecasts")

##Creating a list of the files' names in subfolder 'Districts_violent_events_rds'
DisFilesNames <- list.files("~/.../third_vs_two_thirds/districts_violent_events_rds")
##Counting districts
length(DisFilesNames) #316 districts

##Creating 'DatesEvents' dataframe
DatesEvents <- data.frame(matrix(ncol = 4, nrow = 320))
m <- c("yearmonth", "n", "predicted", "naive")
colnames(DatesEvents) <- m
#Filling 'yearmonth' variable
DatesEvents$yearmonth <- seq.dates(from = "01/01/1995", "08/31/2021", 
                                   by= "months") 
#Converting 'yearmonth' variable to the right format
DatesEvents$yearmonth <- as.numeric(format(as.Date(DatesEvents$yearmonth), '%Y%m'))
DatesEvents$n <- as.numeric(DatesEvents$n)  #Transforming NAs to 0 of variable 'n'
DatesEvents <- DatesEvents %>%
  mutate(n = if_else(is.na(n), 0, n)) 
DatesEvents$predicted <- as.numeric(DatesEvents$predicted) #Transforming NAs to 0 of 'predictor'
class(DatesEvents$predicted) #Validating
DatesEvents <- DatesEvents %>%
  mutate(predicted = if_else(is.na(predicted), 0, predicted))
DatesEvents$naive <- as.numeric(DatesEvents$naive) #Transforming NAs to 0 of 'naive'
class(DatesEvents$naive) #Validating
DatesEvents <- DatesEvents %>%
  mutate(naive = if_else(is.na(naive), 0, naive))

##Creating object DatesEvents2
DatesEvents2 = DatesEvents

##USING FORECAST::ARFIMA+FORECAST & NAIVE+forecast
#Cutting point for test set --> Row 211, 07/2012| ration:1/3 training, 2/3 test
#Creating a progress bar
pb <- txtProgressBar(min = 0, max = length(DisFilesNames), style = 3)
#Looping
for (i in 1:length(DisFilesNames)) {
  DatesEvents = DatesEvents2
   x <- gsub('.rds','',DisFilesNames[i])#Extracting district name
  district <- read_rds(paste0('~/.../third_vs_two_thirds/districts_violent_events_rds/',DisFilesNames[i])) #Reading district's data 
  DatesEvents$n <- district$n[match(DatesEvents$yearmonth, #Merging dataframes to ensure full ts data
                                    district$yearmonth)] 
  DatesEvents$n <- as.numeric(DatesEvents$n)  #Transforming NAs to 0
  DatesEvents <- DatesEvents %>%
    mutate(n = if_else(is.na(n), 0, n)) 
  ##Using arfima() function to forecast
  ObsVec <- DatesEvents$n #Creating ObsVec vector
  start <- 211 #Defining starting value-07/2012
  for (i in start:length(ObsVec)) {
    a <- ObsVec[1:start] #Creating a vector of observed data
    unif <- runif(length(a), min = 0, max = 0.1)
    a <- a+unif #this minor addition allows the arfima to converge
    fit <- forecast::arfima(a, estim="mle") #Training a model
    y_hat <- forecast(fit, h=1) #Forecasting for August 2012
    DatesEvents[start+1, 3] <- y_hat$mean[1]
    start <- start + 1
  }
  initial <- 211 #Defining starting value-07/2012
  for (i in initial:length(ObsVec)) {
    b <- ObsVec[1:initial] #Creating a vector of observed data
    fitN <- naive(b) #Training a model
    y_hat <- forecast(fitN, h=1) #Forecasting 
    DatesEvents[initial+1, 4] <- y_hat$mean[1]
    initial <- initial + 1
  }
  DatesEvents <- round(DatesEvents, digits = 0)
  write_rds(DatesEvents, paste0("~/.../third_vs_two_thirds/districts_forecasts/forecasts", x, ".rds"))
  setTxtProgressBar(pb, i)
}

##Creating a list of files in districts_forecasts
forecasts_files_names <- list.files("~/.../third_vs_two_thirds/districts_forecasts")

##Checking number of districts forecasts files
length(forecasts_files_names) #316 districts/files

