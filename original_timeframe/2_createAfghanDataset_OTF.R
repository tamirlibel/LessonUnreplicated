##Setting working directory
setwd("~/...")

##Loading libraries
library(readr)
library(dplyr)
library(tidylog)

##Setting seed
set.seed(2021)

##loading data
afg_data <- read_rds("~/.../afg_working_data_q4.rds")

##EDA
glimpse(afg_data)
unique(afg_data$year)#1995-2021 are covered


##Subseting the original timeframe
afg_otf <- afg_data %>%
  filter(yearmonth > 200101 & yearmonth < 201205)
#EDA
glimpse(afg_otf)
min(afg_otf$yearmonth)
max(afg_otf$yearmonth)

#Write afg_otf into rds data file
write_rds(afg_otf, "afg_working_data_q4_otf.rds")
