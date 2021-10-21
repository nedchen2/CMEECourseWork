# Runs the stochastic Ricker equation with gaussian fluctuations

rm(list = ls())

#runif(20, min=0, max=2)
#rnorm(10, m=0, sd=1)

stochrick <- function(p0 = runif(1000, .5, 1.5), r = 1.2, K = 1, sigma = 0.2,numyears = 100){
  N <- matrix(NA, numyears, length(p0))  #initialize empty matrix, numyears as row,length as column

  N[1, ] <- p0

  for (pop in 1:length(p0)) { #loop through the populations

    for (yr in 2:numyears){ #for each pop, loop through the years

      N[yr, pop] <- N[yr-1, pop] * exp(r * (1 - N[yr - 1, pop] / K) + rnorm(1, 0, sigma)) # add one fluctuation from normal distribution
    
     }
  
  }
 return(N)

}

#res1<-stochrick()
print("Stochastic Ricker takes:")
print(system.time(res1<-stochrick()))


# Now write another function called stochrickvect that vectorizes the above to
# the extent possible, with improved performance: 

# print("Vectorized Stochastic Ricker takes:")
# print(system.time(res2<-stochrickvect()))

# =================================================================

# Method1
create_empty_matrix <- function (p0 = runif(1000, .5, 1.5),numyears = 100) {
  N <- matrix(NA, numyears, length(p0))  #initialize empty matrix, numyears as row,length as column
  N[1, ] <- p0
  return(N)
}

stochrickvect <- function(p0 = runif(1000, .5, 1.5), r = 1.2, K = 1, sigma = 0.2,numyears = 100) {
  N <- create_empty_matrix(p0,numyears)
  result4 <- sapply(1:length(p0), function(pop) {
    sapply(2:numyears, function(yr) {
      N[yr, pop] <<- N[yr-1, pop] * exp(r * (1 - N[yr-1, pop] / K) + rnorm(1, 0, sigma)) #<<- important same as the shell
    })
  })
  return(result4)
}

print("Vectorized Stochastic Ricker takes:")
print(system.time(res2 <- stochrickvect()))

# Method 2
stochrick_method2 <- function(p0 = runif(1000, .5, 1.5), r = 1.2, K = 1, sigma = 0.2,numyears = 100){
  N <- matrix(NA, numyears, length(p0))  #initialize empty matrix, numyears as row,length as column
  N[1, ] <- p0
 #loop through the populations

  for (yr in 2:numyears){ #for each pop, loop through the years

    N[yr, ] <- N[yr-1, ] * exp(r * (1 - N[yr - 1, ] / K) + rnorm(1, 0, sigma)) # add one fluctuation from normal distribution
  }
 return(N)
}

stochrick_method2()

#res1<-stochrick()
print("Stochastic Ricker method 2 takes:")
print(system.time(res3<-stochrick_method2()))

