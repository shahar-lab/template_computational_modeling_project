#Aim:
#This code generate artificial model parameters in an hierarchical structure
#it works based on the definition in "_artifical_paramters.r" file that you need
#to place in the specific model folder

rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')


#--------------------------------------------------------------------------------------------------------

source(paste0(path$model,'artificial_parameters.r'))

Nsubjects=25
artifical_parameters=generate_individual_parameters(artifical_parameters,
                                                    Nsubjects)


plot_artifical_parameters(artifical_parameters,
                          plot_method='dot' )#plotme can be 'dot', 'hist' or 'density'.)


save(artifical_parameters,file=paste0(path$data,'/artifical_parameters.Rdata'))

