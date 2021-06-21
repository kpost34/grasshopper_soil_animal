#load libraries
library(here)
library(readr)
library(vegan)
library(dplyr)


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
#NS (p>0.17 in both)

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
#wrangle data
nema_dens_total<-nema_dens[,c(1:3,10)] #extract cols of interest
total_nema_final<-nema_dens_total %>%  #extract total nema densities at final harvest
  filter(harvest=="F") %>%
  pull()
nema_dens_total<-nema_dens_total %>% #add final total nemas to tibble as a column & remove harvest col
  filter(harvest=="I") %>%
  bind_cols(total_nema_final) %>%
  rename(total_nema_initial="total_nema") %>%
  rename(total_nema_final="...5") %>%
  select(1:2,4:5)
nema_dens_total

#create models
total_nema_mod1<-aov(total_nema_final~total_nema_initial*trmt,data=nema_dens_total)
summary(total_nema_mod1) #trmt significant but interaction is not
total_nema_mod2<-aov(total_nema_final~total_nema_initial+trmt,data=nema_dens_total)
summary(total_nema_mod2) #drop interaction term
anova(total_nema_mod1,total_nema_mod2) #compare the two models, which shows p>.05, thus interaction 
#not significant

#plot result
#STOPPING POINT: PRODUCE PLOT OF THIS--PERHAPS USE ONE OF THOSE CORRELATION PACKAGES
nema_dens_total %>% ggplot(aes(total_nema_initial,total_nema_final))

#NEXT STEPS: univariate analyses of feeding groups, NMDS plots, etc.




