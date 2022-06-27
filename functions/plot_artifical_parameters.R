#Aim:
#create a quick graphical summary of the artificial parameters that were sampled

plot_artifical_parameters<-function(artifical_parameters,plot_method){
  
    #draw histograms from individual parameters
    data=as.data.frame(artifical_parameters$individual_parameters)
    data_long <- data %>%                        
      pivot_longer(colnames(data)) %>% 
      as.data.frame()
    
    ggp1 <- ggplot(data_long, aes(x = value)) 
    #dot method
    if(plot_method=='hist'){
      ggp1=ggp1+geom_histogram(color='navy',fill='blue') 
    }
    
    #dot method
    if(plot_method=='dot'){
      ggp1=ggp1+geom_dotplot(color='navy',fill='blue') 
    }
    
    #dot method
    if(plot_method=='density'){
      ggp1=ggp1+geom_density(color='navy',fill='blue') 
    }
    
    ggp1=ggp1+facet_wrap(~ name, scales = "free")
    
    
    
    #generate a table with population parameters
    x=data.frame(location=artifical_parameters$population_location,
                 scale   =artifical_parameters$population_scale,
                 names   =artifical_parameters$names)
    
    
    ggp2=grid.table(x)
    
    #plot everything together
    grid.arrange(tableGrob(x),ggp1)
  
}