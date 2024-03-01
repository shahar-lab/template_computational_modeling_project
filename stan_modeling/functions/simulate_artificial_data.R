
simulate_artificial_data <- function(cfg) {
  
  # generate parameters
  simulate_parameters(path,cfg,plotme=T)
  
  # manually examine your parameters
  df = get_parameters(mydatatype = set_datatype(),path) 
  
  # generate trial-by-trial data
  simulate_artifical_data(path,cfg)
  
  # manually examine your artificial data
  df = get_df(mydatatype = set_datatype(),path, standata = F) 
  
  # convert to format that stan likes
  simulate_convert_to_standata(path,cfg,
                               
                               var_toinclude  = c(
                                 'first_trial_in_block',
                                 'trial',
                                 'offer1',
                                 'offer2',
                                 'choice',
                                 'unchosen',
                                 'reward',
                                 'selected_offer',
                                 'fold')
  )
  
  # manually examine your stan data
  df = get_df(mydatatype = set_datatype(),path, standata = T) 
  
}