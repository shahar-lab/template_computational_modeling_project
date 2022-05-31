#aim: Hierarchical fit Stan 
rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')

#--------------------------------------------------------------------------------------------------------

# load data
load(paste0(path$data,'/simulate_standata_based_on_artificial_parameters.rdata'))
load(paste0(path$data,'/modelfit_compile.rdata'))

{
  start_time <- Sys.time()
  
  rl_fit<- my_compiledmodel$sample(
    data = data_for_stan, 
    iter_sampling = 500,
    iter_warmup = 500,
    chains = 2)  
  
  end_time <- Sys.time()
  end_time-start_time
}

#save
saveRDS(rl_fit, paste0(path$data,'/modelfit_based_on_empirical_data.rds'))

pars <- as_draws_df(rl_fit$draws())
save(pars, file=paste0(path$data,'/modelfit_based_on_artificial_data.rdata'))


# # without_loo
# fit_without_loo=run_fit(include_loo=0,data_for_stan=data_for_stan,iter_sampling=1000,iter_warmup=1000,chains=4)
# # save
# saveRDS(fit_without_loo, paste0(path$data,'/modelfit_based_on_empirical_data.rds'))
# pars <- as_draws_df(fit_without_loo$draws(variables=c("alpha","beta")))  #column names are saved here with ``.
# # save
# save(pars, file=paste0(path$data,'/modelfit_based_on_artificial_data.rdata'))
# 
# # with_loo
# fit_with_loo=run_fit(include_loo=1,data_for_stan=data_for_stan,iter_sampling=1000,iter_warmup=1000,chains=4)
# # aggregate across all blocks (the other ones are zeros)
# like=Reduce('+', fit_with_loo)
# save(like, file=paste0(path$data,'modelfit_like_per_trial_and_chain.rdata'))
# 
