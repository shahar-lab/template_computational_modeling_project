#####Setup--------------------
rm(list = ls())
source('./functions/my_starter.R')

path = set_workingmodel()

#####Load stan data--------------------
sample="story"
data_path = paste0('data/data_analysis/empirical_standata_',sample,'.Rdata')

#####sample posterior--------------------

modelfit_compile(path, format = F)

modelfit_mcmc(
  path,
  data_path = data_path,
  sample=sample,
  
  mymcmc = list(
    datatype = 'empirical' ,
    samples  = 2000,
    warmup  = 2000,
    chains  = 4,
    cores   = 4
  )
)

#####examine results--------------------
mypars = c("population_scales[1]",
           "population_scales[2]")

examine_mcmc(path, mypars, datatype = 'empirical')

examine_population_parameters_recovery(path, datatype = 'empirical')


####examine model
#load parameters
fit   = readRDS("D:\\backup\\oil_framing_effect\\fixed_lambda\\modelfit_empirical_story.rds")
fit   = readRDS("D:\\backup\\oil_framing_effect\\fixed_lambda\\modelfit_empirical_abstract_no_PE.rds")
Qdiff = fit$draws(variables = 'Qdiff_external', format = 'draws_matrix')
Qval1 = fit$draws(variables = 'Qval1_external', format = 'draws_matrix')
Qval2 = fit$draws(variables = 'Qval2_external', format = 'draws_matrix')
Qval3 = fit$draws(variables = 'Qval3_external', format = 'draws_matrix')
Qval4 = fit$draws(variables = 'Qval4_external', format = 'draws_matrix')

PE    = fit$draws(variables = 'PE_external', format = 'draws_matrix')


