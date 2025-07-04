source('./functions/check_packages.r')


#load project packages
library(cmdstanr)
library(brms)
library(splines)
library(faux)
library(posterior)
library(loo)
library(doParallel)
library(foreach)
library(bayesplot)
library(ggplot2)
library(dplyr)
library(tidyr)
library(gridExtra)
library(grid)
library(svDialogs)
library(ggdist)
library(ggpubr)
library(ramify)
library(pROC)
library(patchwork)

source('./stan_modeling/functions/simulate_parameters.R')
source('./stan_modeling/functions/simulate_create_artifical_data.R')
source('./stan_modeling/functions/convert_to_stan_format.R')
source('./stan_modeling/functions/modelfit_compile.R')
source('./stan_modeling/functions/modelfit_mcmc.R')
source('./stan_modeling/functions/modelfit_compile_loo.R')
source('./stan_modeling/functions/modelfit_mcmc_loo.R')
source('./stan_modeling/functions/examine_mcmc.R')
source('./stan_modeling/functions/examine_population_parameters_recovery.R')
source('./stan_modeling/functions/examine_individual_parameters_recovery.R')
source('./stan_modeling/functions/compare_models.R')
source('./stan_modeling/functions/get_df.R')
source('./stan_modeling/functions/get_parameters.R')
source('./stan_modeling/functions/generate_individual_parameters.r')

source('./functions/set_workingmodel.r')
source('./functions/add_workingmodel.r')
source('./functions/my_xyplot.R')
source('./functions/remove_workingmodel.r')
source('./functions/run_fit.r')
source('./functions/plot_artificial_parameters.r')
source('./functions/set_datatype.r')
source('./functions/set_data.r')
source('./functions/create_penalty_matrix.r')







