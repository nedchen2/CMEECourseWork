# Language: R
# Script: next.R
# Des: pass to next iteration of loop,  skip current loop
# Usage: Rscript next.R
# Date: Oct, 2021
# Author: Congjia Chen

for (i in 1:10) {
  if ((i %% 2) == 0) # check if the number is odd
    next # pass to next iteration of loop 
  print(i)
}