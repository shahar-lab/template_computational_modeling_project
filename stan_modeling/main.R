rm(list=ls())
source('./functions/my_starter.R')

path=set_workingmodel()


#######TODO:#######
###Create a new data generation function, that asks for datatpe. If artificial - simulates, if empirical loads file.
###Create a new function that makes an Rdata file ready for stan, with name changes and data manipulations if needed.
###Extract posterior sampling (compilation & MCMC) to a new function.
###Add examine functions for empirical data.


#Simulate data
simulate_artificial_data(
  cfg = list(Nsubjects        = 5,
             Nblocks          = 2,
             Ntrials_perblock = 50,
             Narms            = 2,  #number of arms in the task 
             Nraffle          = 2,  #number of arms offered for selection each trial
             rndwlk           = read.csv('./functions/rndwlk.csv',header=F)
  ))

#####sample posterior--------------------

modelfit_compile(path,format=T)

modelfit_mcmc(path,
              
              mymcmc = list(
                datatype = set_datatype() ,
                samples  = 1000,
                warmup  = 2000,
                chains  = 4,
                cores   = 4)
)

mypars=c("population_scales[1]",
         "population_scales[2]")

examine_mcmc(path,mypars, datatype = set_datatype())

examine_population_parameters_recovery(path)

examine_individual_parameters_recovery(path)


####examine model
#load parameters
fit   = readRDS(paste0(path$data,'/modelfit_recovery.rds'))
Qdiff = fit$draws(variables ='Qdiff_external',format='draws_matrix')
Qval1 = fit$draws(variables ='Qval1_external',format='draws_matrix')
Qval2 = fit$draws(variables ='Qval2_external',format='draws_matrix')
Qval3 = fit$draws(variables ='Qval3_external',format='draws_matrix')
Qval4 = fit$draws(variables ='Qval4_external',format='draws_matrix')

PE    = fit$draws(variables ='PE_external',format='draws_matrix')


#####compare models--------------------

modelfit_compile_loo(path)

modelfit_mcmc_loo(path,
                  
                  mymcmc = list(
                    datatype = set_datatype() ,
                    samples  = 500,
                    warmup  = 500,
                    chains  = 8,
                    cores   = 8)
)
compare=compare_models(path)

####Documentation:------------------
#
#simulate_parameters:
#This function generate artificial model parameters in an hierarchical structure
#based on the definition in "_artificial_parameters.r" file that you need
#to place in the specific model folder.
#It then generate a 'model_parameters.Rdata' in the model data folder
#
#simulate_artifical_data:
#This function generates artificial data based on 'model_parameters.Rdata'
#and creates a df.rdata with artifical behavior in the model data folder
#
#simulate_convert_to_standata:
#converts the dataframe to matrix format and handles missing data with padding
#
#modelfit_compile:
#compile and save stan model (so you wont have to redo this everytime you re-run the model with different parameters)
#
#
#examine_parameters_recovery:
#This function plot recovered parameters against the true parameters
#use debug() and undebug() to find problems in these functions

