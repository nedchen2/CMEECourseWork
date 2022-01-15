# Language: R
# Script: apply2.R
# Des: illusstrate the use of apply by self-defined function
# Usage: Rscript apply2.R
# Date: Oct, 2021
# Author : Congjia Chen

SomeOperation <- function(v){ # (What does this function do?)
  if (sum(v) > 0){ #note that sum(v) is a single (scalar) value
    return (v * 100)
  }
  return (v)
}

M <- matrix(rnorm(100), 10, 10)
print (apply(M, 1, SomeOperation))