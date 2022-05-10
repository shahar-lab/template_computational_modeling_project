
#This code generate artificial model parameters in an hierarchical structure

rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')


#--------------------------------------------------------------------------------------------------------


#parameters: learning rate chosen, noise parameter and learning rate unchosen 
Nsubjects =50 

#true population level parameters
population_locations    =c(qlogis(0.3),4) #population mean 
population_scales       =c(1,1.5)                  #population sd for
population_parameters   =list(Nsubjects,population_locations,population_scales)

save(population_parameters, file=paste0(path$data,'/simulate_population_parameters.Rdata'))

#individual parameters 
alpha       = plogis(population_locations[1]+population_scales[1]*rnorm(Nsubjects))
beta        =       (population_locations[2]+population_scales[2]*rnorm(Nsubjects))


#save
individual_parameters= 
  
  cbind(subject=seq(1,Nsubjects),
        alpha  =alpha,
        beta   =beta)

save(individual_parameters,file=paste0(path$data,'/simulate_individual_parameters.Rdata'))

