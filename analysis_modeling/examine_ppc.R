#This code plot posterior predictive checks
#y_rep should be a matrix with samples x observations (note - that samples = iter*chains and observations = nsubjects * ntrials_pre_subject)
source('./functions/my_starter.R')

#load model

y_rep=rl_fit$draws(variables = 'y_rep')
y_rep=ramify::resize(y_rep,1000,5000)
dim(y_rep)
load(paste0(path$data,'/simulate_data_based_on_artificial_parameters.Rdata'))

library(bayesplot)


ppc_stat(  df$selected_offer, y_rep,
                   freq=F,
                   xlim=c(0,1))










# ppc_rootogram(
#   df$stay_frc_unch[(df$reoffer_unch==T & df$reoffer_ch==F)]*1,
#   yrep[1:4000,(df$reoffer_unch==T & df$reoffer_ch==F)],
#   freq=FALSE,
#   style = "suspended",
#   group=df$reward_oneback[(df$reoffer_unch==T & df$reoffer_ch==F)]
# )
# index=(df$reoffer_unch==T & df$reoffer_ch==F)
# 
# 
# ppc_stat_grouped(  df$stay_frc_unch[index]*1, yrep[1:4000,index],df$reward_oneback[index],
#                    freq=F,
#                    xlim=c(0,1))