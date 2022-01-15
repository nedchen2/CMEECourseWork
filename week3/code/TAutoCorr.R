# Language: R
# Script: TAutoCorr.R
# Des: Calculate the correlation between n-1 pairs of years
# Usage: Rscript TAutoCorr.R
# Date: Dec, 2021
# Author: Congjia Chen

#load the data and plot it
#plot(ats, type="l")
#For this, you need to calculate the correlation between n-1 pairs of years, where n is the total number of years.
#initialize a new matrix

load("../data/KeyWestAnnualMeanTemperature.RData")

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
  #permuting the data
  #get the correlation coefficient after permuting them
  pop_sample <-cbind(df[,3],df[sample(nrow(df),nrow(df)),4]) 
  return(cor(pop_sample[,1],pop_sample[,2]))
  
}
calculate_p_value <- function(resultset,N){
  #calculate the pvalue
  fraction <- length(resultset[abs(resultset) > abs(cor(N[,3],N[,4]))])/length(resultset)
  return(fraction)
}


# plot the correlation - coefficient distribution
plot_the_distribution1 <- function(result,correlation_of_successive){
  dfresult <- as.data.frame(result)
  p = ggplot(dfresult,aes(x=result))+geom_density(color="black",fill="grey") +
    theme_economist_white(gray_bg = F) + geom_vline(xintercept = correlation_of_successive,linetype=3,colour = "blue")+xlab("Correlation Coefficient")
  ggsave("../results/Density_plot_of_Cor.png",width=5,height=3.7,plot=p)
  return (p)
}

main_function <- function(num,draw = F){ 
  # num is the repeat times
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

p1 <- main_function(10000,draw = T) # DRAW THE Distribution

# fluctuation of p value - we repeat 100 times to see the mean value
p_value_vector <- sapply(1:100, function(i) main_function(10000))

mean_p_value <- mean(p_value_vector) # repeat 100 times to calculate the mean value of p 

print (paste0(" Mean P-value is ", mean_p_value))


#### =============== plotting ======================= 
require(ggplot2)
require(ggthemes)


# plot the p - value distribution
plot_the_distribution2 <- function(result){
  dfresult <- as.data.frame(result)
  p = ggplot(dfresult,aes(x=result))+geom_density(color="black",fill="grey") +
    theme_economist_white(gray_bg = F) + geom_vline(xintercept = mean_p_value,linetype=3,colour = "red")+xlab("P value")
  ggsave("../results/Density_plot_of_P.png",width=5,height=3.7,plot=p)
  return (p)
}

p2 <- plot_the_distribution2(p_value_vector)



            
