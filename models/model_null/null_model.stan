functions {
  //sampling function (that's why the suffix lp) for the likelihood (array params are currently defined like that but it will be deprecated in the future)
  void null_lp (int Nsubjects,int Nblocks, int Ntrials, int[] Ntrials_per_subject,int Narms,vector Qvalue_initial, int Nraffle, int[,] choice,int[,] reward, int [,] offer1, int [,] offer2,int [,] selected_offer, int [,] first_trial_in_block,vector beta,vector alpha )
  {
for (subject in 1:Nsubjects){
    vector[Narms] Qcard; 
    vector[Nraffle] Qoffer; 
 
      for (trial in 1:Ntrials_per_subject[subject]){
        if (first_trial_in_block[subject,trial] == 1) {
                        Qcard=Qvalue_initial;
        }

          Qoffer[1]=Qcard[offer1[subject,trial]];
          Qoffer[2]=Qcard[offer2[subject,trial]];

        //like function
         selected_offer[subject, trial] ~ categorical_logit(beta[subject] * Qoffer);
        //Qvalues update
        Qcard[choice[subject,trial]] += alpha[subject] * (reward[subject,trial] - Qcard[choice[subject,trial]]);

      } 
  }
    return;
    
}
// log_likelihood function for leave-one-block-out purposes
matrix null_log_lik (int Nsubjects,int Nblocks, int Ntrials, int[] Ntrials_per_subject,int Narms,vector Qvalue_initial, int Nraffle, int[,] choice,int[,] reward, int [,] offer1, int [,] offer2,int [,] selected_offer, int [,] first_trial_in_block,vector beta,vector alpha, int [,] fold,real testfold){
    
    matrix[Nsubjects,Ntrials]     log_lik;
    log_lik=rep_matrix(0,Nsubjects,Ntrials);

    for (subject in 1:Nsubjects) {
        vector[Narms] Qcard; 
        vector[Nraffle] Qoffer; 
        
        Qcard=Qvalue_initial;

        for (trial in 1:Ntrials_per_subject[subject]){
         
          //no need to reset q values as each fold is a new block
          if(fold[subject,trial] == testfold) {


          Qoffer[1]=Qcard[offer1[subject,trial]];
          Qoffer[2]=Qcard[offer2[subject,trial]];
          
          log_lik[subject,trial] = categorical_logit_lpmf(selected_offer[subject, trial] | beta[subject] * Qoffer);

          Qcard[choice[subject,trial]] += alpha[subject] * (reward[subject,trial] - Qcard[choice[subject,trial]]);      
        }
        }
  }
  return log_lik;
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
  int<lower = 0> fold[Nsubjects,Ntrials]; //this is how we slice the data to training/test sets
  real           testfold; //this is the number of the block we use as test set
  int            include_loo; //whether to run loo_block or not.
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
  null_lp(Nsubjects, Nblocks,  Ntrials,  Ntrials_per_subject,Narms,Qvalue_initial, Nraffle, choice,reward,  offer1, offer2,selected_offer,  first_trial_in_block, beta,alpha );
}

generated quantities {
  matrix[Nsubjects,Ntrials] fold_log_lik;
  if (include_loo == 1){
    
    fold_log_lik = null_log_lik(Nsubjects, Nblocks,  Ntrials,  Ntrials_per_subject,Narms,Qvalue_initial, Nraffle, choice,reward,  offer1, offer2,selected_offer,  first_trial_in_block, beta,alpha,fold,testfold );
  }
} 
