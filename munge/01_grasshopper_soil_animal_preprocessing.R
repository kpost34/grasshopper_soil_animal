#load packages
library(here)
library(readxl)
library(dplyr)
library(purrr)
library(tidyr)





#I. Data import
#**************
gh<-read_xlsx(here("data","raw_data","field_expt_gh.xlsx"),col_names=TRUE)
gh #dates got mangled during read-in of data


#II. Data cleaning, wrangling, and preprocessing
#***********************************************

#1. Data cleaning
#create date vector
dates<-c("2014-09-13","2014-09-19","2014-09-26","2014-10-03","2014-10-10",
         "2014-10-16","2014-10-21")
dates
#replace date headers with it
names(gh)[3:9]<-dates
gh


#2. Reclassify variables
gh$Trmt<-as.factor(gh$Trmt)
gh[c(1,3:9)]<-map(gh[c(1,3:9)],as.integer)


#2. Pivot tibble
gh<-gh %>% pivot_longer()


#1. Preliminary data checking
nrow(titanic); ncol(titanic) #check # of rows/cols
str(titanic) #check classes of variables
head(titanic,n=10); tail(titanic,n=10) #check top/bottom of tibble

#2. Data cleaning
titanic<-clean_names(titanic) #clean names
titanic<-relocate(titanic,survived,before=passenger_id) #rearranges cols
levels(titanic$pclass) #not in numerical order
titanic$pclass<-fct_relevel(titanic$pclass,c("1","2","3"))

#3. Data imputation
#assess missing data
vis_dat(titanic)
vis_miss(titanic)

#4. Data checking
#check n's (using prior knowledge)
range(c_titanic$age,na.rm=T) #0.42-80
range(c_titanic$fare,na.rm=T) #0-512
range(c_titanic$sib_sp) #0-8
range(c_titanic$parch) #0-6
#all seem reasonable


#validate with external data
#from wiki: 24.6% 1st class; 21.5% 2nd class; and 53.8% 3rd class
tabyl(c_titanic,pclass) #24.2%, 20.7%, and 55.1% (seem close)

#from wiki: 66% male and 34% female
tabyl(c_titanic,sex) #64.7% m and 35.2% f (again, close)

#data summaries (with imputed data)
summary(c_titanic)
skim(c_titanic)

#5. Feature engineering











#export tibble as a .csv
write_csv(f_titanic,here("data","tidy_data","[insert_file_name]"))