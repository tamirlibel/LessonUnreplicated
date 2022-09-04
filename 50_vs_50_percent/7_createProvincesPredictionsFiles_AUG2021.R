##Cleaning work envirounment
rm(list = ls())

##Setting working directory
setwd("~/.../50_percents_vs_50_percents")

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

##Setting seed
set.seed(2021)

#Creating sub directory for provinces_forecasts' .rds files
if(!dir.exists("~/.../50_percents_vs_50_percents/provinces_forecasts")) dir.create("~/.../50_percents_vs_50_percents/provinces_forecasts")

##Creating a list of the files' names in provinces_violent_events_rds
ProFilesNames <- list.files("~/.../50_percents_vs_50_percents/provinces_violent_events_rds")
#Validating 
length(ProFilesNames) #34 files/provinces

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
#Cutting point for test set --> Row 160, 04/2008| ration:1/2 training, 1/2 test
#Creating a progress bar
pb <- txtProgressBar(min = 0, max = length(ProFilesNames), style = 3)
#Looping
for (i in 1:length(ProFilesNames)) {
  DatesEvents = DatesEvents2
  x <- gsub('.rds','',ProFilesNames[i])#Extracting province name
  province <- read_rds(paste0('~/.../50_percents_vs_50_percents/provinces_violent_events_rds/',ProFilesNames[i])) #Reading province's data 
  DatesEvents$n <- province$n[match(DatesEvents$yearmonth, #Merging dataframes to ensure full ts data
                                    province$yearmonth)] 
  DatesEvents$n <- as.numeric(DatesEvents$n)  #Transforming NAs to 0
  DatesEvents <- DatesEvents %>%
    mutate(n = if_else(is.na(n), 0, n)) 
  ##Using arfima() function to forecast
  ObsVec <- DatesEvents$n #Creating ObsVec vector
  start <- 160 #Defining starting value-04/2008
  for (i in start:length(ObsVec)) {
    a <- ObsVec[1:start] #Creating a vector of observed data
    unif <- runif(length(a), min = 0, max = 0.1)
    a <- a+unif #this minor addition allows the arfima to converge
    fit <- forecast::arfima(a, estim="mle") #Training a model
    y_hat <- forecast(fit, h=1) #Forecasting for May 2008
    DatesEvents[start+1, 3] <- y_hat$mean[1]
    start <- start + 1
  }
  initial <- 160 #Defining starting value-04/2008
  for (i in initial:length(ObsVec)) {
    b <- ObsVec[1:initial] #Creating a vector of observed data
    fitN <- naive(b) #Training a model
    y_hat <- forecast(fitN, h=1) #Forecasting 
    DatesEvents[initial+1, 4] <- y_hat$mean[1]
    initial <- initial + 1
  }
  DatesEvents <- round(DatesEvents, digits = 0)
  write_rds(DatesEvents, paste0("~/.../50_percents_vs_50_percents/provinces_forecasts/forecasts", x, ".rds"))
  setTxtProgressBar(pb, i)
}

##Validating number of provinces
#Creating list of files in provinces_forecasts folder
ProForeFiles <- list.files("~/.../50_percents_vs_50_percents/provinces_forecasts") 
#Checking number of files
length(ProForeFiles) #34 files/provinces





