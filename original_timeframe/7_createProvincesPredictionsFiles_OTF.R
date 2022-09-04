##Cleaning working envirounment
rm(list = ls())

##Setting working directory
setwd("~/...")

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

##Setting seeds
set.seed(2021)

#Creating sub directory for provinces_forecasts' .rds files
if(!dir.exists("~/.../provinces_forecasts")) dir.create("~/.../provinces_forecasts")

##Creating a list of the files' names in subfolder 'provinces_violent_events_rds'
ProFilesNames <- list.files("~/.../provinces_violent_events_rds")

##Creating 'DatesEvents' dataframe
DatesEvents <- data.frame(matrix(ncol = 4, nrow = 135))
m <- c("yearmonth", "n", "predicted", "naive")
colnames(DatesEvents) <- m
#Filling 'yearmonth' variable
DatesEvents$yearmonth <- seq.dates(from = "02/01/2001", "04/30/2012", 
                                   by = "months") 
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
#Creating a progress bar
pb <- txtProgressBar(min = 0, max = length(ProFilesNames), style = 3)
#Looping
for (i in 1:length(ProFilesNames)) {
  DatesEvents = DatesEvents2
  x <- gsub('.rds','',ProFilesNames[i])#Extracting province name
  province <- read_rds(paste0('~/.../provinces_violent_events_rds/',ProFilesNames[i])) #Reading province's data 
  DatesEvents$n <- province$n[match(DatesEvents$yearmonth, #Merging dataframes to ensure full ts data
                                    province$yearmonth)] 
  DatesEvents$n <- as.numeric(DatesEvents$n)  #Transforming NAs to 0
  DatesEvents <- DatesEvents %>%
    mutate(n = if_else(is.na(n), 0, n)) 
  ##Using arfima() function to forecast
  ObsVec <- DatesEvents$n #Creating ObsVec vector
  start <- 87 #Defining starting value-04/2008, starting point of original paper
  for (i in start:length(ObsVec)) {
    a <- ObsVec[1:start] #Creating a vector of observed data
    unif <- runif(length(a), min = 0, max = 0.1)
    a <- a+unif #this minor addition allows the arfima to converge
    fit <- forecast::arfima(a, estim="mle") #Training a model
    y_hat <- forecast(fit, h=1) #Forecasting for May 2008
    DatesEvents[start+1, 3] <- y_hat$mean[1]
    start <- start + 1
  }
  initial <- 87 #Defining starting value-04/2008, starting point of original pape
  for (i in initial:length(ObsVec)) {
    b <- ObsVec[1:initial] #Creating a vector of observed data
    fitN <- naive(b) #Training a model
    y_hat <- forecast(fitN, h=1) #Forecasting 
    DatesEvents[initial+1, 4] <- y_hat$mean[1]
    initial <- initial + 1
  }
  write_rds(DatesEvents, paste0("~/.../provinces_forecasts/forecasts", x, ".rds"))
  setTxtProgressBar(pb, i)
}

##Validating number of provinces
#Creating list of files in provinces_forecasts folder
ProForeFiles <- list.files("~/.../provinces_forecasts") 
#Checking number of files
length(ProForeFiles) #34 files/provinces





