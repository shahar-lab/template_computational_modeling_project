#This code plot posterior predictive checks
#y_rep should be a matrix with samples x observations 
#(note - that samples = Niter*Nchains and observations = Nsubjects * Ntrials_per_subject)

rm(list=ls())
source('./functions/my_packages.R')
source('./functions/my_starter.R')


#--------------------------------------------------------------------------------------------------------

#load stan object
fit=readRDS(paste0(path$data,'/modelfit_recovery.rds'))
load(paste0(path$data,'/artificial_standata.Rdata'))

#extract y_rep
y_rep=fit$draws(variables ='y_rep',format="draws_matrix")
Niterations = dim(fit$draws())[1]
Nchains = dim(fit$draws())[2]
Nsubjects = length(unique(df$subject))
Ntrials_per_subjects = max(df$trial)*max(df$block)
y_rep=resize(y_rep,Niterations*Nchains,Nsubjects*Ntrials_per_subjects) 

#plot y_rep
rowMeans(y_rep)%>%as.data.frame()%>%ggplot(aes(x=`.`))+geom_histogram(color="black", fill="grey")+ theme_classic()+ggtitle("Chance of the model to choose like the agent")

#ppc for stay effect
df=df%>%mutate(stay_card=(choice==lag(choice))*1,reward_oneback=lag(reward),reoffer_chosen = if_else(lag(choice)==offer1|lag(choice)==offer2,1,0))
y_stay_card=df$stay_card

#check whether the model stayed with the same card.
y_rep_stay_card = matrix(NA,nrow(y_rep),ncol(y_rep))
for (sample in 1:nrow(y_rep)) {
  y_rep_stay_card[sample,]= (y_stay_card==y_rep[sample,])*1 
  #if the model choose like the agent (y_rep==1) and the agent stayed (y_stay_card==1) then the model stayed. 
  #Same way if the model choose unlike the agent (y_rep==0) and the agent didn't stay (y_stay_card==0), then the model did'nt stay.
}

df_reoffer_chosen = df%>%filter(reoffer_chosen==1)
y_rep_stay_card_reoffer_chosen = t(as.matrix(y_rep_stay_card))[df$reoffer_chosen==1,][-1,]
stay_rep=fit$draws(variables ='stay_rep',format="draws_matrix")
stay_rep=stay_rep[,-1]
stay_card=df$stay_card[-1]
group_vec=as.factor(df$reward_oneback==1)[-1]
y_stay_card_reoffer_chosen = (df_reoffer_chosen$stay_card)*1
ppc_stat_grouped(stay_card,stay_rep,group_vec)

