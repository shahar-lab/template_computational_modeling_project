#This code plot recovered parameters against the true parameters

rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')


#--------------------------------------------------------------------------------------------------------
library(ggplot2)
library(ggpubr)
library(bayestestR)
library(stringr)

#population level parameters
load(paste0(path$data,'/simulate_population_parameters.Rdata'))
rl_fit=readRDS(paste0(path$data,'/modelfit_based_on_artificial_data.rds'))

my_posteriorplot(x       = plogis(rl_fit$draws(variables ='population_locations[1]',
                                               format='draws_matrix')),
                     myxlim  = c(0,1),
                     my_vline= plogis(population_parameters[[2]][1]), 
                     myxlab  = expression(alpha['location']),
                     mycolor = "pink")


my_posteriorplot(x       = rl_fit$draws(variables ='population_locations[2]',
                                        format='draws_matrix'),
                     myxlim  = c(0.5,5),
                     my_vline= population_parameters[[2]][2], 
                     myxlab  = expression(beta['location']),
                     mycolor = "pink")


#-------------------------------------------------------------------------------------------------------------
# individual level parameters
load(paste0(path$data,'/simulate_individual_parameters.Rdata'))

my_xyplot(individual_parameters[,'alpha'],apply(rl_fit$draws(variables ='alpha',format='draws_matrix'), 2, mean),'true','recovered','navy')
my_xyplot(individual_parameters[,'beta'], apply(rl_fit$draws(variables ='beta' ,format='draws_matrix'), 2, mean),'true','recovered','navy')

