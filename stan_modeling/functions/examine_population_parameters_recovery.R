examine_population_parameters_recovery <- function(fit,path, datatype) {
  library(ggplot2)
  library(ggpubr)
  library(bayestestR)
  library(stringr)
  library(ggdist)
  library(gridExtra)
  
  # Define plotting theme
  mytheme <- theme_pubclean() +
    theme(
      panel.border    = element_blank(),
      axis.line       = element_line(color = 'gray'),
      text            = element_text(size = 14, family = "serif"),
      axis.title      = element_text(size = 14),
      legend.position = "right",
      plot.title      = element_text(hjust = 0.5),
      axis.ticks.y    = element_blank(),
      axis.text.y     = element_blank()
    )
  source(paste0(path$model, '_parameters.r'))
  load(paste0(path$data, '/model_parameters.Rdata'))
  Nparameters <- length(model_parameters$names) 
  # Load recovered parameters
  if (datatype == 'empirical') {
    message('Using empirical data')
     # Assumes pre-loaded model_parameters
  } else if (datatype == 'artificial') {
    message('Using artificial data')
  } else {
    stop("Invalid datatype: must be 'empirical' or 'artificial'")
  }
  
  # Collect plots for each parameter
  plots <- list()
  for (i in 1:Nparameters) {
    param_name <- model_parameters$names[i]
    stan_var   <- paste0('mu_', param_name)
    
    samples <- fit$draws(variables = stan_var, format = 'matrix')
    samples <- as.numeric(unlist(samples))
    
    # Apply inverse transformation if needed
    if (model_parameters$transformation[i] == 'logit') {
      samples <- plogis(samples)
    } else if (model_parameters$transformation[i] == 'exp') {
      samples <- exp(samples)
    }
    
    true_value <- if (datatype == 'artificial') {
      model_parameters$artificial_population_location[i]
    } else {
      NULL
    }
    
    plots[[i]] <- ggplot(data.frame(samples = samples), aes(x = samples)) +
      ggdist::stat_halfeye(
        point_interval = 'median_hdi',
        .width = c(0.89, 0.97),
        fill = 'grey'
      ) +
      geom_vline(
        xintercept = true_value,
        linetype = "dotted",
        color = "blue",
        linewidth = 1.5
      ) +
      xlab(param_name) +
      mytheme
  }
  
  # Arrange and display all plots in a single column
  do.call("grid.arrange", c(plots, ncol = 1))
}
