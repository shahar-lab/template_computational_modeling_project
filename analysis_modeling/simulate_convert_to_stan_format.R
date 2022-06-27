#This code generate artificial data based on simulated parameters

rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')



###convert to a standata format ###----------------------------------------------------------------------------------

source('./functions/make_mystandata.R')
data_for_stan<-make_mystandata(data=df, 
                               subject_column     =df$subject,
                               block_column       =df$block,
                               var_toinclude      =c(
                                 'first_trial_in_block',
                                 'trial',
                                 'offer1',
                                 'offer2',
                                 'choice',
                                 'unchosen',
                                 'reward',
                                 'selected_offer'),
                               additional_arguments=list(Narms=4, Nraffle=2))

save(data_for_stan,file=paste0(path$data,'/simulate_standata_based_on_artificial_parameters.Rdata'))


