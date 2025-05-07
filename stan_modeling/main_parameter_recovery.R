#####Setup--------------------
rm(list = ls())
source('./functions/my_starter.R')

path = set_workingmodel() 

cfg = list(
  Nsubjects        = 100,
  Nblocks          = 4,
  Ntrials_perblock = 50,
  Narms            = 4, #number of arms in the task
  Nraffle          = 2, #number of arms offered for selection each trial
  expvalues        = read.csv('./functions/rndwlk.csv', header = F),
  splines = T
)

if(cfg$splines){
  cfg$num_knots=5 
  cfg$basis_matrix=bs(1:(cfg$Ntrials*cfg$Nblocks), df = cfg$num_knots)
}


#####Simulate data--------------------
# generate parameters
simulate_parameters(path,cfg,plotme=T)
load(paste0(path$data,'/model_parameters.Rdata'))

# generate trial-by-trial data
simulate_artifical_data(path,debug=F,cfg)
load(paste0(path$data,'/artificial_data.Rdata'))

# convert to format that stan likes
vars <- c(
  'first_trial_in_block',
  'ch_card',
  'ch_key',
  'card_left',
  'card_right',
  'reward',
  'selected_offer'
)

convert_to_stan_format(path,data_type="artificial",vars,cfg)

#####sample posterior--------------------

modelfit_compile(path, format = F)

modelfit_mcmc(
  path,
  data_path = paste0(path$data,'/simulated_standata.Rdata'),
  mymcmc = list(
    datatype = 'artificial' ,
    samples  = 2000,
    warmup  = 2000,
    chains  = 4,
    cores   = 4
  )
)

#####examine convergence--------------------
fit   = readRDS(paste0(path$data, '/modelfit_recovery.rds'))

mypars = paste0("mu_",model_parameters$names)

examine_mcmc(fit,path, mypars)

#examine recovery
examine_population_parameters_recovery(fit,path,datatype="artificial")

examine_individual_parameters_recovery(fit,path)

####examine parameters
#load parameters

Qnet_diff = fit$draws(variables = 'Qnet_diff', format = 'draws_matrix')

#plot posterior mean diff per trial
Qnet_diff=colMeans(Qnet_diff)
hist(Qnet_diff)

#examine splines
estimated_beta_t = colMeans(fit$draws(variables = 'beta_t', format = 'draws_matrix'))
df$estimated_beta_t=estimated_beta_t

cor(df$estimated_beta_t,df$beta)

# Compute the difference
df$diff_beta <- df$estimated_beta_t - df$beta

library(ggplot2)

library(ggplot2)

# Compute absolute difference
df$abs_diff_beta <- abs(df$estimated_beta_t - df$beta)

# Calculate mean and SD
mean_abs_diff <- mean(df$abs_diff_beta, na.rm = TRUE)
sd_abs_diff <- sd(df$abs_diff_beta, na.rm = TRUE)

# Plot histogram with mean ± SD lines
ggplot(df, aes(x = abs_diff_beta)) +
  geom_histogram(bins = 30, color = "black", fill = "skyblue", alpha = 0.7) +
  geom_vline(xintercept = mean_abs_diff, color = "red", linetype = "dashed", size = 1) +
  geom_vline(xintercept = mean_abs_diff + sd_abs_diff, color = "darkgreen", linetype = "dotted", size = 1) +
  geom_vline(xintercept = mean_abs_diff - sd_abs_diff, color = "darkgreen", linetype = "dotted", size = 1) +
  annotate("text", x = mean_abs_diff, y = Inf, label = paste0("Mean = ", round(mean_abs_diff, 3)), vjust = 2, color = "red") +
  annotate("text", x = mean_abs_diff + sd_abs_diff, y = Inf, label = paste0("+SD = ", round(mean_abs_diff + sd_abs_diff, 3)), vjust = 4, color = "darkgreen") +
  annotate("text", x = mean_abs_diff - sd_abs_diff, y = Inf, label = paste0("-SD = ", round(mean_abs_diff - sd_abs_diff, 3)), vjust = 4, color = "darkgreen") +
  labs(
    x = "|Estimated Beta - True Beta|",
    y = "Count",
    title = "Histogram of Absolute Differences with Mean ± SD"
  ) +
  theme_minimal()


library(ggplot2)
library(dplyr)

# Filter only subjects 1–10 if you want, or leave it for all
df_subset <- df 

# Add an index if needed
df_subset <- df_subset %>%
  group_by(subject) %>%
  mutate(draw_index = row_number())

# Plot with shared y-axis across panels
ggplot(df_subset, aes(x = draw_index, y = abs_diff_beta)) +
  geom_line(alpha = 0.6) +
  facet_wrap(~subject, scales = "fixed") +  # keep same y-axis for all
  labs(
    x = "Draw Index",
    y = "|Estimated Beta - True Beta|",
    title = "Absolute Beta Difference Across Trials per Subject"
  ) +
  theme_minimal()
