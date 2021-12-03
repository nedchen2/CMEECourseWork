#Author :Congjia.chen
#Function : Logistic model fitting and AIC BIC CALCULATION
#Input ../results/Csvafterpreprocessing2.csv
#     ../results/straightLine_result.csv
#Output ../results/Logistic_model_result.csv
#dep: tidyverse, minpack.lm

# mechanistic model : logistic equation
# we need the start values
suppressPackageStartupMessages(require("minpack.lm"))
suppressPackageStartupMessages(require(tidyverse))

data_model2 <- read.csv("../results/Csvafterpreprocessing2.csv",stringsAsFactors = T)

# import the result from straight linE model

straData <- read.csv("../results/straightLine_result.csv",stringsAsFactors = T)

# logistic equation
logistic_model <- function(t, r_max, K, N_0){ # The classic logistic equation
  return(N_0 * K * exp(r_max * t)/(K + N_0 * (exp(r_max * t) - 1)))
}

#pre-allocation
l = vector("list",length(unique(data_model2$ID)))

# pre-CONFIRM THE UNIT USED IN THE SPECIFIC ID

for (i in seq(length(unique(data_model2$ID)))){
  df_subset = subset(data_model2, ID == i)
if (length(unique(df_subset$PopBio_units)) == 1){
  #print ("One unit confirmed")
  unit <- unique(df_subset$PopBio_units)
}else{
  print ('WARNING: Found more than one units')
  stop('More than one units in one specific ID')
}
}

# parameter number
k = 3

# predicted length of list
length_of_list <- k * 4 + 6

# intialize the model fitting function
Model_fitting <- function (vecterID = seq(length(unique(data_model2$ID)))) {
  # because of the use of different start value, some of the models in different id will show the error. Therefore, this vecter is used to record the id with error
  resids <- c()
  for (i in vecterID){
    df_subset = subset(data_model2, ID == i)
    # start value
    N_0_start <- min(df_subset$LogPopBio) # lowest population size
    K_start <- max(df_subset$LogPopBio) # highest population size
    r_max_start <- as.numeric(subset(straData, ID == i,select = "Time_Estimate")$Time_Estimate)  # use our estimate from the OLS fitting from above
    # fit
    fit_model <- try(nlsLM(LogPopBio ~ logistic_model(t = Time, r_max, K, N_0), df_subset,
                           list(r_max=r_max_start, N_0 = N_0_start, K = K_start),control = list(maxiter = 200)),silent = T)
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
      colname2 <- colnames(report)} #} 
    else{ # if there are try-error, give NA to the result
      resids <- c(resids,i) #store the ids with error to resids
      l[[i]] = c(i,rep(NA,length_of_list-1))
    }
  }
  out = list(one = resids, two = l, Three = colname2)
  return(out)
}

# check the first fit result 
first_fit_result <- Model_fitting()
l <- first_fit_result$two

print(paste0(length(first_fit_result$one)," IDs failed to fit the model"))

df <- data.frame(matrix(unlist(l),nrow=length(unique(data_model2$ID)),byrow = T))
colnames(df) <- gsub(" ","",first_fit_result$Three) #remove the space in the colnames

write.csv(df,"../results/Logistic_model_result.csv",row.names = F)

print ("=========================Logistic growth model fitting done===========================") 






