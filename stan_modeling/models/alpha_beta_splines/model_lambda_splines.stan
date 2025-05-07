data {
  int<lower=1> Ndata;         // Number of trials
  int<lower=1> Nsubjects;     // Number of subjects
  int<lower=2> Narms;         // Number of overall alternatives
  int<lower=2> Nraffle;       // Number of cards per trial
  int<lower=2> Ndims;         // Number of dimensions

  array [Ndata] int first_trial;   
  array [Ndata] int<lower=1, upper=Nsubjects> subject_trial; 

  array[Ndata] int<lower=0> ch_card; 
  array[Ndata] int<lower=0> ch_key;  
  array[Ndata] int<lower=0> reward;  
  array[Ndata] int<lower=0> card_left; 
  array[Ndata] int<lower=0> card_right; 
  array[Ndata] int<lower=0, upper=1> first_trial_in_block;
  array[Ndata] int<lower=0> selected_offer;

  // Spline basis for trial
  int<lower=1> K;             // Number of basis functions
  matrix[Ndata, K] X_trial;   // B-spline basis matrix for trial
}

parameters {
  real mu_alpha;
  real mu_beta;
  vector[K] mu_lambda_beta;
  
  real<lower=0> sigma_alpha;
  real<lower=0> sigma_beta;
  vector<lower=0>[K] sigma_lambda_beta; 
  
  vector[Nsubjects] alpha_raw;
  vector[Nsubjects] beta_raw;
  array[Nsubjects] vector[K] lambda_beta_raw;  // Store as an array of vectors
}

transformed parameters {
  vector<lower=0, upper=1>[Nsubjects] alpha_sbj;
  vector[Nsubjects] beta_sbj;
  array[Nsubjects] vector[K] lambda_beta_sbj;
  
  real  <lower=0, upper=1> alpha_t;
  real beta_t;  
  vector <lower=0, upper=1>[Ndata] lambda_t;
  
  vector[Ndims]  weights;
  vector [Ndata] weight_key;
  vector [Ndata] weight_card;
  real PE_card;
  real PE_key;
  vector [Ndata] Qnet_diff;
  vector [Ndata] Qcard_diff;
  vector [Ndata] Qkey_diff;
  vector [Narms] Q_cards;
  vector [Nraffle] Q_keys;
  vector [Nraffle] Qnet;
  vector [Ndims] prior_relevant;
  vector [Ndims] irrelevant_weights;
  real diff_reliability;
  prior_relevant[1]=1;
  prior_relevant[2]=0;
  irrelevant_weights[1]=0;
  irrelevant_weights[2]=1;
  for (subject in 1:Nsubjects){
    alpha_sbj[subject] = inv_logit(mu_alpha + sigma_alpha * alpha_raw[subject]);
    beta_sbj[subject]  = mu_beta + sigma_beta * beta_raw[subject];
    lambda_beta_sbj[subject] = mu_lambda_beta + sigma_lambda_beta .* lambda_beta_raw[subject]; //gives a vector in length K
  }

  for (t in 1:Ndata) {
    alpha_t = alpha_sbj[subject_trial[t]];
    beta_t = beta_sbj[subject_trial[t]];
    
    // Trial-dependent lambda using B-spline
    lambda_t[t] = inv_logit(X_trial[t] * lambda_beta_sbj[subject_trial[t]]);
     if (first_trial_in_block[t] == 1) {
      Q_cards=rep_vector(0.5, Narms);
      Q_keys=rep_vector(0.5, Nraffle);
    }
          weights[1]= lambda_t[t] * prior_relevant[1] + (1-lambda_t[t]) * irrelevant_weights[1];
          weights[2]= lambda_t[t] * prior_relevant[2] + (1-lambda_t[t]) * irrelevant_weights[2];
          
          Qnet[1]=weights[1]*Q_cards[card_left[t]]+weights[2]*Q_keys[1]; //We compound the value of the card appearing on the left and the value of the left key.

          Qnet[2]=weights[1]*Q_cards[card_right[t]]+weights[2]*Q_keys[2];
        
        //likelihood function
        Qnet_diff[t]  = Qnet[2]-Qnet[1]; //higher values of Qdiff mean higher chance to choose right option.
        //save
        Qcard_diff[t]=Q_cards[card_right[t]]-Q_cards[card_left[t]];
        Qkey_diff[t]=Q_keys[2]-Q_keys[1];
 //calculating PEs
 PE_card =reward[t] - Q_cards[ch_card[t]];
 PE_key  =reward[t] - Q_keys[ch_key[t]];
 
//Update values ch_key=1 means choosing right
 Q_cards[ch_card[t]] += alpha_t * PE_card; //update card_value according to reward
 Q_keys[ch_key[t]]   += alpha_t * PE_key; //update key value according to reward
    
  }
}

model {
  // Priors for group-level parameters
  mu_alpha ~ normal(0, 3);
  mu_beta ~ normal(0, 3);
  mu_lambda_beta ~ normal(0, 3);     // Prior for global mean of spline weights
  
  sigma_alpha ~ normal(0, 1);
  sigma_beta ~ normal(0, 1);
  sigma_lambda_beta ~ normal(0, 1);  // Prior for variability across subjects

  alpha_raw ~ normal(0, 1);
  beta_raw ~ normal(0, 1);
  for (subject in 1:Nsubjects) {
  lambda_beta_raw[subject] ~ normal(0, 1);
}


    target += bernoulli_logit_lpmf(selected_offer | beta_t * Qnet_diff);
  
}
