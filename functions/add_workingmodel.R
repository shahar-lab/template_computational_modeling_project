#### this function opens a dialog allowing the enter the name of a new model
#### the new models is then updated in three locations: the "working_model.txt" files, models and data directories.

if(!("svDialogs" %in% (.packages()))){
  library(svDialogs)
}

new_modelname=dlg_input(message = "Enter name for your new model:")
mymodels_list=read.table('./analysis_modeling/working_model.txt')
mymodels_list=rbind(mymodels_list,new_modelname$res)

dir.create(paste0('models/model_',new_modelname$res))
dir.create(paste0('data/model_',new_modelname$res))

write.csv(mymodels_list,'functions/working_model.txt')
