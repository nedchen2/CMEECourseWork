# Language: R
# Script: browse.R
# Des: R debugging with browser
# Usage: Rscript browse.R
# Date: Oct, 2021
# Author: Congjia Chen

Exponential <- function(N0 = 1, r = 1, generations = 10){
  # Runs a simulation of exponential growth
  # Returns a vector of length generations
  
  N <- rep(NA, generations)    # Creates a vector of NA
  
  N[1] <- N0
  for (t in 2:generations){
    N[t] <- N[t-1] * exp(r)
    browser() #debug with browser() in the console
  }
  return (N)
}

plot(Exponential(), type="l", main="Exponential growth")

#We will not cover advanced debugging here as we did in Python Chapter I, but look up traceback() (to find where the errors(s) are when a program crashes), and debug() (to debug a whole function).