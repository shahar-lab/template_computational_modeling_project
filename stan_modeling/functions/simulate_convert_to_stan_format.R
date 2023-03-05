simulate_convert_to_standata <-function (path,cfg,var_toinclude){

  source('./functions/make_mystandata.R')


  #load artificial data
  load(paste0(path$data,'/artificial_data.Rdata'))


  #convert
  data_for_stan<-make_mystandata(data                 = df, 
                                 subject_column       = df$subject,
                                 block_column         = df$block,
                                 var_toinclude        = var_toinclude,
                                 additional_arguments = list(
                                   Narms  = cfg$Narms, 
                                   Nraffle= cfg$Nraffle))

  #save
  save(data_for_stan,file=paste0(path$data,'/artificial_standata.Rdata'))
  cat(paste0('[stan_modeling]:  "artificial_standata.Rdata" was saved at "',path$data,'"'))
  
}