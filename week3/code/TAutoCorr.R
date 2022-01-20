# Language: R
# Script: TAutoCorr.R
# Des: Calculate the correlation between n-1 pairs of years
# Usage: Rscript TAutoCorr.R
# Date: Dec, 2021
# Author: Group 3


#### =============== loading ======================= 
require(ggplot2)
require(ggthemes)

load("../data/KeyWestAnnualMeanTemperature.RData")

set.seed(17)

reshape_matrix <- function(row = 99, col = 4) {
  # reshaping the matrix
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
permuting <- function(df){
  # permuting the data
  # get the correlation coefficient after permuting them
  pop_sample <-cbind(df[,3],df[sample(nrow(df),nrow(df)),4]) 
  return(cor(pop_sample[,1],pop_sample[,2]))
}

calculate_p_value <- function(resultset,N){
  #calculate the pvalue
  # Argument:
  # resultset is the vector of cor after permuting for 10000 times
  # N is the successive year dataframe after reshaping

  fraction <- length(resultset[resultset > cor(N[,3],N[,4])])/length(resultset)
  return(fraction)
}



plot_the_distribution1 <- function(result,correlation_of_successive){
  # plot the correlation - coefficient distribution
  dfresult <- as.data.frame(result)
  p = ggplot(dfresult,aes(x=result))+geom_density(color="black",fill="grey") +
    theme_economist_white(gray_bg = F) + geom_vline(xintercept = correlation_of_successive,linetype=3,colour = "blue")+xlab("Correlation Coefficient")
  ggsave("../results/Density_plot_of_Cor.png",width=5,height=3.7,plot=p)
  return (p)
}

main_function <- function(num,draw = F){ 
  # num is the repeat times
  # draw -- control draw the distribution or not
  N <- reshape_matrix() #reshaping the successive dataframe
  result <- sapply(1:num, function(i) permuting(N)) #store the result in one vector
  if (draw == T) {
    correlation_of_successive <- cor(N[,3],N[,4])
    plot_the_distribution1(result,correlation_of_successive)
  }
  score_result <- calculate_p_value(result,N) #calculate the p value
  return(score_result)
}


options(scipen = 200) # we do not want E

# ======== repreat 10000 times to have much more convergent p value
p1 <- main_function(10000,draw = T) # DRAW THE Distribution

#
# ==================================
# below is the function to deal with the random P value
# ==================================
# fluctuation of p value - we repeat 100 times to see the mean value

function_for_p_value_replication <- function(start = FALSE) {
  if (start){
   p_value_vector <- sapply(1:100, function(i) main_function(10000)) 
   mean_p_value <- mean(p_value_vector) # repeat 100 times to calculate the mean value of p 
   print (paste0(" Mean P-value is ", mean_p_value))
   p2 <- plot_the_distribution2(p_value_vector,mean_p_value)
  }
}

# plot the p - value distribution
plot_the_distribution2 <- function(result,mean_p_value){
  dfresult <- as.data.frame(result)
  p = ggplot(dfresult,aes(x=result))+geom_density(color="black",fill="grey") +
    theme_economist_white(gray_bg = F) + geom_vline(xintercept = mean_p_value,linetype=3,colour = "red")+xlab("P value")
  ggsave("../results/Density_plot_of_P.png",width=5,height=3.7,plot=p)
  return (p)
}

function_for_p_value_replication(TRUE) # if you do not want the p value distribution, set FALSE for the function