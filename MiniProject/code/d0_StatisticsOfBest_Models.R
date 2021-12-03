# Author : Congjia Chen
# Dep:tidyberse,ggthemes,ggpubr
# Des: Start statistic analysis and preparing the figure for report
# Output: all the figures in the report


print ("======================Start statistic analysis and preparing the figure for report=======================")

if(!require("ggpubr")) {install.packages("ggpubr")}

suppressPackageStartupMessages(require("tidyverse"))
suppressPackageStartupMessages(require("ggthemes"))
suppressPackageStartupMessages(require("ggpubr"))

#import the data

BestR2 <- read.csv("../results/Best_Linear_Model_R2.csv",header = T)
BestAIC <- read.csv("../results/BestModel_AIC.csv",header = T)
BestBIC <-  read.csv("../results/BestModel_BIC.csv",header = T)
BestAIC_c <- read.csv("../results/BestModel_AIC_C.csv",header = T)

# every parameter of model

straData = read.csv("../results/straightLine_result.csv",header = T)
quaData = read.csv("../results/QuadraticPloynomial_result.csv", header = T)
cubicData = read.csv("../results/CubicPloynomial_result.csv", header = T)
OriginData = read.csv("../results/Csvafterpreprocessing2.csv",header = T)
GompData <- read.csv("../results/gompertz_model_result.csv",header = T)
LogisticData <- read.csv("../results/Logistic_model_result.csv",header = T)
BarData <- read.csv("../results/Baranyi_model_result.csv",header = T)

#
#define a function to extract the result
Extract_the_result <- function(data,i,content) {
  result <- as.numeric(subset(data, ID == i,select = content)[1])
  return(result)
}

#create a dir for figure
if (file.exists("../results") ){
  output_dir = "../results"
}else{
  output_dir = "../results"
  dir.create(output_dir)
}

## Figure used in the report

# Figure 1 : The growth of model application in microbial research

data <- read.csv("../sandbox/PubMed_Timeline_Results_by_Year.csv",row.names = NULL)
data2 <- data[-1,]

data2["Year"] <- as.factor(data2$row.names)
data2["counts"] <- as.numeric(data2$Search.query..microbial.modeling)
p1 <- ggplot(data = data2 , aes(x = Year, y =counts)) + geom_bar(stat= "identity") + theme_economist_white(gray_bg = F) + ylab("counts")+
  theme(axis.text.x = element_text(angle = 45, size=7, color="black",vjust = 1 ))

ggsave(paste0(output_dir,"/ModelGrowth.pdf"), plot=p1)
print("ModelGrowth Done")

# Figure2 -AB Linear Model result -- adj.r.sqaured
 
dfplot <- as.data.frame(BestR2 %>% count(Model_type,Model_type,sort=T) %>% mutate(Criteria = "adj.r.sqaured")) %>%  mutate(percent = n/sum(n) * 100 )

p2 = ggplot(data = dfplot, aes(x = Model_type, y = n, fill = Model_type)) + geom_bar(stat= "identity", width = 0.5) + 
  theme_economist_white(gray_bg = F) + 
  labs(x="",y="Counts of Best Fitted",fill = "Model Type") + scale_fill_economist()+ theme(legend.position = "none") +
  geom_text(aes(label = round(percent,2)),size = 4,position = position_dodge(0.8)) + theme(axis.text.x=element_text(size = 10))

p3 = ggplot(data = BestR2,aes(x = Model_type, y = Adjusted_R,fill = Model_type)) + geom_boxplot(width = 0.5)  + 
  theme_economist_white(gray_bg = F,horizontal = T) + scale_fill_economist()+
  labs(x="",y=expression(adj.R^2),fill = "Model Type") + theme(axis.text.x = element_blank()) + 
  theme(legend.position = "none")

p4 = ggarrange(p3,p2,ncol=1,nrow = 2,labels = c("A","B","C"),widths = c(5,2),heights = c(1,3),align = "v")


# Figure2 - C-LinearModelFitting

i = 113

df_subset <- subset(OriginData, ID == i)
unit <- as.vector(unique(df_subset$PopBio_units))
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

ylab <- paste0("LogPopBio","(",unit,")")
subtitle <- paste0("Linear Model of ID ",i)

QuaR_square <- round(as.numeric(subset(quaData, ID == i,select = "Adjusted_R")$Adjusted_R),2)
StraR_square <- round(as.numeric(subset(straData, ID == i,select = "Adjusted_R")$Adjusted_R),2)
cubic_square <- round(as.numeric(subset(cubicData, ID == i,select = "Adjusted_R")$Adjusted_R),2)

p5 = ggplot(data=df_subset,aes(x = Time, y = LogPopBio)) + geom_point() + 
  geom_function(aes(colour = paste0("StraightLine,",StraR_square)),fun = SL) +
  geom_function(aes(colour = paste0("QuadraticPolynomial,",QuaR_square)),fun = Qua) +
  geom_function(aes(colour = paste0("CubicPolynomial,",cubic_square)),fun = cubic) + scale_color_economist() + theme_minimal()+
  labs(x="Time(hours)",y=ylab,colour = "Model",subtitle = subtitle) + theme(legend.position = "bottom")

p6 = ggarrange(p4,p5,ncol=2,nrow = 1,labels = c("A","C"),widths = c(5,5),heights = c(1,3))

ggsave(paste0(output_dir,"/Linear_Model_result.pdf"), plot=p6,width = 10,height=8)
print("LinearModelResult Done")

# ==============Figure 6. Example of linear and Non-linear fitting plot ================

#define a function for plot
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
    print ("Skip the Logistic")
  }else {
    p = p + geom_function(aes(colour = paste0("Logistic")),fun = logistic_model)
  }
  
  if (is.na(gompertz_model(1))){
    print ("Skip the gompertz")
  }else{
    p = p + geom_function(aes(colour = paste0("Gompertz")),fun = gompertz_model)
  }
  
  if (is.na(baranyi(1))){
    print ("Skip the baranyi")
  }else{
    p = p + geom_function(aes(colour = paste0("Baranyi")),fun = baranyi ) 
  }

  p = p + scale_fill_gdocs() + theme_set(theme_gdocs())+  theme(aspect.ratio=1)+ 
  labs(x="Time(hours)",y=ylab,colour = "Model",subtitle = subtitle) + theme(legend.position = "right")  + 
  theme(plot.background = element_rect(fill = "white",colour = "white"))
  return (p)
}


p8 = plot_test(113)

p9 = plot_test(270) # exponential phase and stationary phase

p10 = plot_test(275) #lag phase and exponential phase and stationary phase

p11 = plot_test(277)

p12 = plot_test(64) # to illustrate the straight line 
  
p13 = plot_test(59) # to illustrate the straight line 

P_BU1=plot_test(11) # to illustrate the death phase
P_BU2=plot_test(96)# to illustrate the death phase

p_Figure3 = ggarrange(p8,p9,p10,p11,p12,p13,P_BU1,P_BU2,ncol=2,nrow = 4,labels = c("A","B","C","D","E","F","G","H"), widths = c(1,1), heights = c(1,1),align = "hv")

ggsave(paste0(output_dir,"/lsandNLLSModel.pdf"), plot=p_Figure3, height = 8, width = 10)

print("Example for Non-linear graph Done")

# ==============Figure 3 and Figure 4. The distribution of AIC and BIC ================


# Compare the similarity of different criteria/ whether AIC, BIC Support the same model

INT1 <- subset(BestAIC_c,select = c("ID","Best_Model_type"))
INT2 <- subset(BestAIC,select = c("ID","Best_Model_type"))
INT3 <- subset(BestBIC,select = c("ID","Best_Model_type"))

# AIC and AIC_C
percent_1 <- round(nrow(intersect(INT1,INT2))/nrow(INT2) * 100,2)
print (paste0(percent_1, "% of the IDs shows the same model selection based on AIC and AIC_C criteria"))

#  AIC and BIC
percent_2 <- round(nrow(intersect(INT2,INT3))/nrow(INT2) * 100,2)

print (paste0(percent_2, "% of the IDs shows the same model selection based on AIC and BIC criteria"))

# box plot

Stra=subset(straData,select = c("ID","AIC","BIC","AIC_C")) %>% mutate(Model = "Straightline")
Qua=subset(quaData,select = c("ID","AIC","BIC","AIC_C")) %>% mutate(Model = "QuadraticPolynomial")
CuBIC=subset(cubicData,select = c("ID","AIC","BIC","AIC_C")) %>% mutate(Model = "CubicPolynomial")
Gom=subset(GompData,select = c("ID","AIC","BIC","AIC_C")) %>% mutate(Model = "Gomertz")
Logistic=subset(LogisticData,select = c("ID","AIC","BIC","AIC_C")) %>% mutate(Model = "Logistic")
Bra=subset(BarData,select = c("ID","AIC","BIC","AIC_C")) %>% mutate(Model = "Baranyi")


P14 = ggplot(data = rbind(Stra,Qua,CuBIC,Gom,Logistic,Bra), aes(x= Model ,y= AIC,fill = Model)) + 
  geom_boxplot() + theme_economist_white(gray_bg = F) + labs(y ="AIC",x = "" ) +  theme(legend.position = "none") 

P15 = ggplot(data = rbind(Stra,Qua,CuBIC,Gom,Logistic,Bra), aes(x= Model ,y= BIC,fill = Model)) + 
  geom_boxplot() + theme_economist_white(gray_bg = F) +  theme(legend.position = "none") 

P16 = ggplot(data = rbind(Stra,Qua,CuBIC,Gom,Logistic,Bra), aes(x= Model ,y= AIC_C,fill = Model)) + 
  geom_boxplot() + theme_economist_white(gray_bg = F)+ labs(y ="AIC_C",x = "" ) +  theme(legend.position = "none") 

p_Figure4 = ggarrange(P14,P16,P15,ncol=1,nrow = 3, widths = c(1,1), heights = c(1,1,1),align = "v",common.legend = T,legend = "none")

ggsave(paste0(output_dir,"/AIC_BIC_distribution_of_models.pdf"), plot=p_Figure4, height = 9, width = 8)

print("AIC_BIC_distribution done")

p_Figure5 = ggplot(data = rbind(Stra,Qua,CuBIC,Gom,Logistic,Bra), aes(x= ID ,y= AIC,col = Model)) + 
  geom_line() + theme_economist_white(gray_bg = F) + labs(y ="AIC",x = "ID" ) + 
  scale_color_manual(values = c("red","blue","green","orange","grey","grey")) + 
  scale_x_continuous(breaks=seq(0,285,5)) + 
  theme(axis.text.x = element_text(angle = 45, size=8, color="black",vjust = 1 ))

ggsave(paste0(output_dir,"/AIC_Distribution_ACROSS_the_ids.pdf"), plot=p_Figure5,height = 6 ,width = 8 )

print("AIC_BIC_distribution across the id done")

# ==============Figure 5. The Frequency of best fitted model - AIC===============

dfplot2_c <- as.data.frame(BestAIC_c %>% count(Best_Model_type,Best_Model_type,sort=T) %>% mutate(Criteria = "AIC_c")) %>%  mutate(percent = n/sum(n) * 100 )

#hist(BestAIC_c$SampleSize, breaks = seq(0,200,5))

# rough AIC
dfplot2 <- as.data.frame(BestAIC %>% count(Best_Model_type,Best_Model_type,sort=T) %>% mutate(Criteria = "AIC")) %>%  mutate(percent = n/sum(n) * 100 )

dfplot2 <- dfplot2[order(dfplot2[,2],decreasing=F),]

dfplot2["Best_Model_type"] = factor(dfplot2$Best_Model_type,levels = dfplot2$Best_Model_type)

p_Figure5A = ggplot(data = dfplot2, aes(x = Best_Model_type, y = n, fill = Best_Model_type)) + geom_bar(stat= "identity", position = "dodge",width = 0.5) + 
  coord_flip()+theme_economist_white(gray_bg = F) +
  labs(x="",y="Counts of Best Fitted",fill = "Model Type") + scale_fill_economist()+ theme(legend.position = "none") +
  geom_text(aes(label = round(percent,2)),size = 5,position = position_dodge(0.5),hjust = -0.1 ) + 
  theme(axis.text.x=element_text(size = 20)) + theme(axis.text.y=element_text(size = 20)) + theme(axis.title.y=element_text(size = 20) )

# the relative best fitted rate

dfplot2["SuccessCounts"] <- c(285,285,285,285,285-100,285-8,285-1)

dfplot2 <- dfplot2 %>% mutate(relativePercent = n/SuccessCounts * 100 )
dfplot2 <- dfplot2[order(dfplot2[,2],decreasing=T),]
colnames(dfplot2) <- c("Best_Model_Type","Freq","Criterion","Percent(%)","SuccessCounts","RelativePercent(%)")
dfplot2.p <- ggtexttable(dfplot2, theme = ttheme(base_style = "lBlueWhite",base_size = 20))

# ===== strict AIC ========
dfplot3 <- BestAIC%>% select(Best_Model_type,Plausible_model_name) 

model <- unlist(strsplit(as.character(dfplot3$Plausible_model_name),","))

model2 <- unlist(strsplit(as.character(dfplot3$Best_Model_type),","))

model_final <- c(model,model2)

dfplot4 <- as.data.frame(table(model_final)) %>% mutate(percent = Freq/285 * 100)

colnames(dfplot4) <- c("Model_type","Freq","Percent(%)")

dfplot4.p <- ggtexttable(dfplot4, theme = ttheme(base_style = "lBlueWhite",base_size = 20))


p_Figure5B = ggarrange(dfplot2.p,dfplot4.p,ncol=2,labels = c("table 1","table 2"),nrow = 1,align = "v")


p_Figure6 = ggarrange(p_Figure5A,p_Figure5B,ncol=1,nrow = 2,labels = c("A","B"),heights = c(1,1))


ggsave(paste0(output_dir,"/Best_Fitted_Model.pdf"), plot=p_Figure6,width = 25,height = 10 )

print(" best fitted model done")

# ==============Figure 7. The measurement and models===============


# How many times are each model best fitted in different criteria and different units?



df2plot2  <- as.data.frame(BestAIC %>% count(Unit,Best_Model_type)  %>% mutate(Criteria = "AIC") %>% group_by(Unit) %>% mutate(percent = n/sum(n) * 100))

p_Figure7 = ggplot(data = df2plot2, aes(x = Unit , y = n, fill = Best_Model_type)) + 
  geom_bar(stat= "identity",position = "fill") + theme_clean() + ylab("percentage") + 
  scale_fill_gdocs() +
  geom_text(aes(label = round(percent,2)),size = 4,position = position_fill(0.95),vjust = 0.8) +
  labs(subtitle = "AIC")

ggsave(paste0(output_dir,"/Best_Fitted_and_Measurements.pdf"), plot=p_Figure7)

# ==============Figure 8. The TEMP and models===============

# Temp, Medium (Environment), Species(Inner Gene) ACCOURDING TO AIC means

OriginData[OriginData$Temp < 5 , "Temperature"] <- "cold_Lover"

OriginData[OriginData$Temp > 5 & OriginData$Temp< 20, "Temperature"] <- "middle_cold_Lover"

OriginData[OriginData$Temp >= 20, "Temperature"] <- "middle_warm_Lover"


df_tem = OriginData %>% select(ID,Temperature) 
df_tem2 <- df_tem[!duplicated(df_tem$ID),] # drop the duplicate
df_tem3 <- inner_join(BestAIC,df_tem2,by="ID") # join with the previous BestAIC by ID col

df3plot2  <- as.data.frame(df_tem3 %>% count(Temperature,Best_Model_type)  %>% mutate(Criteria = "AIC") %>% group_by(Temperature) %>% mutate(percent = n/sum(n) * 100))

p_Figure8 = ggplot(data = df3plot2, aes(x = Temperature , y = n, fill = Best_Model_type)) + 
  geom_bar(stat= "identity",position = "fill") + theme_clean() + ylab("percentage") + 
  scale_fill_gdocs() +
  geom_text(aes(label = round(percent,2)),size = 4,position = position_fill(0.95),vjust = 0.8) +
  labs(subtitle = "AIC")

ggsave(paste0(output_dir,"/Best_Fitted_and_Temperatures.pdf"), plot=p_Figure8)

# ========================================= Figure 9 Medium ===================================================

OriginData[OriginData$Medium %in% c("TGE agar" ,"MRS broth","APT Broth","TSB","Z8","MRS","ESAW"), "Env"] <- "Artificial"

OriginData[is.na(OriginData$Env), "Env"] <- "Nature"

OriginData["Env"] <- as.factor(OriginData$Env)

df_env <- OriginData %>% select(ID,Env) 
df_env2 <- df_env[!duplicated(df_env$ID),] # drop the duplicate
df_env3 <- inner_join(BestAIC,df_env2,by="ID") # join with the previous BestAIC by ID col

df4plot2  <- as.data.frame(df_env3 %>% count(Env,Best_Model_type)  %>% mutate(Criteria = "AIC") %>% group_by(Env) %>% mutate(percent = n/sum(n) * 100))

p_Figure9 = ggplot(data = df4plot2, aes(x = Env , y = n, fill = Best_Model_type)) + 
  geom_bar(stat= "identity",position = "fill") + theme_clean() + ylab("percentage") + 
  scale_fill_gdocs() +
  geom_text(aes(label = round(percent,2)),size = 4,position = position_fill(0.95),vjust = 0.8) +
  labs(subtitle = "AIC")

ggsave(paste0(output_dir,"/Best_Fitted_and_Environment.pdf"), plot=p_Figure9)


print(" ===============================ALL done ! =========================================")
