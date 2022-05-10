#aim: compile and save stan model (so you wont have to redo this everytime you re-run the model with different parameters)
rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')


#--------------------------------------------------------------------------------------------------------

# compile stan model----------------------------------------------

set_cmdstan_path(path = NULL)

my_compiledmodel <- cmdstan_model(paste0(path$model,'model.stan'))
save(my_compiledmodel, file=paste0(path$data,'/modelfit_compile.rdata'))


my_compiledmodel <- stan_model(paste0(path$model,'model_loo.stan'))
save(my_compiledmodel, file=paste0(path$data,'/modelfit_compile_loo.rdata'))
