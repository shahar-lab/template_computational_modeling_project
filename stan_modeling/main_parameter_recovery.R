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
  cfg$num_knots=10 
  cfg$basis_matrix=bs(1:(cfg$Ntrials_perblock*cfg$Nblocks), df = cfg$num_knots)
  cfg$penalty_matrix=create_penalty_matrix(1:(cfg$Ntrials_perblock*cfg$Nblocks), cfg$basis_matrix)
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
  'trial',
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
  data_path = paste0(path$data,'/artificial_standata.Rdata'),
  mymcmc = list(
    datatype = 'artificial' ,
    samples  = 1000,
    warmup  = 1000,
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


# Plot median posterior beta for each trial
df_plot = data.frame(subject   = df$subject,
                     trial     = df %>% mutate(overall_trial = (block-1)*cfg$Ntrials_perblock + trial) %>%
                       pull(overall_trial),
                     true_beta = df$beta)

beta_t_summary = apply(fit$draws(variables="beta_t",format='draws_matrix'), 2, function(x) {
  c(median = median(x), lower = quantile(x, 0.05), upper = quantile(x, 0.95))
})
beta_t_summary_df = as.data.frame(t(beta_t_summary))
colnames(beta_t_summary_df) = c("posterior_median", "posterior_lower", "posterior_upper")

df_plot = cbind(df_plot, beta_t_summary_df)
beta_trial_summary <- df_plot %>%
  group_by(trial) %>%
  summarise(
    true_median          = median(true_beta),
    true_lower           = quantile(true_beta, 0.05),
    true_upper           = quantile(true_beta, 0.95),
    posterior_median     = median(posterior_median),
    posterior_lower      = median(posterior_lower),
    posterior_upper      = median(posterior_upper)
  )

ggplot(beta_trial_summary, aes(x = trial)) +
  # Posterior 90% CI ribbon
  geom_ribbon(
    aes(ymin = posterior_lower, ymax = posterior_upper),
    fill = "lightblue", alpha = 0.4
  ) +
  # Posterior median line
  geom_line(aes(y = posterior_median, color = "Recovered β"), linetype = "dashed", size = 1) +
  
  # True 90% CI ribbon
  geom_ribbon(
    aes(ymin = true_lower, ymax = true_upper),
    fill = "gray70", alpha = 0.3
  ) +
  # True median line
  geom_line(aes(y = true_median, color = "True β"), linetype = "solid", size = 1) +
  
  scale_color_manual(values = c("Recovered β" = "steelblue", "True β" = "black")) +
  labs(
    title = "Posterior vs. True β Across Trials",
    x = "Trial",
    y = "β value",
    color = ""
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
