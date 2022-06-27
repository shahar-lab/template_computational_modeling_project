#Aim: 
#this functions take 'artificial_parameters' list with information regarding
#model parameters (names, population locations, scales and transformation)
#and generate individual parameters

generate_individual_parameters=function(artifical_parameters,Nsubjects,plotme){

#-----------------------------------------------------------
#sample individual parameters based on the population definitions in 'artifical parameters'  
  #pre-allocation
  x=matrix(data = NA, nrow = Nsubjects, ncol = length(artifical_parameters$names),)
  
  #sample individual parameters
  for (p in 1:length(artifical_parameters$names)){
    
    #no transformation
    if(artifical_parameters$transformation[p]=='none'){
      
      x[,p]=(artifical_parameters$population_location[p]+
               artifical_parameters$population_scale[p]*rnorm(Nsubjects))
    }
    
    
    #logit transformation (between 0 to 1)
    if(artifical_parameters$transformation[p]=='logit'){
      
      x[,p]=plogis(qlogis(artifical_parameters$population_location[p])+
                     artifical_parameters$population_scale[p]*rnorm(Nsubjects))
      
    }
    
    
  }
  
  #add columns names
  colnames(x)=artifical_parameters$names
  
  #assign back to the output file
  artifical_parameters$individual_parameters<-x
  
  return(artifical_parameters)
}
