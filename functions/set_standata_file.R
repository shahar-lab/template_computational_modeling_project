set_standata_file<-function(){
  load('data/empirical_data_files/standata_files.Rdata')

  
  myfile   =dlg_list(standata_files, multiple = TRUE)$res
  data_path =paste0('data/empirical_data_files/', myfile)

  cat(paste0(myfile,
             ' is the chosen data file',
             '\n',
             '\n from folder: ',data_path
             ))
  
  return(data_path)
}
