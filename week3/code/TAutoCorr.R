# Language: R
# Script: DataWrang.R
# Des: Wrangling the Pound Hill Dataset
# Usage: Rscript DataWrang.R
# Date: Oct, 2021

#load the data and plot it
#plot(ats, type="l")
#For this, you need to calculate the correlation between n-1 pairs of years, where n is the total number of years.
#initialize a new matrix

load("../data/KeyWestAnnualMeanTemperature.RData")

reformat_matrix <- function(row = 99, col = 4) {
  # reformating the matrix
  
  N <- matrix(NA, row, col)
  for (i in 1:(length(ats$Year)-1)){
    #print (i)
    N[i,1] <- ats[i,1]
    N[i,2] <- ats[i+1,1]
    N[i,3] <- ats[i,2]
    N[i,4] <- ats[i+1,2]
  }
  return(N)
}

#you need to permute the original one
mysample <- function(df){
  #permuting the data
  
  pop_sample <-cbind(df[,3],df[sample(nrow(df),nrow(df)),4])
  return(cor(pop_sample[,1],pop_sample[,2]))
}

calculate_p_value <- function(resultset,N){
  #cal the pvalue
  
  fraction <- length(resultset[abs(resultset) > abs(cor(N[,3],N[,4]))])/length(resultset)
  return(fraction)
}

main_function <- function(num){ 
  # num is the repeat times
  
  N <- reformat_matrix() #initialize a matrix
  result <- sapply(1:num, function(i) mysample(N))
  score_result <- calculate_p_value(result,N)
  return(score_result)
}

main_function(10000)


            
