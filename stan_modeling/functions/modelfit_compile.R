
modelfit_compile <-function(path){

  set_cmdstan_path(path = NULL)

  my_compiledmodel <- cmdstan_model(paste0(path$model,'.stan'))
  
  save(my_compiledmodel, file=paste0(path$data,'/modelfit_compile.rdata'))
  cat(paste0('[stan_modeling]:  "modelfit_compile.Rdata" was saved at "',path$data,'"'))
  
}
