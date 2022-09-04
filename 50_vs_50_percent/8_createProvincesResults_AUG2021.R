##Cleaning work envirounment
rm(list = ls())

##Setting working directory
setwd("~/.../50_percents_vs_50_percents")

#Loading libraries
library(dplyr)
library(readr)
library(stringr)
library("tidylog", warn.conflicts = FALSE)
library(Metrics)
library(chron)
library(gridExtra)

##Setting seed
set.seed(2021)

#Creating ErrorsData dataframe
ErrorsData <- data.frame(matrix(vector(), 160, 4,
                                dimnames=list(c(), c("yearmonth", "PreN", "NaiN", "Pre_Nai")))) 
#Filling 'yearmonth' variable
ErrorsData$yearmonth <- seq.dates(from = "5/01/2008", "08/31/2021", 
                                  by= "months")
#Converting 'yearmonth' variable to the right format
ErrorsData$yearmonth <- as.numeric(format(as.Date(ErrorsData$yearmonth), '%Y%m'))
#Populating 'PreN' and 'NaiN' columns with zeros
ErrorsData$PreN <- 0
ErrorsData$NaiN <- 0

##Creating a vector of file names for districts_forecasts
ForecastFiles <- list.files("~/.../50_percents_vs_50_percents/provinces_forecasts")
#Overview
length(ForecastFiles)#34 provinces

##Looping over districts forecast files to the calculate the total difference
#between ARFIMA predictions and observed data
for (i in 1:length(ForecastFiles)) {
  forecast <- read_rds(paste0("~/.../50_percents_vs_50_percents/provinces_forecasts/",ForecastFiles[i])) #Reading province's data)
  CalDat <- forecast[161:320, ] #Reading 'test data' forecast data into CalDat
  #Calculating 'predicted-n' data
  ErrorsData$PreN <- ErrorsData$PreN + abs((CalDat$predicted - CalDat$n))
}

##Creating a working copy of ErrorsData --> ErrorsData2
ErrorsData2 <- ErrorsData

##Dividing ErrorData$PreN by N (=number of provinces=34)
#Getting the MAE results per yearmonth unit
ErrorsData2$PreN <- ErrorsData2$PreN / 34

##Looping over districts forecast files to the caculate the total difference
#between Naive predictions and observed data
#Cutting point for test set --> Row 160, 04/2008| ration:1/2 training, 1/2 test
for (i in 1:length(ForecastFiles)) {
  forecast <- read_rds(paste0("~/.../50_percents_vs_50_percents/provinces_forecasts/",ForecastFiles[i])) #Reading district's data)
  CalDat <- forecast[161:320, ] #Reading 'test data' forecast data into CalDat
  #Calculating 'predicted-n' data
  ErrorsData2$NaiN <- ErrorsData2$NaiN + abs((CalDat$naive - CalDat$n))
}

##Creating a working copy of ErrorsData2 --> ErrorsData3
ErrorsData3 <- ErrorsData2

##Dividing ErrorData$NaiN by N (=number of provinces=34)
#Getting the MAE results per yearmonth unit
ErrorsData3$NaiN <- ErrorsData3$NaiN / 34

##Testing whether more ARFIMA MAEs are lower than NAIVE MAEs
ErrorsData3$Pre_Nai <- ErrorsData3$PreN < ErrorsData3$NaiN
##Checking results
table(summary(ErrorsData3$Pre_Nai)) ##131 True, 29 False


##Writing the results into .rds file
write_rds(ErrorsData3, "~/.../50_percents_vs_50_percents/provinces_results_table_all_years_50Per.rds")

##Reading data
data <- read_rds("~/.../50_percents_vs_50_percents/provinces_results_table_all_years_50Per.rds")

##Calculating sum of ARFIMA MAE
sum(data$PreN) #1201.11
##Calculating sum of NAIVE MAE
sum(data$NaiN) #1421.20
