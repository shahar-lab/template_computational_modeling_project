#### simulate Rescorla-Wagner block for participant ----
sim.block = function(subject,parameters,cfg){ 
  print(paste('subject',subject))
  
  #pre-allocation
  
  #set parameters
  alpha = parameters['alpha']
  beta_spline1  = parameters['beta_splines_vector[1]']
  beta_spline2  = parameters['beta_splines_vector[2]']
  beta_spline3  = parameters['beta_splines_vector[3]']
  beta_spline4  = parameters['beta_splines_vector[4]']
  beta_spline5  = parameters['beta_splines_vector[5]']
  
  
  #set initial var
  Narms              = cfg$Narms
  Ntrials=cfg$Ntrials
  Nraffle            = cfg$Nraffle
  Nblocks            = cfg$Nblocks
  Ndims              = cfg$Ndims
  expvalues          = cfg$expvalues
  basis_matrix       = cfg$basis_matrix
  df                 =data.frame()

  for (block in 1:Nblocks){

    Q_cards= rep(0.5, Narms)
    for (trial in 1:Ntrials){
      
      #create beta for this trial
      overall_trial= (block-1)*Ntrials+trial
      beta = beta_spline1* basis_matrix[overall_trial,1] +
              beta_spline2 * basis_matrix[overall_trial,2] + 
                beta_spline3 * basis_matrix[overall_trial,3]+
                beta_spline4 * basis_matrix[overall_trial,4]+
                beta_spline5 * basis_matrix[overall_trial,5]
      #computer offer
      options=sample(1:Narms,2)
      
      #value of offered cards
      Q_cards_offered = Q_cards[options] #use their Q values

      Qnet = Q_cards_offered
      
      p= exp(beta * Qnet) / sum(exp(beta * Qnet)) #get prob for each action
      #players choice
      ch_card = sample(options, 1, prob = p) #chose a card according to probs
      unch_card=options[which(options != ch_card)]
      ch_key = which(options == ch_card) #get key of chosen card 1 =left
      unch_key = which(options!=ch_card)
      #outcome 
      reward = sample(0:1, 1, prob = c(1 - expvalues[ch_card, trial], expvalues[ch_card, trial])) #reward according to card
      
      PE_cards=reward-Q_cards[ch_card]
      
      #save trial's data
      
      #create data for current trials
      dfnew=data.frame(
        subject,
        overall_trial,
        block,
        trial,
        first_trial_in_block=if_else(trial==1,1,0),
        first_trial=if_else(trial==1&block==1,1,0),
        card_right = options[2],
        card_left = options[1],
        ch_card,
        ch_key,
        selected_offer=ch_key-1,
        reward,
        Q_ch_card = Q_cards[ch_card], #to get previous trial
        Q_unch_card = Q_cards[options[which(options != ch_card)]],
        Q_right_card = Q_cards[options[2]],
        Q_left_card = Q_cards[options[1]],
        exp_val_right=expvalues[options[2], trial],
        exp_val_left=expvalues[options[1], trial],
        exp_val_ch = expvalues[ch_card, trial],
        exp_val_unch = expvalues[options[which(options != ch_card)], trial],
        PE_cards,
        alpha,
        beta
      )
      df=rbind(df,dfnew)
      #updating Qvalues
      
      Q_cards[ch_card] = Q_cards[ch_card]  + alpha * PE_cards

    }
  }     
  
  return (df)
}