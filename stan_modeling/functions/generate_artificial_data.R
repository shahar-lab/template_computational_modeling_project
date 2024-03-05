### This function uses task configuration to simulate artificial data using model parameters and task configuartion.
### the data is saved in a file ready for stan run.
### to manually examine the data generated in this code, use "get_df" function

generate_artificial_data <- function(cfg) {
  
  # generate parameters
  simulate_parameters(path,cfg,plotme=T)

  # generate trial-by-trial data
  simulate_artifical_data(path,cfg)
  
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
  
}