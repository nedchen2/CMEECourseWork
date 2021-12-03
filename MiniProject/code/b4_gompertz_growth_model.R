#Author :Congjia.chen
#Function : Gompertz model fitting and AIC BIC CALCULATION
#Input ../results/Csvafterpreprocessing2.csv
#      ../results/straightLine_result.csv
#     ../results/CubicPloynomial_result.csv
#Output ../results/gompertz_model_result.csv
#dep: tidyverse, minpack.lm

# NLLS method
# Gompertz model 
# log transform 
suppressPackageStartupMessages(require("minpack.lm"))
suppressPackageStartupMessages(require(tidyverse))

#import the data
data_model2 <- read.csv("../results/Csvafterpreprocessing2.csv",stringsAsFactors = T)

# import the result from previous line model as the start value
straData <- read.csv("../results/straightLine_result.csv",stringsAsFactors = T)
# QuaData <-  read.csv("../results/QuadraticPloynomial_result.csv",stringsAsFactors = T)
cubicData <- read.csv("../results/CubicPloynomial_result.csv", header = T) #we will use the intersection with x axis of cubic model as the tlag

gompertz_model <- function(t, r_max, K, N_0, t_lag){ # Modified gompertz growth model (Zwietering 1990)
  return (N_0 + (K - N_0) * exp(-exp(r_max * exp(1) * (t_lag - t)/((K - N_0) * log(10)) + 1)))
}   

#pre-allocation
l = vector("list",length(unique(data_model2$ID)))

#para number
k =4

# predicted length pf list
length_of_list <- k * 4 + 6  

#Model fitting report
Model_fitting <- function (vecterID = seq(length(unique(data_model2$ID)))) {
  # because of the use of different start value, some of the models in different id will show the error. Therefore, this vecter is used to record the id with error
  resids <- c()
  for (i in vecterID){
  df_subset = subset(data_model2, ID == i)

  #calculate the t_lag start value
  cubic <- function(x)  as.numeric(subset(cubicData, ID == i,select = "A0_Estimate")$A0_Estimate) + 
  as.numeric(subset(cubicData, ID == i,select = "A1_Estimate")$A1_Estimate) * x + 
  as.numeric(subset(cubicData, ID == i,select = "A2_Estimate")$A2_Estimate) * x^2 + 
  as.numeric(subset(cubicData, ID == i,select = "A3_Estimate")$A3_Estimate) * x^3

  
  # =========================================== Use root to estimate the lag phase ==============================
    root1 <- try(uniroot(cubic, interval = c(-500,500),tol=0.01)[[1]],silent = T)
  if (as.vector(summary(root1))[2] == "try-error"){root1 <- 0}
  # ===========================================Althoug failed ======================================================
  # ========================================== Use derivative to calculate the rmax =============================
  #calculate the r_max from the cubic data
  #Derivitive of the original cubic model is the r (rate)
  CubicDeri <- function(x){
    return(
      as.numeric(subset(cubicData, ID == 1,select = "A1_Estimate")$A1_Estimate)  + 
        as.numeric(subset(cubicData, ID == 1,select = "A2_Estimate")$A2_Estimate) * 2 * x + 
        as.numeric(subset(cubicData, ID == 1,select = "A3_Estimate")$A3_Estimate) * 3 * x ^2)
  }
  #calculate the maximum r_max
  r_max_start = optimise(f=CubicDeri,lower = 0,upper = max(df_subset$Time) ,maximum = T)[[1]]
  
  # ========================================= Although failed ====================================================
  
  # start value
  # first we need some starting parameters for the model
  N_0_start <- min(df_subset$LogPopBio) # lowest population size
  K_start <- max(df_subset$LogPopBio) # highest population size
  r_max_start <-  as.numeric(subset(straData, ID == i,select = "Time_Estimate")$Time_Estimate) # use our estimate from the OLS fitting from above #maybe correlate from the OLS method
  t_lag_start <- df_subset$Time[which.max(diff(diff(df_subset$LogPopBio)))] 
  # fit
  fit_model <- try(nlsLM(LogPopBio ~ gompertz_model(t = Time, r_max, K, N_0,t_lag), df_subset,
          list(r_max=r_max_start, N_0 = N_0_start, K = K_start, t_lag = t_lag_start), control = list(maxiter = 200)),silent = T)

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

write.csv(df,"../results/gompertz_model_result.csv",row.names = F)

print ("=========================Gompertz growth model fitting done===========================")










