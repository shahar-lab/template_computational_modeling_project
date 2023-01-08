#Aim:
#This code generate artificial model parameters in an hierarchical structure
#it works based on the definition in "_artificial_parameters.r" file that you need
#to place in the specific model folder

rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')


#--------------------------------------------------------------------------------------------------------

source(paste0(path$model,'_parameters.r'))

Nsubjects=100
model_parameters=generate_individual_parameters(model_parameters,Nsubjects)

plot_artifical_parameters(model_parameters, plot_method='dot' )#plotme can be 'dot', 'hist' or 'density'.)


save(model_parameters,file=paste0(path$data,'/model_parameters.Rdata'))

