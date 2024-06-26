#####Setup--------------------
rm(list = ls())
source('./functions/my_starter.R')

path = set_workingmodel()

cfg = list(
  Nsubjects        = 100,
  Nblocks          = 2,
  Ntrials_perblock = 200,
  Narms            = 4, #number of arms in the task
  Nraffle          = 2, #number of arms offered for selection each trial
  rndwlk           = read.csv('./functions/rndwlk.csv', header = F)
)


#####Simulate data--------------------
generate_artificial_data(cfg = cfg)
load(paste0(path$data,'/artificial_data.Rdata'))
#####sample posterior--------------------

modelfit_compile(path, format = F)

modelfit_mcmc(
  path,
  data_path = paste0('data/stan_ready_data_files/artificial_standata_', path$name, '.Rdata'),
  
  mymcmc = list(
    datatype = 'artificial' ,
    samples  = 1000,
    warmup  = 1000,
    chains  = 4,
    cores   = 4,
    refresh = 20
  )
)

#####examine results--------------------
mypars = c("population_locations_transformed[1]",
           "population_locations[1]")

examine_mcmc(path, mypars, datatype = 'artificial')

examine_population_parameters_recovery(path, datatype = 'artificial')

examine_individual_parameters_recovery(path)


####examine model
#load parameters
fit   = readRDS(paste0(path$data, '/modelfit_recovery.rds'))
Qdiff = fit$draws(variables = 'Qdiff_external', format = 'draws_matrix')
Qval1 = fit$draws(variables = 'Qval1_external', format = 'draws_matrix')
Qval2 = fit$draws(variables = 'Qval2_external', format = 'draws_matrix')
Qval3 = fit$draws(variables = 'Qval3_external', format = 'draws_matrix')
Qval4 = fit$draws(variables = 'Qval4_external', format = 'draws_matrix')

PE    = fit$draws(variables = 'PE_external', format = 'draws_matrix')
