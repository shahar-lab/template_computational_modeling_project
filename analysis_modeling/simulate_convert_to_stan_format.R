#This code generate artificial data based on simulated parameters

rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')
source('./functions/make_mystandata.R')


###convert to a standata format ###----------------------------------------------------------------------------------

#load artificial data
load(paste0(path$data,'/artificial_data.Rdata'))


#convert
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
                               additional_arguments=list(Narms=length(unique(df$choice)), Nraffle=2))

#save
save(data_for_stan,file=paste0(path$data,'/artificial_standata.Rdata'))


