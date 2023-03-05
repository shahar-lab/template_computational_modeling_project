
simulate_artifical_data <-function(path,cfg){

  #load parameters
  load(paste0(path$data,'/model_parameters.Rdata'))

  #set sample size
  Nsubjects =dim(model_parameters$artificial_individual_parameters)[1] 

  #run simulation

  n.cores <- parallel::detectCores() - 1
  
  my.cluster <- parallel::makeCluster(
    n.cores, 
    type = "PSOCK"
  )
  
  doParallel::registerDoParallel(cl = my.cluster)
  library(doParallel)
  source(paste0(path$model,'.r'))
  
  df<-
  foreach(
    subject = 1:Nsubjects,
    .combine = rbind
    ) %do% {
    sim.block(subject=subject, 
              parameters=model_parameters$artificial_individual_parameters[subject,],
              cfg=cfg)
  }

  #save
  save(df,file=paste0(path$data,'/artificial_data.Rdata'))
  cat(paste0('[stan_modeling]:  "artificial_data.Rdata" was saved at "',path$data,'"'))
  
}