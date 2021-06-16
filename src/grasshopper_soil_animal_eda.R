#load packages
library(here)
library(readr)
library(dplyr)
library(ggplot2)
library(PerformanceAnalytics)
library(GGally)





#III. Data exploration/visualization
#**********************************
#1. Import tidy datasets
tidy_gh<-read_csv(here("data","tidy_data","tidy_gh_data.csv"),col_types="ifDn")

ag_plant_biomass<-read_csv(here("data","tidy_data","ag_plant_biomass.csv"),col_types="ifnnnnn")
bg_plant_biomass<-read_csv(here("data","tidy_data","bg_plant_biomass.csv"),col_types="ifffn")
s_r_data<-read_csv(here("data","tidy_data","s_r_data.csv"),col_types="ifnnn")

nema_dens<-read_csv(here("data","tidy_data","nema_densities.csv"),col_types="iffnnnnnnn")
nema_prop<-read_csv(here("data","tidy_data","nema_proportions.csv"),col_types="iffnnnn")
mite_dens<-read_csv(here("data","tidy_data","mite_densities.csv"),col_types="iffnnnn")


#2. Plots
#Grasshopper
#***********
#changes in numbers for each plot over time separated by trmt
tidy_gh %>% 
  ggplot(aes(x=date,y=number)) +
  geom_path(aes(linetype=as.factor(plot),color=trmt)) +
  facet_wrap(vars(trmt)) +
  theme(legend.position="none")
#appears that Gh plots had more grasshopper activity than Ex plots

tidy_gh %>%
  group_by(date,trmt) %>%
  summarize(avg_number=mean(number)) %>%
  ggplot(aes(date,avg_number)) +
  geom_path(aes(color=trmt))
#above statement supported when looking at averages



#Plants
#*****
#function to use in wrapper function to produce regression lines
my_fn <- function(data, mapping, method="loess", ...){
  p <- ggplot(data = data, mapping = mapping) + 
    geom_point() + 
    geom_smooth(method=method, ...)
  p
}


#Aboveground Biomass
#correlations among fescue, other grasses (B.g.), and forbs separated by trmt
ag_plant_biomass %>%
  ggpairs(aes(color=trmt,alpha=0.5),columns=3:5,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#nothing statistically significant
#ex: + corrs for all combinations
#other grasses-forbs: opposing directions of correlation

#total ag biomass by trmt
ag_plant_biomass %>% ggplot(aes(x=trmt,y=tot_ag_plant_g_m2,fill=trmt)) + 
  stat_summary(geom="bar",position="dodge",fun=mean) +
  stat_summary(geom="errorbar",position="dodge",fun.data=mean_se) +
  scale_fill_manual(values=c("steelblue","darkred"))
#more total shoot biomass in Gh plots than Ex plots


#Belowground Biomass
#root biomass separated by treatment and location (bare vs. plant area)
bg_plant_biomass %>% ggplot(aes(x=trmt,y=root_g_m2,fill=location)) + 
  stat_summary(geom="bar",position="dodge",fun=mean) +
  stat_summary(geom="errorbar",position="dodge",fun.data=mean_se) +
  scale_fill_manual(values=c("steelblue","darkred"))
#more root biomass in B than P and similar between trmts

#root biomass separated by treatment and depth (0-10 and 10-20 cm)
bg_plant_biomass %>% ggplot(aes(x=trmt,y=root_g_m2,fill=depth_cm)) + 
  stat_summary(geom="bar",position="dodge",fun=mean) +
  stat_summary(geom="errorbar",position="dodge",fun.data=mean_se) +
  scale_fill_manual(values=c("steelblue","darkred"),name="Depth (cm)",labels=c("0-10 cm","10-20 cm"))
#more root biomass in shallower soils; more in 0-10 for Gh than Ex but opposite pattern in 10-20 cm


#Shoot-Root
#look correlations between shoot & root biomass overall and by trmt
s_r_data %>%
  ggpairs(aes(color=trmt,alpha=0.5),columns=3:4,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE)))
#positive corr overall and both trmts
#ss correlation for Ex plots and overall

#look at avg s:r between trmts
s_r_data %>% ggplot(aes(x=trmt,y=s_r,fill=trmt)) + 
  stat_summary(geom="bar",position="dodge",fun=mean) +
  stat_summary(geom="errorbar",position="dodge",fun.data=mean_se) +
  scale_fill_manual(values=c("steelblue","darkred"))
#Gh plots had higher avg



#Soil
#****
#Soil Moisture
#compare soil moisture between trmts for initial and final harvests
nema_dens %>% ggplot(aes(x=trmt,y=soil_moisture_per,fill=harvest)) + 
  stat_summary(geom="bar",position="dodge",fun=mean) +
  stat_summary(geom="errorbar",position="dodge",fun.data=mean_se) +
  scale_fill_manual(values=c("steelblue","darkred"))
#similar b/t trmts but much greater at expt end


#Nematode Densities
#nematode feeding groups: initial harvest
nema_dens %>% 
  filter(harvest=="I") %>%
  ggpairs(aes(color=trmt,alpha=0.5),columns=5:8,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#two significant correlations: pp-ff: + for all data points & pp-om: + for all & Ex data
#divergent patterns (+ in GH & - in Ex) for all bf correlations

#final harvest
nema_dens %>% 
  filter(harvest=="F") %>%
  ggpairs(aes(color=trmt,alpha=0.5),columns=5:8,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#one ss correlation: - corr b/t ff & om for Gh

#change for each treatment
#grasshopper
nema_dens %>% 
  filter(trmt=="Gh") %>%
  ggpairs(aes(color=harvest,alpha=0.5),columns=5:8,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))

#exclosure
nema_dens %>% 
  filter(trmt=="Ex") %>%
  ggpairs(aes(color=harvest,alpha=0.5),columns=5:8,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#from both sets of plots, the largest takeaway is the shifts in densities from greater to smaller

#total nematodes
nema_dens %>% ggplot(aes(x=trmt,y=total_nema,fill=harvest)) + 
  stat_summary(geom="bar",position="dodge",fun=mean) +
  stat_summary(geom="errorbar",position="dodge",fun.data=mean_se) +
  scale_fill_manual(values=c("steelblue","darkred"))
#reduction in both trmts from initial to final harvest

#bf:ff
nema_dens %>% ggplot(aes(x=trmt,y=bf_ff,fill=harvest)) + 
  stat_summary(geom="bar",position="dodge",fun=mean) +
  stat_summary(geom="errorbar",position="dodge",fun.data=mean_se) +
  scale_fill_manual(values=c("steelblue","darkred"))
#growth in ratio for Gh plots but little change in Ex plots


#Nematode Proportions
#nematode feeding groups: initial harvest
nema_prop %>% 
  filter(harvest=="I") %>%
  ggpairs(aes(color=trmt,alpha=0.5),columns=4:7,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))

#final harvest
nema_prop %>% 
  filter(harvest=="F") %>%
  ggpairs(aes(color=trmt,alpha=0.5),columns=4:7,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#no corr by trmt ss (bf-om - corr for all data)

#change for each treatment
#grasshopper
nema_prop %>% 
  filter(trmt=="Gh") %>%
  ggpairs(aes(color=harvest,alpha=0.5),columns=4:7,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#no ss corr for specific harvest; om-ff - corr for all Gh data

#exclosure
nema_prop %>% 
  filter(trmt=="Ex") %>%
  ggpairs(aes(color=harvest,alpha=0.5),columns=4:7,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#om-bf - corr for I harvest within Ex plots
#bf-om and bf-pp - corr for all harvest data within Ex plots


#Mites
mite_dens %>% 
  filter(harvest=="I") %>%
  ggpairs(aes(color=trmt,alpha=0.5),columns=4:5,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#no significant correlation

mite_dens %>% 
  filter(harvest=="F") %>%
  ggpairs(aes(color=trmt,alpha=0.5),columns=4:5,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#not ss; slightly + corr for both trmts; an outlier for Ex trmt

mite_dens %>% 
  filter(trmt=="Gh") %>%
  ggpairs(aes(color=harvest,alpha=0.5),columns=4:5,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#no ss corrs; divergent patterns: + for F and slightly - for I

mite_dens %>% 
  filter(trmt=="Ex") %>%
  ggpairs(aes(color=harvest,alpha=0.5),columns=4:5,
          lower=list(continuous=wrap(my_fn,method="lm",se=TRUE,alpha=0.2)))
#similar to above

#total mites
mite_dens %>% ggplot(aes(x=trmt,y=total_mite,fill=harvest)) + 
  stat_summary(geom="bar",position="dodge",fun=mean) +
  stat_summary(geom="errorbar",position="dodge",fun.data=mean_se) +
  scale_fill_manual(values=c("steelblue","darkred"))
#almost no change for Gh trmt but growth for Ex trmt

#total microarthropods
mite_dens %>% ggplot(aes(x=trmt,y=total_marth,fill=harvest)) + 
  stat_summary(geom="bar",position="dodge",fun=mean) +
  stat_summary(geom="errorbar",position="dodge",fun.data=mean_se) +
  scale_fill_manual(values=c("steelblue","darkred"))
#similar pattern

