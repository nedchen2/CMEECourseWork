#Author :Congjia.chen
#Function : Baranyi model fitting and AIC BIC CALCULATION
#Input ../results/Csvafterpreprocessing2.csv
#      ../results/straightLine_result.csv
#Output ../results/Baranyi_model_result.csv
#dep: tidyverse, minpack.lm

# LAG phase 1/3
#import the package
suppressPackageStartupMessages(require("minpack.lm"))
suppressPackageStartupMessages(require(tidyverse))


data_model2 <- read.csv("../results/Csvafterpreprocessing2.csv",stringsAsFactors = T)

straData <- read.csv("../results/straightLine_result.csv",stringsAsFactors = T)

#model
baranyi <- function(x,N_0,K,r_max,t_lag) {
  return (N_0 +r_max * (x + (1/r_max) * log(exp(-r_max*x) + 
    exp(-r_max * t_lag) - exp(-r_max * (x + t_lag)))) - 
    log(1 + ((exp(r_max * (x + (1/r_max) * log(exp(-r_max*x) + 
    exp(-r_max * t_lag) - exp(-r_max * (x + t_lag)))))-1)/(exp(K-N_0)))))
}

#N_0:initial value of abundance
#r_max : maximum growth rate 
#K: carryiing capacity (maximum abundance)
#lamba: lagphase

#pre-allocation
l = vector("list",length(unique(data_model2$ID)))

#number of the parameter
k = 4

# predicted length pf list
length_of_list <- k * 4 + 6

#Model fitting report
Model_fitting <- function (vecterID = seq(length(unique(data_model2$ID)))) {
  # because of the use of different start value, some of the models in different id will show the error. Therefore, this vecter is used to record the id with error
  resids <- c()
  for (i in vecterID){
    df_subset = subset(data_model2, ID == i)
    r_max_start_first <- as.numeric(subset(straData, ID == i,select = "Time_Estimate")$Time_Estimate)
    # start value
    # first we need some starting parameters for the model
    N_0_start <- min(df_subset$LogPopBio) # lowest population size
    K_start <- max(df_subset$LogPopBio) # highest population size
    r_max_start <- r_max_start_first # use our estimate from the OLS fitting from above #maybe correlate from the OLS method
    t_lag_start <-df_subset$Time[which.max(diff(diff(df_subset$LogPopBio)))] # use the root value as start
    
      
    fit_model <- try(nlsLM(LogPopBio ~ baranyi(x = Time, N_0,K,r_max,t_lag), df_subset,
                           list(r_max = r_max_start,N_0 = N_0_start, K = K_start, t_lag = t_lag_start), control = list(maxiter = 200)),silent = T)
    
    if (as.vector(summary(fit_model))[2] != "try-error"){
      # create the report data frame
      report_tmp <- as.data.frame(coef(summary(fit_model)))
      report_tmp["Parameter"] <- rownames(report_tmp) #add parameter to one col
      # convert to longer sheet
      report_tmp2 <- report_tmp %>% pivot_longer(cols= !c(Parameter), names_to = "StatMethod", values_to = "StatValue")
      report_tmp2["ID"] <- i
      report_tmp2["SampleSize"] <- nrow(df_subset)
      report_tmp2["AIC"] <- AIC(fit_model)
      report_tmp2["AIC_C"] <- AIC(fit_model) + 2 * k * (k + 1)/ (nrow(df_subset) - k -1)
      report_tmp2["BIC"] <- BIC(fit_model)
      report_tmp2["Unit"] <- as.vector(unique(df_subset$PopBio_units))
      #convert the coefficient matrix to wide sheet
      report <- report_tmp2 %>% pivot_wider(names_from = c("Parameter","StatMethod"), values_from = StatValue)
      #save the report to pre-allocation 
      l[[i]] <- report
      colname2 <- colnames(report)} #get the colname
    else{ # if there are try-error, give NA to the result
      resids <- c(resids,i) #store the ids with error to resids
      l[[i]] = c(i,rep(NA,length_of_list-1))
      }
  }
  out = list(one = resids, two = l,Three =colname2)
  return(out)
}

# check the first fit result 
first_fit_result <- Model_fitting()
l <- first_fit_result$two
print(paste0(length(first_fit_result$one)," IDs failed to fit the model"))

df <- data.frame(matrix(unlist(l),nrow=length(unique(data_model2$ID)),byrow = T))
colnames(df) <- gsub(" ","",first_fit_result$Three)#remove the space in the colnames

write.csv(df,"../results/Baranyi_model_result.csv",row.names = F)

print ("=========================Baranyi growth model fitting done===========================")