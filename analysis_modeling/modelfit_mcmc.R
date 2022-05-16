#aim: Hierarchical fit Stan 
rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')

#--------------------------------------------------------------------------------------------------------

#load data
load(paste0(path$data,'/simulate_standata_based_on_artificial_parameters.rdata'))
load(paste0(path$data,'/modelfit_compile.rdata'))

{
  start_time <- Sys.time()

    rl_fit<- my_compiledmodel$sample(
                data = data_for_stan, 
                iter_sampling = 1000,
                iter_warmup = 1000,
                chains = 4,
                parallel_chains = 4) 

  end_time <- Sys.time()
  end_time-start_time
}

#save
saveRDS(rl_fit, paste0(path$data,'/modelfit_based_on_empirical_data.rds'))

pars <- as_draws_df(rl_fit$draws())
save(pars, file=paste0(path$data,'/modelfit_based_on_artificial_data.rdata'))



