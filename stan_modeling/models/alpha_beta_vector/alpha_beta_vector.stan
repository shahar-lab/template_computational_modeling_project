data {
  
 int<lower=1> Ndata;                // Total number of trials (for all subjects)
  int<lower=1> Nsubjects; //number of subjects

  int<lower=2> Narms; //number of overall alternatives

  int<lower=2> Nraffle; //number of cards per trial

  int<lower=2> Ndims; //number of dimensions
  

  array [Ndata] int<lower=1, upper=Nsubjects> subject_trial; // Which subject performed each trial

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

}

parameters {
    // Group-level (population) parameters
  real mu_alpha;        // Mean learning rate across subjects
  real mu_beta;          // Mean non-decision time across subjects
  
  // Group-level standard deviations (for subject-level variability)
  real<lower=0> sigma_alpha;          // Variability in non-decision time
  real<lower=0> sigma_beta;          // Variability in non-decision time
  
// Non-centered parameters (random effects in standard normal space)
  vector[Nsubjects] alpha_raw;
  vector[Nsubjects] beta_raw;

}


transformed parameters {
  vector<lower=0,upper=1>[Nsubjects] alpha_sbj; // learning rate
  vector[Nsubjects] beta_sbj; // inverse temp
  
  for (subject in 1:Nsubjects){
 alpha_sbj[subject] = inv_logit(mu_alpha +sigma_alpha* alpha_raw[subject]);
 beta_sbj[subject] = (mu_beta +sigma_beta* beta_raw[subject]);
  }
  real alpha_t;
	real beta_t;		
	
  real PE_card;
  vector[Narms] Qnet;
  vector [Ndata] Qnet_diff;
  vector [Narms] Q_cards;

    for (t in 1:Ndata) {
    alpha_t = alpha_sbj[subject_trial[t]];
		beta_t = beta_sbj[subject_trial[t]];

  if (first_trial_in_block[t] == 1) {
      Q_cards=rep_vector(0.5, Narms);
    }
          
          Qnet[1]=Q_cards[card_left[t]];

          Qnet[2]=Q_cards[card_right[t]];
        
        //likelihood function
        Qnet_diff[t]  = beta_t*(Qnet[2]-Qnet[1]); //higher values of Qdiff mean higher chance to choose right option.
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
  mu_beta ~ normal(0, 3);
  
  // Priors for group-level standard deviations
  sigma_alpha ~ normal(0, 2);
  sigma_beta ~ normal(0, 2);
  
  // Priors for subject-specific effect
  alpha_raw~normal(0,1);
  beta_raw~normal(0,1);
  
  target+= bernoulli_logit_lpmf(selected_offer |  Qnet_diff);
  
}

generated quantities {
  vector[Ndata] log_lik;
  for (n in 1:Ndata) {
    log_lik[n] = bernoulli_logit_lpmf(selected_offer[n] | Qnet_diff[n]);
  }
}
