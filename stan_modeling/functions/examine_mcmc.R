examine_mcmc <- function(fit,path, mypars) {
  library(purrr)

  p = list()
  for (i in seq_along(mypars)) {
    pars_matrix <- fit$draws(variables = mypars[i], format = 'matrix')
    # Trace plots
    p[[i]] = mcmc_trace(pars_matrix)
  }
  print(fit)
  draws = fit$draws(variables = mypars)
  pairs = mcmc_pairs(draws)
  combined_plots <- c(p, list(pairs))
  do.call("grid.arrange", c(combined_plots, ncol = 2))
}