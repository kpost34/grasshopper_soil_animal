#load packages
library(here)
library(readxl)
library(janitor)
library(lubridate)
library(tidyr)
library(visdat)
library(skimr)
library(readr)



#******************
#1-Grasshopper data
#******************

#I. Data import
#**************
gh<-read_xlsx(here("data","raw_data","field_expt_gh.xlsx"),col_names=TRUE)
gh #dates got mangled during read-in of data


#II. Data cleaning, wrangling, and preprocessing
#***********************************************

#1. Data cleaning
#clean_names
gh<-clean_names(gh)
#create date vector
dates<-c("2014-09-13","2014-09-19","2014-09-26","2014-10-03","2014-10-10",
         "2014-10-16","2014-10-21")
#replace date headers with it
names(gh)[3:9]<-dates


#2. Reshape data
#convert to wide format
gh<-gh %>% pivot_longer(cols=3:9,names_to="date",values_to="number")
#reclassify variables
gh$trmt<-as.factor(gh$trmt)
gh$date<-ymd(gh$date)
gh$number<-as.integer(gh$number)

tidy_gh<-gh

#3. Preliminary data checking
nrow(tidy_gh); ncol(tidy_gh) #check # of rows/cols; 84=12 (plots) * 7 (dates)
str(tidy_gh) #check classes of variables; they check out
levels(tidy_gh$trmt) #check factor levels; they check out
head(tidy_gh,n=10); tail(tidy_gh,n=10) #check top/bottom of tibble


#4. Missing data assessment
vis_dat(tidy_gh)
vis_miss(tidy_gh)
#no missing data


#5. Data checking
#check n's (using prior knowledge)
range(tidy_gh$date) #2014-09-13 to 2014-10-21, which are correct range of dates
range(tidy_gh$number) #0-2, which is correct


#data summaries 
summary(tidy_gh)
skim(tidy_gh)

#export tibble as a .csv
write_csv(tidy_gh,here("data","tidy_data","tidy_gh_data.csv"))
