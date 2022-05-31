functions {
  matrix null_model(int Ntrials, int Ntrials_per_subject, int Narms, vector Qvalue_initial, int Nraffle, int[] choice, int[] reward, int [] offer1, int [] offer2, int [] selected_offer, int [] first_trial_in_block, real alpha ){
    vector[Narms] Qcard; 
    matrix[Ntrials,Nraffle] Qoffer; 
 
      for (trial in 1:Ntrials_per_subject){
        if (first_trial_in_block[trial] == 1) {
                        Qcard=Qvalue_initial;
        }
        
        Qoffer[trial,1] = Qcard[offer1[trial]];
        Qoffer[trial,2] = Qcard[offer2[trial]];

        
        //Qvalues update
        Qcard[choice[trial]] += alpha * (reward[trial] - Qcard[choice[trial]]);

      }
      return Qoffer;
  }
}

data {

  //General fixed parameters for the experiment/models
  int<lower = 1> Nsubjects;                                         
  int<lower = 1> Nblocks;           
  int<lower = 1> Ntrials;                                           
  int<lower = 1> Ntrials_per_subject[Nsubjects];                    
  int<lower = 2> Narms;                                             
  int<lower = 2> Nraffle;                                           


  //Behavioral data:
  int<lower = 0> choice[Nsubjects,Ntrials];              
  int<lower = 0> reward[Nsubjects,Ntrials];              
  int<lower = 0> offer1[Nsubjects,Ntrials];              
  int<lower = 0> offer2[Nsubjects,Ntrials];              
  int<lower = 0> selected_offer[Nsubjects,Ntrials];      
  int<lower = 0> first_trial_in_block[Nsubjects,Ntrials];
  //int<lower = 0> fold[Nsubjects,Ntrials]; //this is how we slice the data to training/test sets
  //real           testfold; //this is the number of the block we use as test set
  //int            include_loo; //whether to run loo_block or not.
}


transformed data{
  int<lower = 1> Nparameters=2; 
  vector[Narms] Qvalue_initial; 
  Qvalue_initial = rep_vector(0.5, Narms);
}

parameters {
  //population level parameters 
  vector         [Nparameters] population_locations;      
  vector<lower=0>[Nparameters] population_scales;         
  
  //individuals level
  vector[Nsubjects] alpha_random_effect;
  vector[Nsubjects] beta_random_effect;
}


transformed parameters {
  vector<lower=0, upper=1>[Nsubjects] alpha;
  vector                  [Nsubjects] beta;
  
  for (subject in 1:Nsubjects) {
    alpha[subject]   = inv_logit(population_locations[1]  + population_scales[1] * alpha_random_effect[subject]);
    beta[subject]    =          (population_locations[2]  + population_scales[2] * beta_random_effect [subject]) ;
  }

}


model {
  
  // population level  
  population_locations  ~ normal(0, 2);            
  population_scales     ~ cauchy(0,2);        

  // indvidual level  
  alpha_random_effect ~ std_normal();
  beta_random_effect  ~ std_normal();
 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Likelihood function per subject per trial

  for (subject in 1:Nsubjects){
    
    matrix[Ntrials,Nraffle] Qoffer;
    vector[Nraffle] Qoffer_subject;
    
    Qoffer = null_model(Ntrials, Ntrials_per_subject[subject], Narms, Qvalue_initial, Nraffle, choice[subject], reward[subject], offer1[subject], offer2[subject], selected_offer[subject], first_trial_in_block[subject], alpha[subject] );
    
    //like function
    for(trial in 1:Ntrials_per_subject[subject]){
      Qoffer_subject = to_vector(Qoffer[trial]);
      selected_offer[subject, trial] ~ categorical_logit(Qoffer_subject*beta[subject]);
    }
    
  } 
}


//generated quantities {
  //matrix[Nsubjects,Ntrials] fold_log_lik;
  //if (include_loo == 1){
    
    //fold_log_lik = null_log_lik(Nsubjects, Nblocks,  Ntrials,  Ntrials_per_subject,Narms,Qvalue_initial, Nraffle, choice,reward,  offer1, offer2,selected_offer,  first_trial_in_block, beta,alpha,fold,testfold );
  //}
//} 
