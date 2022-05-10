rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')

#--------------------------------------------------------------------------------------------------------


rl_fit=readRDS(paste0(path$data,'/modelfit_based_on_empirical_data.rds'))

mypars = c('population_locations[1]',
           'population_locations[2]',
           'population_scales[1]',
           'population_scales[2]')

#Trace plots
mcmc_trace(rl_fit$draws(),pars=mypars)
mcmc_pairs(rl_fit$draws(),pars=mypars)
