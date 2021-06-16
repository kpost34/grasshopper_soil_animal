#load packages
library(here)
library(readxl)
library(tidyr)
library(dplyr)
library(janitor)
library(forcats)
library(purrr)
library(visdat)
library(skimr)
library(readr)


#****************
#2-Plant data
#****************

#I. Data import
#**************
ag_plant<-read_xlsx(here("data","raw_data","field_expt_plant.xlsx"),col_names=TRUE,
                    sheet="Aboveground-total")

ag_plant_groups<-read_xlsx(here("data","raw_data","field_expt_plant.xlsx"),col_names=TRUE,
                           sheet="Aboveground-functional groups")

bg_plant<-read_xlsx(here("data","raw_data","field_expt_plant.xlsx"),col_names=TRUE,
                    sheet="Belowground-new")


#II. Data cleaning, wrangling, and preprocessing
#***********************************************

#1. Data cleaning and tidying
#A. Aboveground plant biomass
#preliminary data checking
dim(ag_plant) #check 34 x 5, which seems correct
str(ag_plant) #check classes of variables; need to change some eventually
head(ag_plant,n=10); tail(ag_plant,n=10) #preview data--need to fill; other NAs expected

dim(ag_plant_groups) #12 x 4; 12 plots and 4 variables
str(ag_plant_groups) #check classes of variables; need to change plot # eventually
ag_plant_groups #data look fine

#clean column names
#create character vector of col names
ag_plant_names<-c("plot","bag","biomass_bag_washers_g","bag_washers_g","measured_biomass_g")
names(ag_plant)<-ag_plant_names #append to tibble

ag_plant_groups<-clean_names(ag_plant_groups)

#display names
names(ag_plant) #plot and bag #s, measurements of plant biomass w/bag & washers, w/b & w alone,
#and directly measured plant biomass
names(ag_plant_groups) #simply plot # and biomass of three plant types

#fill in empty cells
ag_plant<-fill(ag_plant,plot)

#rename, compute, eliminate, and reclassify variables
#compute 'calculated' biomass from subtraction
ag_plant<-ag_plant %>%
  mutate(calc_biomass_g=biomass_bag_washers_g-bag_washers_g) #calculate biomass
ag_plant$calc_biomass_g[29:34]<-NA #replace values with NA where biomass directly measured
#create algorithm where ag_biomass is based on directly measured or computed biomass
ag_plant<-ag_plant %>%
  mutate(ag_biomass_g=ifelse(!is.na(measured_biomass_g),measured_biomass_g,calc_biomass_g))
#reclassify variables
ag_plant[1:2]<-map(ag_plant[1:2],as.integer) #convert plot and bag cols to integers
#sum by plot
ag_plant_by_plot<-ag_plant %>%
  group_by(plot) %>%
  summarize(tot_ag_biomass_g=sum(ag_biomass_g)) %>%
  ungroup() %>%
  mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) #add treatment col

#rename and reclassify cols 
ag_plant_by_plot$trmt<-as.factor(ag_plant_by_plot$trmt)
names(ag_plant_groups)[1]<-"plot"
ag_plant_groups$plot<-as.integer(ag_plant_groups$plot)

#join ag plant tibbles and create fescue biomass col
ag_plant_biomass<-inner_join(ag_plant_by_plot,ag_plant_groups,by="plot") %>%
  mutate(fescue_biomass=tot_ag_biomass_g-(other_grasses_g+forbs_g+shrubs_g)) %>% #create fescue col
  select(plot,trmt,fescue_biomass,other_grasses_g,forbs_g,shrubs_g,tot_ag_biomass_g) %>% #reorder using select
  mutate(across(fescue_biomass:tot_ag_biomass_g,~.x/0.49487)) #convert to biomass per m^2

#rename cols
ag_plant_dens_names<-c("fescue_biomass_g_m2","oth_grasses_g_m2","forbs_g_m2",
                       "shrubs_g_m2","tot_ag_plant_g_m2")
names(ag_plant_biomass)[3:7]<-ag_plant_dens_names

#B. Belowground plant biomass
#preliminary data check
dim(bg_plant) #check 45 x 7: indicates some missing rows (as a multiple of 12 expected)
str(bg_plant) #check classes of variables; some need to change some eventually
head(bg_plant,n=10); tail(bg_plant,n=10) #seems like plots 1 & 2 for location P are missing

#clean and view names
bg_plant<-clean_names(bg_plant)
bg_plant #includes plot, location, depth, and masses of the crucible, plant+crucible, and plant+ash (after burning)

#compute root biomass and root biomass density
bg_plant_biomass<-bg_plant %>% 
  rename(plot=plot_number) %>%
  mutate(trmt=ifelse(plot %in% c(1,3,5,8,9,11),"Gh","Ex")) %>% #assign trmts
  mutate(root_g_m2=(crucible_plant_g-crucible_ash_g)*315.764039) %>% #calculate root biomass & convert to g/m^2
  select(plot,trmt,location,depth_cm,root_g_m2) %>%
  add_row(plot=c(1,1,2),trmt=c("Gh","Gh","Ex"),location=c("B","P","P"), #add NAs
          depth_cm=c("10-20","10-20","10-20"),root_g_m2=rep(NA,3)) %>%
  arrange(plot,location,depth_cm) #sort data
bg_plant_biomass

#reclassify variables
bg_plant_biomass$plot<-as.integer(bg_plant_biomass$plot)
bg_plant_biomass[2:4]<-map(bg_plant_biomass[2:4],as.factor)
bg_plant_biomass$depth_cm<-fct_recode(bg_plant_biomass$depth_cm,`10`="0-10",`20`="10-20") 
#recode depth levels to make it easier 


#calculate shoot:root values
#sum and avg root biomass for each plot 
tot_root_biomass<-bg_plant_biomass %>%
  group_by(plot,trmt) %>%
  summarize(tot_root_g_m2=sum(root_g_m2/2)) #take average value based on bare and plant locations

#compute s:r data
s_r_data<-bind_cols(ag_plant_biomass[c(1,2,7)],tot_root_biomass[3]) %>%
  mutate(s_r=tot_ag_plant_g_m2/tot_root_g_m2)

#tibbles of interest
ag_plant_biomass #shoot biomass (g/m^2) by trmt, plot, and plant type
bg_plant_biomass #root biomass (g/m^2) by plot, trmt, location, and depth
s_r_data #shoot:root by plot and trmt


#2. Missing data assessment
vis_dat(ag_plant_biomass) #0 NAs
vis_dat(bg_plant_biomass) #3 NAs; expected
vis_dat(s_r_data); vis_miss(s_r_data) #2 cols with a few values each
#missing data expected


#3. Data checking
#checking data for irregularities
dim(ag_plant_biomass); dim(bg_plant_biomass); dim(s_r_data) #all seem fine
str(ag_plant_biomass); str(bg_plant_biomass); str(s_r_data) #all cols coded correctly
ag_plant_biomass
s_r_data
head(bg_plant_biomass,n=10); tail(bg_plant_biomass,n=10) #look as expected

range(ag_plant_biomass$tot_ag_plant_g_m2) 
range(bg_plant_biomass$root_g_m2,na.rm=TRUE) 
range(s_r_data$s_r,na.rm=TRUE)
#all look fine

#data summaries 
summary(ag_plant_biomass)
summary(bg_plant_biomass)
summary(s_r_data)

skim(ag_plant_biomass)
skim(bg_plant_biomass)
skim(s_r_data)

#export tibbles as a .csv
write_csv(ag_plant_biomass,here("data","tidy_data","ag_plant_biomass.csv"))
write_csv(bg_plant_biomass,here("data","tidy_data","bg_plant_biomass.csv"))
write_csv(s_r_data,here("data","tidy_data","s_r_data.csv"))


