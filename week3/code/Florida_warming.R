# Language: R
# Script: Florida_warming.R
# Des: Is Florida getting warmer? 
# Usage: Rscript Florida_warming.R
# Date: Oct, 2021
# Input: ../data/KeyWestAnnualMeanTemperature.RData
# Output: the density plot of coeff distribution

require(ggplot2)
require(ggthemes)
# draw a histogram
rm(list=ls())

load("../data/KeyWestAnnualMeanTemperature.RData")

#ls()
#plot(ats)

correlation_of_successive <- cor(ats$Temp,ats$Year) #calculate the cor of the temp and year

mysample <- function(df){ 
  #randomly reshuffling the temperatures (i.e., randomly re-assigning temperatures to years), and recalculating the correlation coefficient (and storing it)
  #df : dataframe with Temp and year
  
  pop_sample <- cbind(df[,1],df[sample(nrow(df),nrow(df)),2]) #cbind the randomly sampled Temp col and the original year col 
  return(cor(pop_sample[,1],pop_sample[,2]))
}

calculate_p_value <- function(resultset){
  #Calculate what fraction of the random correlation coefficients were greater than the observed one
  #resultset : a list of randomly sampled cor between temp and years
  
  fraction <- length(resultset[abs(resultset) > abs(correlation_of_successive)])/length(resultset)
  return(fraction)
}

plot_the_distribution <- function(result){
  dfresult <- as.data.frame(result)
  p = ggplot(dfresult,aes(x=result))+geom_density(color="black",fill="grey") +
        theme_economist_white() + geom_vline(xintercept = correlation_of_successive,linetype=3,colour = "blue")+xlab("Correlation Coefficient")
  ggsave("../results/Density_plot.png",width=5,height=3.7,plot=p)
  return (p)
}

main_function <- function(num){ 
  #main function of the whole program
  #num is the repeat times
  N <- ats
  result <- sapply(1:num, function(i) mysample(N))
  picture <- plot_the_distribution(result) # plot
  score_result <- calculate_p_value(result)
  return(paste0("p-value:", score_result, " (",num," repeats)"))
}

main_function(10000) # run the main function with 10000 repeats
