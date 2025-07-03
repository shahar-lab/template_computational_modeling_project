data {
  
  int<lower=1> Ndata;                // Total number of trials (for all subjects)
 
  int<lower=1> Nsubjects; //number of subjects

  int<lower=2> Narms; //number of overall alternatives

  int<lower=2> Nraffle; //number of cards per trial

  int<lower=2> Ndims; //number of dimensions
  
  int<lower=1> Ntrials; //number of trials in the task
  

  array [Ndata] int<lower=1, upper=Nsubjects> subject_trial; // Which subject performed each trial
  
  array [Ndata] int trial_num; // trial number (within the task) for each trial

  //Behavioral data:

  //each variable being a subject x trial matrix

  //the data is padded in make_standata function so that all subjects will have the same number of trials

  array[Ndata] int<lower=0> ch_card; //index of which card was chosen coded 1 to 4

  array[Ndata] int<lower=0> ch_key; //index of which card was chosen coded 1 to 4

  array[Ndata] int<lower=0> reward; //outcome of bandit arm pull

  array[Ndata] int<lower=0> card_left; //offered card in left bandit

  array[Ndata] int<lower=0> card_right; //offered card in right bandit

  array [Ndata] int <lower=0,upper=1> first_trial_in_block; // binary indicator

  array[Ndata] int<lower=0> selected_offer;

 // Spline basis for trial
  int<lower=1> K;             // Number of basis functions
  matrix[Ntrials, K] basis_matrix;   // B-spline basis matrix for trial in task
  matrix[K, K] penalty_matrix;  // Penalty matrix
}

parameters {
    // Group-level (population) parameters
  real mu_alpha;        // Mean learning rate across subjects
  vector[K] mu_beta_splines_vector;
  
  // Group-level standard deviations (for subject-level variability)
  real<lower=0> sigma_alpha;          // Variability in learning rate
  vector<lower=0>[K] sigma_beta_splines_vector;          // Variability in betas_coefs
  
// Non-centered parameters (random effects in standard normal space)
  vector[Nsubjects] alpha_raw;
  array[Nsubjects] vector[K] beta_splines_vector_raw;

  real<lower=0> smoothing;  //penalty smoothing parameter
  
}


transformed parameters {
  vector<lower=0,upper=1>[Nsubjects] alpha_sbj; // learning rate
  array[Nsubjects] vector[K] beta_spline_vector_sbj; // inverse temp
  
  
 alpha_sbj = inv_logit(mu_alpha +sigma_alpha* alpha_raw);
 for(subject in 1:Nsubjects){
 beta_spline_vector_sbj[subject] = mu_beta_splines_vector + sigma_beta_splines_vector .* beta_splines_vector_raw[subject]; //gives a vector for each subject in length K
 }
  real alpha_t;
	vector [Ndata] beta_t;		
	
  real PE_card;
  vector[Narms] Qnet;
  vector [Ndata] Qnet_diff;
  vector [Narms] Q_cards;

    for (t in 1:Ndata) {
    alpha_t = alpha_sbj[subject_trial[t]];
		beta_t[t] = basis_matrix[trial_num[t]] * beta_spline_vector_sbj[subject_trial[t]];

  if (first_trial_in_block[t] == 1) {
      Q_cards=rep_vector(0.5, Narms);
    }
          
          Qnet[1]=Q_cards[card_left[t]];

          Qnet[2]=Q_cards[card_right[t]];
        
        //likelihood function
        Qnet_diff[t]  = beta_t[t]*(Qnet[2]-Qnet[1]); //higher values of Qdiff mean higher chance to choose right option.
        //save
 //calculating PEs
 PE_card =reward[t] - Q_cards[ch_card[t]];
 
//Update values ch_key=1 means choosing right
 Q_cards[ch_card[t]] += alpha_t * PE_card; //update card_value according to reward
 

}
}

model {
  
  // Priors for group-level parameters
  mu_alpha ~ normal(0, 3);
  mu_beta_splines_vector ~ normal(0, 3);
  
  // Priors for group-level standard deviations
  sigma_alpha ~ normal(0, 2);
  sigma_beta_splines_vector ~ normal(0, 2);
  
  // Priors for subject-specific effect
  alpha_raw~normal(0,1);
  
  for (subject in 1:Nsubjects) {
  beta_splines_vector_raw[subject] ~ normal(0, 1);
}

  //Prior for smoothness penalty
  smoothing ~ exponential(1);
  target += -0.5 * smoothing * dot_product(mu_beta_splines_vector, penalty_matrix * mu_beta_splines_vector);
  
  target+= bernoulli_logit_lpmf(selected_offer |  Qnet_diff);
  
}

generated quantities {
  vector[Ndata] log_lik;
  for (n in 1:Ndata) {
    log_lik[n] = bernoulli_logit_lpmf(selected_offer[n] | Qnet_diff[n]);
  }
}
