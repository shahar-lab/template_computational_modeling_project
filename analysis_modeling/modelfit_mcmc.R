#aim: Hierarchical fit Stan 
rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')

#--------------------------------------------------------------------------------------------------------

# load data
load(paste0(path$data,'/simulate_standata_based_on_artificial_parameters.rdata'))
load(paste0(path$data,'/modelfit_compile.rdata'))

# without_loo
fit_without_loo=run_fit(include_loo=0,data_for_stan=data_for_stan,iter_sampling=1000,iter_warmup=1000,chains=4)
# save
saveRDS(fit_without_loo, paste0(path$data,'/modelfit_based_on_empirical_data.rds'))
pars <- as_draws_df(fit_without_loo$draws(variables=c("alpha","beta")))  #column names are saved here with ``.
# save
save(pars, file=paste0(path$data,'/modelfit_based_on_artificial_data.rdata'))

# with_loo
fit_with_loo=run_fit(include_loo=1,data_for_stan=data_for_stan,iter_sampling=1000,iter_warmup=1000,chains=4)
# aggregate across all blocks (the other ones are zeros)
like=Reduce('+', fit_with_loo)
save(like, file=paste0(path$data,'modelfit_like_per_trial_and_chain.rdata'))

