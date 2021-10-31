# Language: R
# Script: Vectorize1.R
# Des: Illustrate R Vectorization 1
# Usage: Rscript Vectorize1.R
# Date: Oct, 2021

M <- matrix(runif(1000000),1000,1000)

SumAllElements <- function(M){
  Dimensions <- dim(M) #
  Tot <- 0 #
  for (i in 1:Dimensions[1]){ #USE THE DIMENSION INDEX TO LOCATE EVERY SINGLE FACTOR IN THE MATRIX
    for (j in 1:Dimensions[2]){
      Tot <- Tot + M[i,j]
    }
  }
  return (Tot)
}
 
print("Using loops, the time taken is:")
print(system.time(SumAllElements(M)))

print("Using the in-built vectorized function, the time taken is:")
print(system.time(sum(M)))