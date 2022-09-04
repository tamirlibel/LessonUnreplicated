##Cleaning work envirounment
rm(list = ls())

##Setting working directory
setwd("~/.../third_vs_two_thirds")

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
ErrorsData <- data.frame(matrix(vector(), 109, 4,
                                dimnames=list(c(), c("yearmonth", "PreN", "NaiN", "Pre_Nai")))) 
#Filling 'yearmonth' variable
ErrorsData$yearmonth <- seq.dates(from = "08/01/2012", "08/01/2021", 
                                  by= "months")
#Converting 'yearmonth' variable to the right format
ErrorsData$yearmonth <- as.numeric(format(as.Date(ErrorsData$yearmonth), '%Y%m'))
#Populating 'PreN' and 'NaiN' columns with zeros
ErrorsData$PreN <- 0
ErrorsData$NaiN <- 0

##Looping over districts forecast files to the caculate the total difference
#between ARFIMA predictions and observed data
forecast <- read_rds("~/.../third_vs_two_thirds/country_forecasts_third.rds")
CalDat <- forecast[212:320, ] #Reading 'test data' forecast data into CalDat|12/2014
#Calculating 'predicted-n' data
ErrorsData$PreN <- ErrorsData$PreN + abs((CalDat$predicted - CalDat$n))

##Creating a working copy of ErrorsData --> ErrorsData2
ErrorsData2 <- ErrorsData

##Dividing ErrorData$PreN by N (=number of country=1)
#Getting the MAE results per yearmonth unit
ErrorsData2$PreN <- ErrorsData2$PreN / 1

##Looping over districts forecast file to the calculate the total difference
#between Naive predictions and observed data
forecast <- read_rds("~/.../third_vs_two_thirds/country_forecasts_third.rds")
CalDat <- forecast[212:320, ] #Reading 'test data' forecast data into CalDat
#Calculating 'predicted-n' data
ErrorsData2$NaiN <- ErrorsData2$NaiN + abs((CalDat$naive - CalDat$n))


##Creating a working copy of ErrorsData2 --> ErrorsData3
ErrorsData3 <- ErrorsData2

##Dividing ErrorData$NaiN by N 
#Getting the MAE results per yearmonth unit
ErrorsData3$NaiN <- ErrorsData3$NaiN / 1

##Testing whether more ARFIMA MAEs are lower than NAIVE MAEs
ErrorsData3$Pre_Nai <- ErrorsData3$PreN < ErrorsData3$NaiN
##Checking results
table(summary(ErrorsData3)) #62 TRUE, 47 FALSE
#(62*100)/109=56.88%

##Writing ErrosData3 into .rds file
write_rds(ErrorsData3, "~/.../third_vs_two_thirds/country_results_table_third.rds")

##Reading data
data <- read_rds("~/.../third_vs_two_thirds/country_results_table_third.rds")

##Analysing data
table(summary(data))
#(62*100)/109=56.88%=

##Sum of AE
sum(data$PreN) #10794
#Sum of NE
sum(data$NaiN) #11814

