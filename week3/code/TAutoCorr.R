#load the data and plot it
#plot(ats, type="l")
#For this, you need to calculate the correlation between n-1 pairs of years, where n is the total number of years.
#initialize a new matrix

load("../data/KeyWestAnnualMeanTemperature.Rdata")

reformat_matrix <- function(row = 99, col = 4) {
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

mysample <- function(df,n){
  pop_sample <-df[sample(nrow(df),n),]
  return(cor(pop_sample[,3],pop_sample[,4]))
}

calculate_p_value <- function(resultset){
  fraction <- length(resultset[resultset > cor(N[,3],N[,4])])/length(resultset)
  return(fraction)
}

main_function <- function(n,num){ # n is the size of the random sample, num is the repeat times
  N <- reformat_matrix() #initialize a matrix
  result <- sapply(1:num, function(i) mysample(N, n))
  score_result <- calculate_p_value(result)
  return(score_result)
}

main_function(66,10000)

            
