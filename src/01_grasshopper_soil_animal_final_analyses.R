#load libraries
library(here)
library(readr)
library(dplyr)
library(nlme)




#IV. Statistical analyses/modeling
#**********************************
#1. Import tidy datasets
tidy_gh<-read_csv(here("data","tidy_data","tidy_gh_data.csv"),col_types="ifDn")

ag_plant_biomass<-read_csv(here("data","tidy_data","ag_plant_biomass.csv"),col_types="ifnnnnn")
bg_plant_biomass<-read_csv(here("data","tidy_data","bg_plant_biomass.csv"),col_types="ifffn")
s_r_data<-read_csv(here("data","tidy_data","s_r_data.csv"),col_types="ifnnn")

mite_dens<-read_csv(here("data","tidy_data","mite_densities.csv"),col_types="iffnnnn")

#2. Analyses
#Grasshopper
#sum counts by plot over all dates
plot_gh<-tidy_gh %>%
  group_by(plot) %>%
  mutate(tot_count=sum(number)) %>%
  select(c(1,2,5)) %>%
  unique()

#create model and residuals object
gh_model<-aov(tot_count~trmt,data=plot_gh)
gh_errors<-residuals(aov(gh_model))

#normality test
plot(gh_model,which=2) #appears normal
shapiro.test(gh_errors) #normality supported by shapiro test (p>0.05)

#test for homogeneity of variance
plot(gh_model,which=1) #appears to have equal variance
leveneTest(tot_count~trmt,data=plot_gh) #supported by Levene's test (p>.05)

#t-test
t.test(tot_count~trmt,var.equal=TRUE,data=plot_gh) 
#significant difference (p<.015); Gh (x-bar: 2.83) > Ex (x-bar: 1.17)



#Aboveground Plant Biomass
#Total ag plant biomass
#create model and residuals object
ag_tot_plant_mod<-aov(tot_ag_plant_g_m2~trmt,data=ag_plant_biomass)
ag_tot_plant_errors<-residuals(ag_tot_plant_mod)

#normality test
plot(ag_tot_plant_mod,which=2)
shapiro.test(ag_tot_plant_errors)
#normal

#homogeneity of variance
plot(ag_tot_plant_mod,which=1) 
leveneTest(tot_ag_plant_g_m2~trmt,data=ag_plant_biomass)
#equal variances

#t-test
t.test(tot_ag_plant_g_m2~trmt,var.equal=TRUE,data=ag_plant_biomass) 
#no significant difference (p>0.5)
#Gh (150.9) and Ex (138.8)


#Fescue biomass
#create model and residuals object
ag_fescue_mod<-aov(fescue_biomass_g_m2~trmt,data=ag_plant_biomass)
ag_fescue_errors<-residuals(ag_fescue_mod)

#normality test
plot(ag_fescue_mod,which=2)
shapiro.test(ag_fescue_errors)
#normal

#homogeneity of variance
plot(ag_fescue_mod,which=1) 
leveneTest(fescue_biomass_g_m2~trmt,data=ag_plant_biomass)
#equal variances

#t-test
t.test(fescue_biomass_g_m2~trmt,var.equal=TRUE,data=ag_plant_biomass) 
#no significant difference (p>0.47)
#Gh (141.7) and Ex (129.7)


#Other grasses biomass
#create model and residuals object
ag_o_grasses_mod<-aov(oth_grasses_g_m2~trmt,data=ag_plant_biomass)
ag_o_grasses_errors<-residuals(ag_o_grasses_mod)

#normality test
plot(ag_o_grasses_mod,which=2)
shapiro.test(ag_o_grasses_errors)
#normal

#homogeneity of variance
plot(ag_o_grasses_mod,which=1) 
leveneTest(oth_grasses_g_m2~trmt,data=ag_plant_biomass)
#equal variances

#t-test
t.test(oth_grasses_g_m2~trmt,var.equal=TRUE,data=ag_plant_biomass) 
#no significant difference (p>0.5984)
#Gh (7.87) and Ex (8.80)



#Shoot-Root Ratio
#create model and residuals object
s_r_mod<-aov(s_r~trmt,data=s_r_data)
s_r_errors<-residuals(s_r_mod)

#normality test
plot(s_r_mod,which=2)
shapiro.test(s_r_errors)
#normal

#homogeneity of variance
plot(s_r_mod,which=1) 
leveneTest(s_r~trmt,data=s_r_data)
#appers unqueal based on graph (although equal with Levene's Test) 

#t-test
t.test(s_r~trmt,var.equal=FALSE,data=s_r_data) 
#no significant difference (p>0.2)
#Gh (0.283) and Ex (0.245)



#Bg Plant Biomass
#remove NA data
which(is.na(bg_plant_biomass$root_g_m2))
bg_plant_biomass_noNA<-bg_plant_biomass[-c(2,4,8),1:5]
bg_plant_biomass_noNA

#create model and residuals object
bg_plant_lme<-lme(fixed=root_g_m2~trmt*location*depth_cm,random=~1|plot/location,
                      data=bg_plant_biomass_noNA)
bg_plant_errors<-residuals(bg_plant_lme)
bg_plant_biomass_errors<-bind_cols(bg_plant_biomass_noNA,tibble(bg_plant_errors))

#test normality assumption
qqnorm(bg_plant_errors); qqline(bg_plant_errors,col="red") 
#appears to deviate from normality at the tails
shapiro.test(bg_plant_errors) #normal (p>.07918)

#homogeneity of variance
plot(bg_plant_lme) #growth in scatter; suggestive of unequal variances
leveneTest(bg_plant_errors~trmt*location*depth_cm,data=bg_plant_biomass_errors) 
#equal using data
#let's tranform given normality and homogeneity of variances issues from plots

#square root transformation
sqrt_bg_biomass<-bind_cols(bg_plant_biomass_noNA[1:4],sqrt(bg_plant_biomass_noNA[5]))

#create model and residuals object
sqrt_bg_plant_lme<-lme(fixed=root_g_m2~trmt*location*depth_cm,random=~1|plot/location,
                       data=sqrt_bg_biomass)

sqrt_bg_errors<-residuals(sqrt_bg_plant_lme)
sqrt_bg_biomass_errors<-bind_cols(sqrt_bg_biomass,tibble(sqrt_bg_errors))

#test normality assumption
qqnorm(sqrt_bg_errors); qqline(sqrt_bg_errors,col="red")
shapiro.test(sqrt_bg_errors) 
#appears more normal based on qq plot and shapiro test

#homogeneity of variance
plot(sqrt_bg_plant_lme) #appears equal (with some outliers)
leveneTest(sqrt_bg_errors~trmt*location*depth_cm,data=sqrt_bg_biomass_errors) #equal

#run model
#NOTE: can't use aov() due to unbalanced design (i.e., missing data)
sqrt_aov_bg_mod<-aov(root_g_m2~trmt*location*depth_cm+
                       Error(plot/location),data=sqrt_bg_biomass)
summary(sqrt_aov_bg_mod) #incorrect error structure (factors B & C should not be
#part of plot error)

#mixed-effects model
sqrt_bg_plant_lme
summary(sqrt_bg_plant_lme) #problem: singularity; lack of variance in intercept
anova(sqrt_bg_plant_lme,type="marginal") #depth is significant; nothing else is



#Soil Organisms
#Soil mites
mite_dens

#create rmANOVA models
ff_mite_mod<-aov(ff_mite~trmt*harvest+Error(as.factor(plot)),data=mite_dens)
summary(ff_mite_mod)

pr_mite_mod<-aov(pr_mite~trmt*harvest+Error(as.factor(plot)),data=mite_dens)
summary(pr_mite_mod)

total_mite_mod<-aov(total_mite~trmt*harvest+Error(as.factor(plot)),data=mite_dens)
summary(total_mite_mod)

total_marth_mod<-aov(total_marth~trmt*harvest+Error(as.factor(plot)),data=mite_dens)
summary(total_marth_mod)

#test normality assumption
#extract residuals
ff_mite_pr<-proj(ff_mite_mod)
ff_mite_resids<-ff_mite_pr[[3]][,"Residuals"]

pr_mite_pr<-proj(pr_mite_mod)
pr_mite_resids<-pr_mite_pr[[3]][,"Residuals"]

total_mite_pr<-proj(total_mite_mod)
total_mite_resids<-total_mite_pr[[3]][,"Residuals"]

total_marth_pr<-proj(total_marth_mod)
total_marth_resids<-total_marth_pr[[3]][,"Residuals"]


#test normality assumption
#ff mites
qqnorm(ff_mite_resids); qqline(ff_mite_resids,col="red") 
shapiro.test(ff_mite_resids)
qqPlot(ff_mite_resids)
#non-normal due to outlier
#re-test without outlier
qqnorm(ff_mite_resids[-c(7,19)]); qqline(ff_mite_resids[-c(7,19)],col="red")
shapiro.test(ff_mite_resids[-c(7,19)])
#still have normality issues even when removing 2/24 data points

#remaining groups
qqPlot(pr_mite_resids)
shapiro.test(pr_mite_resids) 

qqPlot(total_mite_resids)
shapiro.test(total_mite_resids) 

qqPlot(total_marth_resids)
shapiro.test(total_marth_resids) 
#same with other three groups


#data transformation
#log 
mite_dens_log<-bind_cols(mite_dens[1:3],tibble(log(mite_dens[4:7])))

#ff mite
ff_mite_log_mod<-aov(ff_mite~trmt*harvest+Error(as.factor(plot)),data=mite_dens_log)
summary(ff_mite_log_mod)
ff_mite_log_pr<-proj(ff_mite_log_mod)
ff_mite_log_resids<-ff_mite_log_pr[[3]][,"Residuals"]

qqnorm(ff_mite_log_resids); qqline(ff_mite_log_resids,col="red") 
shapiro.test(ff_mite_log_resids)
qqPlot(ff_mite_log_resids)
#normal

#pr mite
pr_mite_log_mod<-aov(pr_mite~trmt*harvest+Error(as.factor(plot)),data=mite_dens_log)
summary(pr_mite_log_mod)
pr_mite_log_pr<-proj(pr_mite_log_mod)
pr_mite_log_resids<-pr_mite_log_pr[[3]][,"Residuals"]

qqnorm(pr_mite_log_resids); qqline(pr_mite_log_resids,col="red") 
shapiro.test(pr_mite_log_resids)
qqPlot(pr_mite_log_resids)
#normality issues


#sqrt
mite_dens_sqrt<-bind_cols(mite_dens[1:3],tibble(sqrt(mite_dens[4:7])))
#ff mite
ff_mite_sqrt_mod<-aov(ff_mite~trmt*harvest+Error(as.factor(plot)),data=mite_dens_sqrt)
summary(ff_mite_sqrt_mod)
ff_mite_sqrt_pr<-proj(ff_mite_sqrt_mod)
ff_mite_sqrt_resids<-ff_mite_sqrt_pr[[3]][,"Residuals"]

qqnorm(ff_mite_sqrt_resids); qqline(ff_mite_sqrt_resids,col="red") 
shapiro.test(ff_mite_sqrt_resids)
qqPlot(ff_mite_sqrt_resids)
#normal

#pr mite
pr_mite_sqrt_mod<-aov(pr_mite~trmt*harvest+Error(as.factor(plot)),data=mite_dens_sqrt)
summary(pr_mite_sqrt_mod)
pr_mite_sqrt_pr<-proj(pr_mite_sqrt_mod)
pr_mite_sqrt_resids<-pr_mite_sqrt_pr[[3]][,"Residuals"]

qqnorm(pr_mite_sqrt_resids); qqline(pr_mite_sqrt_resids,col="red") 
shapiro.test(pr_mite_sqrt_resids)
qqPlot(pr_mite_sqrt_resids)
#normality issues

#arc sin
mite_dens_asub<-bind_cols(mite_dens[1:3],tibble(asin(mite_dens[4:7]))) #NaNs produced
#not applicable for these data

#given issues with normality, even after transformations, use non-parametric test

#Wilcoxon tests
wilcox.test(ff_mite~trmt,data=mite_dens)
wilcox.test(pr_mite~trmt,data=mite_dens)
wilcox.test(total_mite~trmt,data=mite_dens)
wilcox.test(total_marth~trmt,data=mite_dens)
#non-significant differences




