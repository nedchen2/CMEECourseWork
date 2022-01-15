# Language: R
# Script: break.R
# Des: Illustrate R control flow tools : while - break
# Usage: Rscript break.R
# Date: Oct, 2021
# Author: Congjia Chen

i <- 0 #Initialize i
while(i < Inf) {
    if (i == 10) {
        break 
    } # Break out of the while loop! 
    else { 
        cat("i equals " , i , " \n")
        i <- i + 1 # Update i
    }
}

