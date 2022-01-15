# Language: R
# Script: preallocate.R
# Des: So writing a for loop that resizes a vector repeatedly makes R re-allocate memory repeatedly, which makes it slow. 
# Usage: Rscript preallocate.R
# Date: Oct, 2021
# Author: Congjia Chen

#for loop
NoPreallocFun <- function(x){
    a <- vector() # empty vector
    for (i in 1:x) {
        a <- c(a, i)
        print(a)
        print(object.size(a))
    }
}

system.time(NoPreallocFun(10))

#
PreallocFun <- function(x){
    a <- rep(NA, x) # pre-allocated vector, we have set a new vector previously
    for (i in 1:x) {
        a[i] <- i
        print(a)
        print(object.size(a))
    }
}
#run time
system.time(PreallocFun(10))
