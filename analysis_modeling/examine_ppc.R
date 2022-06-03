#This code plot posterior predictive checks


rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')


#--------------------------------------------------------------------------------------------------------
library(bayesplot)

#load stan object
fit=readRDS(paste0(path$data,'/modelfit_based_on_artificial_data.rds'))
load(paste0(path$data,'/simulate_data_based_on_artificial_parameters.Rdata'))

#extract y_rep
y_rep=rl_fit$draws(variables ='y_rep',format='draws_matrix')


ppc_stat_grouped(df$selected_offer, y_rep,df$selected_offer,
                   freq=F,
                 xlim=c(0,1))
