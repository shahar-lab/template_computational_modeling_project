
#aim: Hierarchical fit Stan 
rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')


#--------------------------------------------------------------------------------------------------------

# load data
load(paste0(path$data,'/simulate_standata_based_on_artificial_parameters.rdata'))
load(paste0(path$data,'/modelfit_compile.rdata'))

fit<- my_compiledmodel$sample(
  data = data_for_stan, 
  iter_sampling = 500,
  iter_warmup = 200,
  chains           = 2,
  parallel_chains  = 2)  


#save
fit$save_object(paste0(path$data,'/modelfit_based_on_artificial_data.rds'))
