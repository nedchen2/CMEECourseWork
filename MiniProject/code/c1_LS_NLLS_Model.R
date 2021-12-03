# Author : Congjia Chen
# Dep:tidyberse,ggthemes
# Des:Compare the model with different criteria
# Output: the pngs ../results/All_pic and a csv which contains the best model parameter and type base on a specific criteria to ../results/
# Arguments: 1 <criteria> (choose from AIC_C,AIC or BIC)


rm(list = ls())
suppressPackageStartupMessages(require("tidyverse"))
suppressPackageStartupMessages(require("ggthemes"))

# READ THE ARG from the terminal
arg <- commandArgs(T)
if(length(arg) < 1){
  cat("Argument: You need to provide the criteria (AIC_C,AIC or BIC) that you want to use!")
  quit('no')
}

# check the criteria
if (arg[1] == "AIC") {
  criteria ="AIC"
  print ("======================Start Plotting the NonLinear Model=====================")
  cat ("The best models result will be output to ../results/BestModel_AIC  ")
}else if (arg[1] == "BIC"){
  criteria ="BIC"
  cat ("The best models result will be output to ../results/BestModel_BIC  ")
  
}else if (arg[1] == "AIC_C"){
  criteria ="AIC_C"
  cat ("The best models result will be output to ../results/BestModel_AIC_C  ")
}else {
  cat("Argument: You need to provide the criteria (AIC_C,AIC or BIC) that you want to use!")
  quit('no')
}



#Import models
straData = read.csv("../results/straightLine_result.csv",header = T) %>% select(-Adjusted_R)
quaData = read.csv("../results/QuadraticPloynomial_result.csv", header = T)%>% select(-Adjusted_R)
cubicData = read.csv("../results/CubicPloynomial_result.csv", header = T)%>% select(-Adjusted_R)
OriginData = read.csv("../results/Csvafterpreprocessing2.csv",header = T)
GompData <- read.csv("../results/gompertz_model_result.csv",header = T)
LogisticData <- read.csv("../results/Logistic_model_result.csv",header = T)
BarData <- read.csv("../results/Baranyi_model_result.csv",header = T)

#Create a function for calculate the RMSE
rmse <- function(real,pred){
  return(sqrt(mean((real-pred)*2)))
}

#define a function to extract the result
Extract_the_result <- function(data,i,content) {
  result <- as.numeric(subset(data, ID == i,select = content)[1])
  return(result)
}

# def plotting function
plot_test <- function (i) {
  
  # initialize the function
  SL  <- function(x) as.numeric(subset(straData, ID == i,select = "intercept_Estimate")$intercept_Estimate) + 
    (as.numeric(subset(straData, ID == i,select = "Time_Estimate")$Time_Estimate)) * x #ID 63
  Qua <- function(x)  as.numeric(subset(quaData, ID == i,select = "A0_Estimate")$A0_Estimate) + 
    (as.numeric(subset(quaData, ID == i,select = "A1_Estimate")$A1_Estimate)) * x + 
    (as.numeric(subset(quaData, ID == i,select = "A2_Estimate")$A2_Estimate)) * x^2 #ID 63 
  cubic <- function(x)  as.numeric(subset(cubicData, ID == i,select = "A0_Estimate")$A0_Estimate) + 
    as.numeric(subset(cubicData, ID == i,select = "A1_Estimate")$A1_Estimate) * x + 
    as.numeric(subset(cubicData, ID == i,select = "A2_Estimate")$A2_Estimate) * x^2 + 
    as.numeric(subset(cubicData, ID == i,select = "A3_Estimate")$A3_Estimate) * x^3
  gompertz_model <- function(x){ # Modified gompertz growth model (Zwietering 1990)
    return (Extract_the_result(GompData,i,"N_0_Estimate") + (Extract_the_result(GompData,i,"K_Estimate") - Extract_the_result(GompData,i,"N_0_Estimate")) * 
              exp(-exp(Extract_the_result(GompData,i,"r_max_Estimate") * exp(1) * (Extract_the_result(GompData,i,"t_lag_Estimate") - x)/
                         ((Extract_the_result(GompData,i,"K_Estimate") - Extract_the_result(GompData,i,"N_0_Estimate")) * log(10)) + 1)))
  }   
  
  #Logistic_model
  logistic_model <- function(x){ # The classic logistic equation
    return(Extract_the_result(LogisticData,i,"N_0_Estimate") * 
             Extract_the_result(LogisticData,i,"K_Estimate") * exp(Extract_the_result(LogisticData,i,"r_max_Estimate") * x)/
             (Extract_the_result(LogisticData,i,"K_Estimate") + Extract_the_result(LogisticData,i,"N_0_Estimate") * (exp(Extract_the_result(LogisticData,i,"r_max_Estimate") * x) - 1)))
  }
  
  
  #Baranyi_model
  baranyi <- function(x) {
    return (Extract_the_result(BarData,i,"N_0_Estimate") +Extract_the_result(BarData,i,"r_max_Estimate") * 
              (x + (1/Extract_the_result(BarData,i,"r_max_Estimate")) * 
                 log(exp(-Extract_the_result(BarData,i,"r_max_Estimate")*x) + 
                       exp(-Extract_the_result(BarData,i,"r_max_Estimate") * Extract_the_result(BarData,i,"t_lag_Estimate")) - exp(-Extract_the_result(BarData,i,"r_max_Estimate") * (x + Extract_the_result(BarData,i,"t_lag_Estimate"))))) - 
              log(1 + ((exp(Extract_the_result(BarData,i,"r_max_Estimate") * (x + (1/Extract_the_result(BarData,i,"r_max_Estimate")) * 
                                                                                log(exp(-Extract_the_result(BarData,i,"r_max_Estimate")*x) + 
                                                                                      exp(-Extract_the_result(BarData,i,"r_max_Estimate") * Extract_the_result(BarData,i,"t_lag_Estimate")) - 
                                                                                      exp(-Extract_the_result(BarData,i,"r_max_Estimate") * (x + Extract_the_result(BarData,i,"t_lag_Estimate"))))))-1)/(exp(Extract_the_result(BarData,i,"K_Estimate")-Extract_the_result(BarData,i,"N_0_Estimate"))))))
  }
  
  df_subset <- subset(OriginData, ID == i)
  unit <- as.vector(unique(df_subset$PopBio_units))
  ylab <-paste0("LogPopBio","(",unit,")")
  subtitle <- paste0( "Models of ID ",i)
  #plot
  p = ggplot(data=df_subset,aes(x = Time, y = LogPopBio)) + geom_point(size = 3) + 
    geom_function(aes(colour = paste0("StraightLine")),fun = SL) +
    geom_function(aes(colour = paste0("QuadraticPolynomial")),fun = Qua) +
    geom_function(aes(colour = paste0("CubicPolynomial")),fun = cubic)
  if (is.na(logistic_model(1))){ # to know which model are skipped 
    #print ("Skip the Logistic")
  }else {
    p = p + geom_function(aes(colour = paste0("Logistic")),fun = logistic_model)
  }
  
  if (is.na(gompertz_model(1))){
    #print ("Skip the gompertz")
  }else{
    p = p + geom_function(aes(colour = paste0("Gompertz")),fun = gompertz_model)
  }
  
  if (is.na(baranyi(1))){
    #print ("Skip the baranyi")
  }else{
    p = p + geom_function(aes(colour = paste0("Baranyi")),fun = baranyi ) 
  }
  
  p = p + scale_fill_gdocs() + theme_set(theme_gdocs())+  theme(aspect.ratio=1)+ 
    labs(x="Time(hours)",y=ylab,colour = "Model",subtitle = subtitle) + theme(legend.position = "right")  + 
    theme(plot.background = element_rect(fill = "white",colour = "white"))
  return (p)
}

#pre-allocation of the table list
l = vector("list",length(unique(OriginData$ID)))

#to have the same length of cols among three models, i created some supply dataframe with NAs
supply_qua = t(as.data.frame(rep(NA, length(colnames(cubicData))- length(colnames(quaData)))))
supply_stra = t(as.data.frame(rep(NA, length(colnames(cubicData))- length(colnames(straData)))))
supply_logistic = t(as.data.frame(rep(NA, length(colnames(cubicData))- length(colnames(LogisticData)))))

#create a dir for figure
if (file.exists("../results/All_pic") ){
  output_dir = "../results/All_pic"
}else{
  output_dir = "../results/All_pic"
  dir.create(output_dir)
}




for (i in seq(length(unique(OriginData$ID)))){
  
  df_subset <- subset(OriginData, ID == i)
  
  
  #Compare all the model
  #select the best model with different criteria
  
  vecter_name <- c("StraightLine","QuadraticPolynomial","CubicPolynomial","Gompertz","Logistic","Baranyi")
  vecter_value <- c(Extract_the_result(straData,i,criteria),Extract_the_result(quaData,i,criteria),Extract_the_result(cubicData,i,criteria),Extract_the_result(GompData,i,criteria),Extract_the_result(LogisticData,i,criteria),Extract_the_result(BarData,i,criteria))
  df_tmp <- as.data.frame(cbind(vecter_name,vecter_value))
  colnames(df_tmp) <- c("Model_Type","value")
  #df_tmp <- na.omit(df_tmp)
  df_tmp["value"] <- as.numeric(df_tmp$value)
  df_tmp["min"] <-  as.numeric(df_tmp$value[which.min(df_tmp$value)])
  df_tmp <- df_tmp %>% mutate(delta = ifelse(!is.na(value),round(value - min,2), value)) #calculate the delta AIC or BIC 
  
  the_Plausible_model_number <- nrow(subset(df_tmp,delta <= 2))
  the_Plausible_model_name <- paste(subset(df_tmp,delta <= 2 & delta > 0,select ="Model_Type")$Model_Type,collapse = ",")
  the_delta_number <- paste(subset(df_tmp,delta <= 2 & delta > 0,select ="delta")$delta,collapse = ",")
  Best_Model_name <- paste(subset(df_tmp,value == as.numeric(df_tmp$value[which.min(df_tmp$value)]),select ="Model_Type")$Model_Type,collapse = ",")

  #present the plot color and width and record the best model into data frame
  if (vecter_name[which.min(vecter_value)] == "QuadraticPolynomial") {
    result <- cbind(subset(quaData,ID == i),supply_qua) 
  } else if(vecter_name[which.min(vecter_value)] == "StraightLine"){
    result <- cbind(subset(straData,ID == i),supply_stra)
  } else if (vecter_name[which.min(vecter_value)] == "CubicPolynomial"){
    result <- subset(cubicData,ID == i) 
  }  else if (vecter_name[which.min(vecter_value)] == "Gompertz"){
    result <- subset(GompData,ID == i) 
  } else if (vecter_name[which.min(vecter_value)] == "Logistic"){
    result <- cbind(subset(LogisticData,ID == i),supply_logistic)
  }else{
    result <- subset(BarData,ID == i)
  }
  result <- result %>% mutate(Best_Model =  Best_Model_name  )
  result <- result %>% mutate(Plausible_Model_Number =  the_Plausible_model_number  ) #add the number here
  result <- result %>% mutate(Plausible_Model =  the_Plausible_model_name )
  result <- result %>% mutate(Plausible_Model_delta =  the_delta_number )
  #save the result to the list 
  l[[i]] <- result
  
  if (criteria == "AIC"){ #SAVE THE TIME for other criteria
  p = plot_test(i)
  name_of_pic <- paste0("ID",i,"All_Model_Plot.png")
  png(paste0(output_dir,"/",name_of_pic))
  print (p)
  dev.off()
  }
}

df <- data.frame(matrix(unlist(l),nrow=length(unique(OriginData$ID)),byrow = T)) # reformat the list to data frame
colnames(df) <-c(colnames(GompData),"Best_Model_type","the_Plausible_model_number","Plausible_model_name","DeltaValue") #remove the space in the colnames
outputfilename <- paste0("../results/BestModel_",arg[1],".csv")
write.csv(df,outputfilename,row.names = F)

print ("=====================Model fitting and visualization done====================")
