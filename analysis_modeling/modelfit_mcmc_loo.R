#aim: Hierarchical fit Stan with loo cv

rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')


#--------------------------------------------------------------------------------------------------------


detectCores()

#load data
load('./data/empirical_data/standata.rdata')
load(paste0(path$data,'modelfit_compile_loo.rdata'))

like=
  lapply(1:4, function(mytestfold) {
    print(Sys.time())
    print(mytestfold)
    data_for_stan$testfold=mytestfold
    
    fit <- my_compiledmodel$sample(
                    data = data_for_stan, 
                    iter_sampling = 500,
                    iter_warmup = 500,
                    chains = 2,
                    parallel_chains = 2)
    
    # fit<- sampling(my_compiledmodel, 
    #                data=data_for_stan, 
    #                pars=c('log_lik'),
    #                iter=2000,
    #                warmup = 1000,
    #                chains=4,
    #                cores =4) 
    
    pars <- as_draws_df(fit$draws())
    #pars=rstan::extract(fit)
    pars$log_lik
  })

#aggregate across all four blocks
like=like[[1]]+like[[2]]+like[[3]]+like[[4]]

save(like, file=paste0(path$data,'modelfit_like_per_trial_and_chain.rdata'))

# save mean predicted probability per trial (across samples)
like   =t(sapply(1:dim(like)[1], function(i){x=c(t(like[i,,]))
                                             x[x==0]<-NA
                                             x=na.omit(x)}))

save(like, file=paste0(path$data,'modelfit_like_per_trial.rdata'))






