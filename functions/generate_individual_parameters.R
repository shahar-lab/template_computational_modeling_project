#Aim: 
#this functions take 'artificial_parameters' list with information regarding
#model parameters (names, population locations, scales and transformation)
#and generate individual parameters

generate_individual_parameters=function(model_parameters,Nsubjects,plotme){

#-----------------------------------------------------------
#sample individual parameters based on the population definitions in 'artifical parameters'  
  #pre-allocation
  x=matrix(data = NA, nrow = Nsubjects, ncol = length(model_parameters$names),)
  
  #sample individual parameters
  for (p in 1:length(model_parameters$names)){
    
    #no transformation
    if(model_parameters$transformation[p]=='none'){
      
      x[,p]=(model_parameters$artificial_population_location[p]+
             model_parameters$artificial_population_scale[p]*rnorm(Nsubjects))
    }
    
    
    #logit transformation (between 0 to 1)
    if(model_parameters$transformation[p]=='logit'){
      
      x[,p]=plogis(qlogis(model_parameters$artificial_population_location[p])+
                          model_parameters$artificial_population_scale[p]*rnorm(Nsubjects))
      
    }
    
    
  }
  
  #add columns names
  colnames(x)=model_parameters$names
  
  #assign back to the output file
  model_parameters$artificial_individual_parameters<-x
  
  return(model_parameters)
}
