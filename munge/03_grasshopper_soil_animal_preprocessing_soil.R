#load packages
library(here)
library(readxl)
library(tibble)
library(janitor)
library(dplyr)
library(purrr)
library(visdat)
library(skimr)
library(readr)



#***************************
#3-Soil and soil animal data
#***************************

#I. Data import
#**************
initial_soil<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                        skip=1,col_names=TRUE,sheet="Raw Soil-Initial")

final_soil<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                      skip=1,col_names=TRUE,sheet="Raw Soil-Final")

initial_nema<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                        skip=3,n_max=12,col_names=TRUE,sheet="Nematodes")

final_nema<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                      skip=21,n_max=12,col_names=TRUE,sheet="Nematodes")

initial_mite<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                        skip=3,n_max=12,col_names=TRUE, sheet="Mites")

final_mite<-read_xlsx(here("data","raw_data","field_expt_soil_orgs.xlsx"),
                      skip=21,n_max=12,col_names=TRUE,sheet="Mites")


#II. Data cleaning, wrangling, and preprocessing
#***********************************************
#1. Data cleaning and tidying
#A. Soil data
#preliminary data checking
initial_soil #12 x 9; looks reasonable; a couple cols need to be reclassified
final_soil #same as above

#add harvest variable and combine tibbles
initial_soil<-initial_soil %>%
  add_column(harvest=rep("I",12),.after="Plot")
final_soil<-final_soil %>%
  add_column(harvest=rep("F",12),.after="Plot")
soil<-bind_rows(initial_soil,final_soil)

#clean column names
soil<-clean_names(soil)

#display names
names(soil) #plot and soil_can_number are for IDing; harvest indicates start/end of expt; 
#otherwise, these are raw measures needed to mutate to produce variables of interest

#compute soil variables of interest based on raw data, append trmt variable
soil_vars<-soil %>%
  mutate(soil_dryness_prop=(soil_can_lid_dried_soil_g-empty_can_lid_g)/soil_for_moisture_determination_g) %>%
  mutate(nema_dry_soil_kg=(soil_for_nematode_extraction_g*soil_dryness_prop)/1000) %>%
  mutate(mite_dry_soil_kg=((mite_sample_soil_bag_g-mite_sample_bag_only_g)*soil_dryness_prop)/1000) %>%
  mutate(soil_moisture_per=(1-soil_dryness_prop)*100) %>%
  mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) %>%
  select(plot,trmt,harvest,soil_moisture_per,nema_dry_soil_kg,mite_dry_soil_kg)

#reclassify variables
soil_vars$plot<-as.integer(soil_vars$plot)
soil_vars[2:3]<-map(soil_vars[2:3],as.factor)


#B. Nematode data
#preliminary data check
initial_nema #12 x 8; need to reclassify vars
final_nema #same as directly above

#add harvest variable, combine tibbles, and remove cols with low counts
initial_nema<-initial_nema %>%
  add_column(harvest=rep("I",12),.after="Plot")
final_nema<-final_nema %>%
  add_column(harvest=rep("F",12),.after="Plot")
nema<-bind_rows(initial_nema,final_nema)
nema<-nema[,c(1:6,9)]

#clean column names
nema<-clean_names(nema)

#display names
names(nema) #plot is for IDing; harvest indicates start/end of expt; remainder are counts of nematode groups and total nemas

#compute nema density variables of interest based on nema counts and dry soil data, append trmt variable
nema_dens<-nema %>%
  add_column(soil_vars[4:5],.after="harvest") %>%
  mutate(total_nema=total/nema_dry_soil_kg) %>%
  mutate(across(.cols=5:8,~((.x/200)*total_nema))) %>%
  mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) %>%
  mutate(bf_ff=bf/ff) %>%
  select(plot,trmt,harvest,soil_moisture_per,bf,ff,pp,om,bf_ff,total_nema)

#compute nema proportions
nema_prop <- nema %>% 
  mutate(across(.cols=3:6,~((.x/200)))) %>%
  mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) %>%
  select(plot,trmt,harvest,bf,ff,pp,om)

#reclassify variables
#densities
nema_dens$plot<-as.integer(nema_dens$plot)
nema_dens[2:3]<-map(nema_dens[2:3],as.factor)

#proportions
nema_prop$plot<-as.integer(nema_prop$plot)
nema_prop[2:3]<-map(nema_prop[2:3],as.factor)


#C. Mite data
#preliminary data check
initial_mite #12 x 8; last two cols irrelevant; need to reclassify vars
final_mite #same as directly above

#remove irrelevant cols and cols with low counts, add harvest variable, and combine tibbles
initial_mite<-initial_mite[,-c(4:5,7:8)]
final_mite<-final_mite[,-c(4:5,7:8)]
initial_mite<-initial_mite %>%
  add_column(harvest=rep("I",12),.after="Plot")
final_mite<-final_mite %>%
  add_column(harvest=rep("F",12),.after="Plot")
mite<-bind_rows(initial_mite,final_mite)

#clean column names
mite<-clean_names(mite)

#display names
names(mite) #plot is for IDing; harvest indicates start/end of expt; ff and pr are for fungal-feeding and predaceous mites;
#total is for total microarthropods (need to compute total mites as well)

#compute mite variables of interest based on mite counts and dry soil data, append trmt variable
mite_dens<-mite %>%
  rename(ff_mite=ff) %>%
  rename(pr_mite=pr) %>%
  rename(total_marth=total) %>%
  add_column(soil_vars[6],.after="harvest") %>%
  mutate(across(.cols=c("ff_mite","pr_mite","total_marth"),~.x/mite_dry_soil_kg)) %>%
  mutate(total_mite=ff_mite+pr_mite) %>%
  mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) %>%
  select(plot,trmt,harvest,ff_mite,pr_mite,total_mite,total_marth) 

#reclassify variables
mite_dens$plot<-as.integer(mite_dens$plot)
mite_dens[2:3]<-map(mite_dens[2:3],as.factor)

#tibbles of interest
nema_dens #plot, trmt, harvest, and DVs (# per kg dry soil)
nema_prop #plot, trmt, harvest, and DVs (props for 4 feeding groups)
mite_dens #same as above


#2. Missing data assessment
vis_dat(nema_dens) 
vis_dat(nema_prop)
vis_dat(mite_dens) 
vis_miss(nema_dens)
vis_miss(nema_prop)
vis_miss(mite_dens) 
#no missing data


#3. Data checking
#checking data for irregularities
dim(nema_dens); dim(nema_prop); dim(mite_dens) #all seem fine
str(nema_dens); str(nema_prop); str(mite_dens) #all cols coded correctly
head(nema_dens); tail(nema_dens) #look as expected
head(nema_prop); tail(nema_prop) #look as expected
head(mite_dens); tail(mite_dens) #look as expected

map(nema_dens[4:10],range)
map(nema_prop[4:7],range)
map(mite_dens[4:7],range)

#data summaries 
summary(nema_dens)
summary(nema_prop)
summary(mite_dens)

skim(nema_dens)
skim(nema_prop)
skim(mite_dens)


#export tibbles as a .csv
write_csv(nema_dens,here("data","tidy_data","nema_densities.csv"))
write_csv(nema_prop,here("data","tidy_data","nema_proportions.csv"))
write_csv(mite_dens,here("data","tidy_data","mite_densities.csv"))
