# Aim: Run some basic sanity checks using linear / logistic regression
rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')

#--------------------------------------------------------------------------------------------------------


load(paste0(path$data,'/simulate_data_based_on_empirical_parameters.rdara'))
load(paste0(path$data,'/simulate_data_based_on_artificial_parameters.rdata'))



df=df%>%mutate(stay                  =(choice==lag(choice)),
               reward_oneback         =lag(reward))
               


model= glmer(stay ~ reward_oneback+(reward_oneback| subject), 
             data = df,
             family = binomial,
             control = glmerControl(optimizer = "bobyqa"), nAGQ = 0)

