
#aim: Hierarchical fit Stan 
rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')

mydatatype=set_datatype()

#--------------------------------------------------------------------------------------------------------

#load model
load(paste0(path$data,'/modelfit_compile.rdata'))

# load data
if (mydatatype=='empirical') {print('using empirical data')
                              load('./data/empirical_data/standata.Rdata')}
if (mydatatype=='artificial'){print('using artificial data')
                              load(paste0(path$data,'/artificial_standata.Rdata'))}

#sample
fit<- my_compiledmodel$sample(
  data = data_for_stan, 
  iter_sampling = 500,
  iter_warmup = 500,
  chains           = 2,
  cores =2)  


#save
if (mydatatype=='empirical'){fit$save_object(paste0(path$data,'/modelfit_empirical.rds'))}
if (mydatatype=='artificial'){fit$save_object(paste0(path$data,'/modelfit_recovery.rds'))}
