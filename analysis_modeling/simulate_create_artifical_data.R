#This code generate artificial data based on simulated parameters

rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')

#--------------------------------------------------------------------------------------------------------

#load parameters
load(paste0(path$data,'/model_parameters.Rdata'))

#set sample size
Nsubjects =dim(model_parameters$artificial_individual_parameters)[1] 

#set task variables 
cfg = list(Nblocks         =2,
           Ntrials_perblock=100,
           Narms           =2,  #number of arms in the task 
           Nraffle         =2,  #number of arms offered for selection each trial
           rndwlk          =read.csv('./functions/rndwlk.csv',header=F))

#run simulation
source(paste0(path$model,'.r'))

df=data.frame()
for (subject in 1:Nsubjects) {
  df=rbind(df, sim.block(subject=subject, parameters=model_parameters$artificial_individual_parameters[subject,],cfg=cfg))
}

#save
save(df,file=paste0(path$data,'/artificial_data.Rdata'))
