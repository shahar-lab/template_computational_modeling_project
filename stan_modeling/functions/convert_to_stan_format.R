convert_to_stan_format <-function (path,data_type,var_toinclude,cfg){
  
  
  #load data
  load(paste0(path$data,"/artificial_data.Rdata"))
  
  # Number of subjects and trials per subject (based on your matrix dimensions)
  n_subjects <- length(unique(df$subject))  # Number of subjects (rows)
  n_trials_per_subject <- as.vector(table(df$subject))  # Number of trials per subject (columns)
  n_total_trials <- nrow(df)  # Total number of trials across all subjects
  
  # Create the subject index: repeat each subject ID for every trial they performed
  subject_vector <- rep(1:n_subjects, times = n_trials_per_subject)
  
  
  if(data_type=="empirical"){
  df=df%>%mutate(
    first_trial_in_block=if_else(block!=lag(block),1,0))
  df$first_trial_in_block[1]=1
  }
  

  
  # Prepare stan_data list
  data_for_stan <- list(
    Ndata = n_total_trials,  # Total number of trials
    Nsubjects = n_subjects,  # Number of subjects
    subject_trial = subject_vector,  # Subject IDs for each trial
    Narms = cfg$Narms,
    Nraffle = cfg$Nraffle,
    Ndims = 2,
    Ntrials = cfg$Ntrials_perblock*cfg$Nblocks, # Number of trials in the task
    trial_num = df %>% mutate(overall_trial = (block-1)*cfg$Ntrials_perblock + trial) %>%
      pull(overall_trial)
  )
  for (var in var_toinclude) {
    data_for_stan[[var]] <-  as.vector(df[[var]])
  }
  
  
  if (cfg$splines) {
    data_for_stan$K = cfg$num_knots   # Number of spline basis functions
    data_for_stan$basis_matrix = cfg$basis_matrix    # B-spline basis for trial
    data_for_stan$penalty_matrix = cfg$penalty_matrix   # Penalty matrix
  }
  
  if (data_type=="artificial") {
    save(data_for_stan,file=paste0(path$data,"/artificial_standata.Rdata"))
  } else {
    save(data_for_stan,file=paste0(path$data,"/empirical_standata.Rdata"))
  }
  
}