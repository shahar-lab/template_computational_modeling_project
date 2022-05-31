library(rstan)
stan_model1 = "functions/try_stan.stan"
x=2:101
y = (x**2)+rnorm(100,5,1)
stan_data = data.frame(x,y)
stan_data=append(list(N=100),stan_data)

fit <- stan(file = stan_model1, data = stan_data, warmup = 300, iter = 600, chains = 2, cores = 2, thin = 1)
summary(fit)