functions {
 real my_func(real x) {
   real a;
   a=x^2;
   return a;
 }
}

data {
  
  int <lower =1> N; // sample size
  vector [N] x; //predictor
  vector [N] y; //outcome
  
}

parameters {
 real alpha; //intercept
 real beta; //slope
 real beta2; //slope
 real <lower=0> sigma; //sd error
}

transformed parameters {

}
model {
 vector [N] x_squared;
  for (i in 1:N) {
  x_squared[i] = my_func(x[i]);
  if (i % 20 ==0){
  print(x_squared[i]);
  }
  }
  
  alpha ~ normal(0,50);
  beta ~ normal(0,50);
  beta2 ~ normal(0,50);
  //sigma ~ lognormal(3,1);
  y~normal(alpha+beta*x+x_squared*beta2,sigma);
}