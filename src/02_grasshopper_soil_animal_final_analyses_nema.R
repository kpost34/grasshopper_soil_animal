#load libraries
library(here)
library(readr)
library(vegan)
library(dplyr)



#Analyses
#nema dens and props: rm perMANOVA using B-C dissimilarity index
#changes in dens & props WERE analyzed with t-tests (on change data)
#--> consider ANCOVAs


#IV. Statistical analyses/modeling
#**********************************
#1. Import tidy datasets
nema_dens<-read_csv(here("data","tidy_data","nema_densities.csv"),col_types="iffnnnnnnn")
nema_prop<-read_csv(here("data","tidy_data","nema_proportions.csv"),col_types="iffnnnn")

#2. Nematode Analyses
#A. Densities
#create tibbles of interest
nema_feed<-nema_dens[-c(4,9:10)] %>% #plot, trmt, harvest, and feeding groups sorted
  arrange(harvest,trmt)
nema_feed$plot<-as.factor(nema_feed$plot)
nema_troph<-nema_feed[4:7] #tibble without plot, trmt, harvest
nema_troph_bc<-vegdist(nema_troph) #bray-curtis dissimilarity indices

#create factors
exclude<-pull(nema_feed,2)
samp<-pull(nema_feed,3)
exclude_samp<-as.factor(rep(c("ig","ie","fg","fe"),each=6))
reps<-as.factor(nema_feed$plot)

#beta dispersions
#cage effect
nema_disper_exclude<-betadisper(nema_troph_bc,exclude)
anova(nema_disper_exclude)
permutest(nema_disper_exclude)
#NS (p>0.96 in both)

#harvest
nema_disper_samp<-betadisper(nema_troph_bc,samp)
anova(nema_disper_samp)
permutest(nema_disper_samp)
#NS (p>0.7 in both)

#cage and harvest
nema_disper_exclude_samp<-betadisper(nema_troph_bc,exclude_samp)
anova(nema_disper_exclude_samp)
permutest(nema_disper_exclude_samp)
#NS (p>0.92 in both)

#homogeneity assumption met

#create model
nema_dens_mod<-adonis(nema_troph_bc~trmt*harvest+plot,strata=pull(nema_feed,plot),data=nema_feed,permutations=999)
nema_dens_mod
#time is significant, but herbivory*time is not; herbivory p-val uses wrong error term

#B. Proportions
#create tibbles of interest

#STARTING POINT
nema_prop_feed<-arrange(nema_prop,harvest,trmt) #arrange nema prop data
nema_prop_feed$plot<-as.factor(nema_prop_feed$plot)
nema_prop_troph<-nema_prop_feed[4:7] #tibble without plot, trmt, harvest
nema_prop_troph_bc<-vegdist(nema_prop_troph) #bray-curtis dissimilarity indices

#create factors
p_exclude<-pull(nema_prop_feed,2)
p_samp<-pull(nema_prop_feed,3)
p_exclude_samp<-as.factor(rep(c("ig","ie","fg","fe"),each=6))
p_reps<-as.factor(nema_prop_feed$plot)

#beta dispersions
#cage effect
nema_prop_disper_exclude<-betadisper(nema_prop_troph_bc,p_exclude)
anova(nema_prop_disper_exclude)
permutest(nema_prop_disper_exclude)
#NS (p>0.21 in both)

#harvest
nema_prop_disper_samp<-betadisper(nema_prop_troph_bc,p_samp)
anova(nema_prop_disper_samp)
permutest(nema_prop_disper_samp)
#NS (p>0.2 in both)

#cage and harvest
nema_prop_disper_exclude_samp<-betadisper(nema_prop_troph_bc,p_exclude_samp)
anova(nema_prop_disper_exclude_samp)
permutest(nema_prop_disper_exclude_samp)
#NS (p>0.47 in both)

#homogeneity assumption met

#create model
nema_prop_mod<-adonis(nema_prop_troph_bc~trmt*harvest+plot,strata=pull(nema_prop_feed,plot),
                      data=nema_prop_feed,permutations=999)
nema_prop_mod
#time is significant, but herbivory*time is not; herbivory p-val uses wrong error term


#Univariate tests
#Total nematode



#BF:FF





