##Setting working directory
setwd("~/...")

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
ErrorsData <- data.frame(matrix(vector(), 48, 4,
                                dimnames=list(c(), c("yearmonth", "PreN", "NaiN", "Pre_Nai")))) 
#Filling 'yearmonth' variable
ErrorsData$yearmonth <- seq.dates(from = "05/01/2008", "04/30/2012", 
                                  by= "months")
#Converting 'yearmonth' variable to the right format
ErrorsData$yearmonth <- as.numeric(format(as.Date(ErrorsData$yearmonth), '%Y%m'))
#Populating 'PreN' and 'NaiN' columns with zeros
ErrorsData$PreN <- 0
ErrorsData$NaiN <- 0

##Looping over districts forecast files to the caculate the total difference
#between ARFIMA predictions and observed data
forecast <- read_rds("~/.../forecasts_country_OTF.rds")
CalDat <- forecast[88:135, ] #Reading 'test data' forecast data into CalDat
#Calculating 'predicted-n' data
ErrorsData$PreN <- ErrorsData$PreN + abs((CalDat$predicted - CalDat$n))

##Creating a working copy of ErrorsData --> ErrorsData2
ErrorsData2 <- ErrorsData

##Dividing ErrorData$PreN by N (=number of country=1)
#Getting the MAE results per yearmonth unit
ErrorsData2$PreN <- ErrorsData2$PreN / 1

##Looping over districts forecast file to the calculate the total difference
#between Naive predictions and observed data
forecast <- read_rds("~/.../forecasts_country_OTF.rds")
CalDat <- forecast[88:135, ] #Reading 'test data' forecast data into CalDat
#Calculating 'predicted-n' data
ErrorsData2$NaiN <- ErrorsData2$NaiN + abs((CalDat$naive - CalDat$n))


##Creating a working copy of ErrorsData2 --> ErrorsData3
ErrorsData3 <- ErrorsData2

##Dividing ErrorData$NaiN by N (=number of provinces=34)
#Getting the MAE results per yearmonth unit
ErrorsData3$NaiN <- ErrorsData3$NaiN / 1

##Testing whether more ARFIMA MAEs are lower than NAIVE MAEs
ErrorsData3$Pre_Nai <- ErrorsData3$PreN < ErrorsData3$NaiN
##Checking results
table(summary(ErrorsData3$Pre_Nai)) #26 TRUE, 22 FALSE
#(26*100)/48=54.1%

##Writing ErrosData3 into .rds file
write_rds(ErrorsData3, "~/.../country_results_table_OTF.rds")
