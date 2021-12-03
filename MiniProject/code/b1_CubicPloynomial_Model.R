#Author :Congjia.chen
#Function : cubicPolynomial model fitting and AIC BIC CALCULATION
#Input ../results/Csvafterpreprocessing2.csv
#Output ../results/CubicPloynomial_result.csv
#dep: tidyverse, minpack.lm

# linear-OLS-cubic polynomial model fitting

#import packages
suppressPackageStartupMessages(require("minpack.lm"))
suppressPackageStartupMessages(require(tidyverse))


data_model2 <- read.csv("../results/Csvafterpreprocessing2.csv",stringsAsFactors = T)

#pre-allocation

l = vector("list",length(unique(data_model2$ID)))

# pre-CONFIRM THE UNIT USED IN THE SPECIFIC ID

for (i in seq(length(unique(data_model2$ID)))){
  df_subset = subset(data_model2, ID == i)
if (length(unique(df_subset$PopBio_units)) == 1){
  #print ("One unit confirmed")
  #unit <- unique(df_subset$PopBio_units)
}else{
  print ('WARNING: Found more than one units')
  stop('More than one units in one specific ID')
}
}

#Model fitting report #cubic
for (i in seq(length(unique(data_model2$ID)))){
  df_subset <- subset(data_model2, ID == i)
  # fit
  fit_model <- try(lm(data = df_subset,
           LogPopBio ~ poly(Time,3,raw = T)),silent = T)

  if (as.vector(summary(fit_model))[2] != "try-error"){
  
  #calculate the predicted length
  k = nrow(coef(summary(fit_model)))
    
  length_of_list <-  nrow(coef(summary(fit_model))) * 4 + 6  
  
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
  report_tmp2["Adjusted_R"] <- summary(fit_model)$adj.r.squared
  report_tmp2["Unit"] <- as.vector(unique(df_subset$PopBio_units))
  #convert the coefficient matrix to wide sheet
  report <- report_tmp2 %>% pivot_wider(names_from = c("Parameter","StatMethod"), values_from = StatValue)
  #save the report to pre-allocation 
  l[[i]] <- report
  colname2 <- colnames(report)} #get the colname
  else{ # if there are try-error, give NA to the result
    l[[i]] = c(i,rep(NA,length_of_list-1))
  }
}

df <- data.frame(matrix(unlist(l),nrow=length(unique(data_model2$ID)),byrow = T))
colnames(df) <- gsub(" ","",gsub("poly\\(Time, 3, raw = T\\)","A",gsub("\\(Intercept\\)","A0",colname2))) #remove the space in the colnames

write.csv(df,"../results/CubicPloynomial_result.csv",row.names = F)

print ("=========================Cubicploynomial growth model fitting done===========================")