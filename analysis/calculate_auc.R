library(pROC)
#load fit
fit=readRDS(paste0(path$data,'/modelfit_empirical.rds'))
p_ch_action=fit$draws(variables ='p_ch_action',format='draws_matrix')

#remove missing trials
p_ch_action[p_ch_action==0]=NA
p_ch_action = p_ch_action[, !colSums(is.na(p_ch_action))]
#transform to aligned df
p_ch_action=as.data.frame(t(p_ch_action))
#calculate roc
#print example
plot(roc(df$selected_offer,p_ch_action[,1]))
auc(roc)
#iterate on all samples
Nsamples=ncol(p_ch_action)
auc_list=list()
for (sample in 1:Nsamples){
  print(paste0("sample: ",sample))
  roc=roc(df$selected_offer,p_ch_action[,sample])
  auc=auc(roc)
  auc_list=append(auc_list,auc)
}
posterior_auc=unlist(auc_list)
hist(posterior_auc)

save(posterior_auc,file=paste0(path$data,'/auc.Rdata'))