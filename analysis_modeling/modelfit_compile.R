#aim: compile and save stan model (so you wont have to redo this everytime you re-run the model with different parameters)
rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')


#--------------------------------------------------------------------------------------------------------


set_cmdstan_path(path = NULL)

my_compiledmodel <- cmdstan_model(paste0(path$model,'.stan'))
save(my_compiledmodel, file=paste0(path$data,'/modelfit_compile.rdata'))

