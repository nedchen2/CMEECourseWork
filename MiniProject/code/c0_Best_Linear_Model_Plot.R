# Author : Congjia Chen
# Dep:tidyberse
# Des:Compare the linear model with different criteria, the best model will be plotted in a different color
# Output: the pngs ../results/Linear_pic and a csv which contains the best model parameter and type base on a specific criteria to ../results/
# Arguments: 1 <criteria> (choose from R2,AIC or BIC)

#House keeping
rm(list = ls())
suppressPackageStartupMessages(require("tidyverse"))

print ("======================Start Plotting the Linear Model=====================")
# READ THE ARG from the terminal
arg <- commandArgs(T)
if(length(arg) < 1){
  cat("Argument: You need to provide the criteria (R2,AIC or BIC) that you want to use!")
  quit('no')
}

#Import models
straData = read.csv("../results/straightLine_result.csv",header = T)
quaData = read.csv("../results/QuadraticPloynomial_result.csv", header = T)
cubicData = read.csv("../results/CubicPloynomial_result.csv", header = T)
OriginData = read.csv("../results/Csvafterpreprocessing2.csv",header = T)

#define a function to extract the result
Extract_the_result <- function(data,i,content) {
  result <- as.numeric(subset(data, ID == i,select = content)[1])
  return(result)
}

#pre-allocation of the table list
l = vector("list",length(unique(OriginData$ID)))

#to have the same length of cols among three models, i created some supply dataframe with NAs
supply_qua = t(as.data.frame(rep(NA, length(colnames(cubicData))- length(colnames(quaData)))))
supply_stra = t(as.data.frame(rep(NA, length(colnames(cubicData))- length(colnames(straData)))))

#create a dir for figure
if (file.exists("../results/Linear_pic") ){
  output_dir = "../results/Linear_pic"
}else{
  output_dir = "../results/Linear_pic"
  dir.create(output_dir)
}

# check the criteria
if (arg[1] == "R2"){
  criteria ="Adjusted_R"
}else if (arg[1] == "AIC") {
  criteria ="AIC"
}else if (arg[1] == "BIC"){
  criteria ="BIC"
}else{
  cat("Argument: You need to provide the criteria (R2,AIC or BIC) that you want to use!")
  quit('no')
}

if (criteria == "Adjusted_R"){

  for (i in seq(length(unique(OriginData$ID)))){

  df_subset <- subset(OriginData, ID == i)
  
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
  unit <- as.vector(unique(df_subset$PopBio_units))
  #read the result from the 

  #select the best model with different criteria/ Here we only use R_sqaure to label the best fitted curve
  vecter_name <- c("ID","StraightLine","QuadraticPolynomial","CubicPolynomial")
  vecter_value <- c(i,Extract_the_result(straData,i,criteria),Extract_the_result(quaData,i,criteria),Extract_the_result(cubicData,i,criteria))
  
  #present the plot color and width and record the best model into data frame
  if (vecter_name[which.max(vecter_value[-1])+1] == "QuadraticPolynomial") {
    col <- c("grey","orange","grey")
    lwd <- c(1,3,1)
    result <- cbind(subset(quaData,ID == i),supply_qua) %>% mutate(Type = "QuadraticPolynomial",
                                                                   R_2_stra = vecter_value[2],
                                                                   R_2_cubic = vecter_value[4])
  } else if(vecter_name[which.max(vecter_value[-1])+1] == "StraightLine"){
    col <- c("red","grey","grey")
    lwd <- c(3,1,1)
    result <- cbind(subset(straData,ID == i),supply_stra)  %>% mutate(Type = "StraightLine",
                                                                      R_2_qua = vecter_value[3],
                                                                      R_2_cubic = vecter_value[4])
  } else{
    col <- c("grey","grey","blue")
    lwd <- c(1,1,3)
    result <- subset(cubicData,ID == i) %>% mutate(Type = "CubicPolynomial",
                                                   R_2_stra = vecter_value[2],
                                                   R_2_qua = vecter_value[3])
  }
  #save the result to the list 
  l[[i]] <- result
  #plot the figure
  name_of_pic <- paste0("ID",i,"_LinearPlot.png")
  png(paste0("../results/Linear_pic/",name_of_pic))
  ylab <- paste0("ID",i,"LogPopBio","(",unit,")")
  model_name = c("StraightLine","QuadraticPolynomial","CubicPolynomial")
  
  #plot
  par(mar = c(5,5,5,12))
  par(mgp = c(2,0.5,0))
  plot(x = df_subset$Time, y = df_subset$LogPopBio, type = "p",xlab = paste0("Time(Hour)"),ylab = ylab)
  curve(SL,0,max(df_subset$Time), add = T, col = col[1],lwd = lwd[1])
  curve(Qua, 0, max(df_subset$Time), add = T,col = col[2],lwd = lwd[2])
  curve(cubic, 0, max(df_subset$Time), add = T, col = col[3],lwd = lwd[3])
  legend("right",model_name,   # Add legend
         fill=col,xpd = T,inset = -0.65,box.col = "white") 
  dev.off()
  }
}else { # for AIC and BIC
  for (i in seq(length(unique(OriginData$ID)))){
    
    df_subset <- subset(OriginData, ID == i)
    
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
    unit <- as.vector(unique(df_subset$PopBio_units))
    
    #select the best model with different criteria/ Here we only use R_sqaure to label the best fitted curve
    vecter_name <- c("ID","StraightLine","QuadraticPolynomial","CubicPolynomial")
    vecter_value <- c(i,Extract_the_result(straData,i,criteria),Extract_the_result(quaData,i,criteria),Extract_the_result(cubicData,i,criteria))
    
    #print(root1)
    #preset the plot color
    if (vecter_name[which.min(vecter_value[-1])+1] == "QuadraticPloynomial") {
      col <- c("grey","orange","grey")
      lwd <- c(1,3,1)
      result <- cbind(subset(quaData,ID == i),supply_qua) %>% mutate(Type = "QuadraticPolynomial",
                                                                     R_2_stra = vecter_value[2],
                                                                     R_2_cubic = vecter_value[4]
                                                                     )
    } else if(vecter_name[which.min(vecter_value[-1])+1] == "StraightLine"){
      col <- c("red","grey","grey")
      lwd <- c(3,1,1)
      result <- cbind(subset(straData,ID == i),supply_stra)  %>% mutate(Type = "StraightLine",
                                                                        R_2_qua = vecter_value[3],
                                                                        R_2_cubic = vecter_value[4])
    } else{
      col <- c("grey","grey","blue")
      lwd <- c(1,1,3)
      result <- subset(cubicData,ID == i) %>% mutate(Type = "CubicPolynomial",
                                                     R_2_stra = vecter_value[2],
                                                     R_2_qua = vecter_value[3])
    }
    #save the result to the list
    l[[i]] <- result
    
    #plot the figure
    name_of_pic <- paste0("ID",i,"_LinearPlot.png")
    png(paste0("../results/Linear_pic/",name_of_pic))
    ylab <- paste0("ID",i,"LogPopBio","(",unit,")")
    plot(x = df_subset$Time, y = df_subset$LogPopBio, type = "p",xlab = paste0("Time(Hour)"),ylab = ylab)
    curve(SL,0,max(df_subset$Time), add = T, col = col[1],lwd = lwd[1])
    curve(Qua, 0, max(df_subset$Time), add = T,col = col[2], lwd = lwd[2])
    curve(cubic, 0, max(df_subset$Time), add = T, col = col[3],lwd = lwd[3])
    dev.off()
  }
}

#format the list tp dataframe
df <- data.frame(matrix(unlist(l),nrow=length(unique(OriginData$ID)),byrow = T)) # reformat the list to data frame
colnames(df) <-c(colnames(cubicData),"Model_type","option_Model1_para","option_model2_para") #remove the space in the colnames
outputfilename <- paste0("../results/Best_Linear_Model_",arg[1],".csv")
write.csv(df,outputfilename,row.names = F)

print ("==================================End of Linear Model PLotting============================")


