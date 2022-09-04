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

##Setting seed
set.seed(2021)

##Creating 'DatesEvents' dataframe
DatesEvents <- data.frame(matrix(ncol = 4, nrow = 135))
m <- c("yearmonth", "n", "predicted", "naive")
colnames(DatesEvents) <- m
#Filling 'yearmonth' variable
DatesEvents$yearmonth <- seq.dates(from = "02/03/2001", "04/30/2012", 
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
country_pre <- read_rds("~/.../violent_country_OTF.rds")  #Reading province's data 
DatesEvents$n <- country_pre$n[match(DatesEvents$yearmonth, #Merging dataframes to ensure full ts data
                                  country_pre$yearmonth)] 
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
#Rounding results
DatesEvents <- round(DatesEvents, digits = 0)
##Adding '201205' in 'yearmonth' column in row 136. These are the 
#predictions based on row 135
#DatesEvents[136, 1] <- "201205" #row 136 doesn't have the real 'n'!
#Deleting row 136 as it is superflous 
DatesEvents <- DatesEvents[-136, ]
write_rds(DatesEvents, paste0("~/.../forecasts_country_OTF", ".rds"))


##Validating number of provinces
#Creating list of files in provinces_forecasts folder
CouForeFile <- read_rds("~/.../forecasts_country_OTF.rds") 
#Review of the forecasts_country
glimpse(CouForeFile)





