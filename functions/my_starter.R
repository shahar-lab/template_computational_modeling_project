#load project packages
library(cmdstanr)
library(posterior)
library(loo)
library(doParallel)
library(bayesplot)
library(ggplot2)
library(dplyr)
library(tidyr)
library(gridExtra)
library(svDialogs)
library(ggdist)
library(ggpubr)
library(ramify)

source('./stan_modeling/functions/simulate_parameters.R')
source('./stan_modeling/functions/simulate_create_artifical_data.R')
source('./stan_modeling/functions/simulate_convert_to_stan_format.R')
source('./stan_modeling/functions/modelfit_compile.R')
source('./stan_modeling/functions/modelfit_mcmc.R')
source('./stan_modeling/functions/examine_mcmc.R')
source('./stan_modeling/functions/examine_population_parameters_recovery.R')
source('./stan_modeling/functions/examine_individual_parameters_recovery.R')

source('./functions/set_workingmodel.r')
source('./functions/add_workingmodel.r')
source('./functions/my_xyplot.R')
source('./functions/remove_workingmodel.r')
source('./functions/run_fit.r')
source('./functions/generate_individual_parameters.r')
source('./functions/plot_artificial_parameters.r')
source('./functions/set_datatype.r')





