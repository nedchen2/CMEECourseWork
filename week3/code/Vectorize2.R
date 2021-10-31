# Language: R
# Script: Vectorize2.R
# Des: Illustrate R Vectorization 2
# Usage: Rscript Vectorize2.R
# Date: Oct, 2021

# Runs the stochastic Ricker equation with gaussian fluctuations
rm(list = ls())
#runif(20, min=0, max=2)
#rnorm(10, m=0, sd=1)
stochrick <- function(p0 = runif(1000, .5, 1.5), r = 1.2, K = 1, sigma = 0.2,numyears = 100){
  N <- matrix(NA, numyears, length(p0))  #initialize empty matrix, numyears as row,length as column
  N[1, ] <- p0
  for (pop in 1:length(p0)) { #loop through the populations

    for (yr in 2:numyears){ #for each pop, loop through the years
      #browser()
      N[yr, pop] <- N[yr-1, pop] * exp(r * (1 - N[yr - 1, pop] / K) + rnorm(1, 0, sigma) ) # add one fluctuation from normal distribution to each single col
     }
  
  }
 return(N)

}
#res1<-stochrick()
print("Stochastic Ricker takes:")
print(system.time(res1<-stochrick()))


# Now write another function called stochrickvect that vectorizes the above to
# the extent possible, with improved performance: 

# ===================================================================

rm(list = ls())
#Method
stochrickvect <- function(p0 = runif(1000, .5, 1.5), r = 1.2, K = 1, sigma = 0.2,numyears = 100){
  N <- matrix(NA, numyears, length(p0))  #initialize empty matrix
  N[1, ] <- p0
  for (yr in 2:numyears){
    N[yr, ] <- N[yr-1, ] * exp(r * (1 - N[yr - 1, ] / K) + rnorm(numyears, 0, sigma)) # add one fluctuation from normal distribution
  }
  return(N)
}

print("Vectorized Stochastic Ricker takes:")
print(system.time(res2 <- stochrickvect()))
