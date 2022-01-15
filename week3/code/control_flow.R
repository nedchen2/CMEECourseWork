# Language: R
# Script: control_flow.R
# Des: Illustrate R control flow tools including (if , for , while)
# Usage: Rscript control_flow.R
# Date: Oct, 2021
# Author: Congjia Chen

# Please indent your code for readability

# if statements
a <- TRUE
if (a == TRUE){
    print ("a is TRUE")
    } else {
    print ("a is FALSE")
}

# another way for if statements
z <- runif(1) ## Generate a uniformly distributed random number
if (z <= 0.5) {
    print ("Less than a half")
    }

#for loops
# 1:10 = seq(1,10,1)) or seq(10)
for (i in 1:10){
    j <- i * i
    print(paste(i, " squared is", j ))
}

#for loops for vector
for(species in c('Heliodoxa rubinoides', 
                 'Boissonneaua jardini', 
                 'Sula nebouxii')){
  print(paste('The species is', species))
}

# for loops for v1
# for loop can iterate in different iterable object ( same as python)
v1 <- c("a","bc","def")
for (i in v1){
    print(i)
}

# while loop
i <- 0
while (i < 10){
    i <- i+1
    print(i^2)  #i sqaure
}
