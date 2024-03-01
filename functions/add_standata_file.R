#### this function opens a dialog allowing the enter the name of a data file ready for stan
#### the new file is then updated.
### First save the file in 'data/empirical_data_files' and then add it's name.

add_standata_file<-function(){
  load('data/empirical_data_files/standata_files.Rdata')
  file_name=dlg_input(message = "Enter name for your file:")
  
  standata_files=c(standata_files,file_name$res)
  
  save(standata_files, file = "data/empirical_data_files/standata_files.rdata")
}

