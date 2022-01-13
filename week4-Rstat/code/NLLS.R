S_data <- seq(1,50,5) #创建 substrate 的随机序列
S_data

V_data <- ((12.5 * S_data)/(7.1 + S_data)) #velocity response
plot(S_data, V_data)


set.seed(1456) # To get the same random fluctuations in the "data" every time
V_data <- V_data + rnorm(10,0,1) # Add 10 random fluctuations  with standard deviation of 0.5 to emulate error
plot(S_data, V_data)


#y~formula
MM_model <- nls(V_data ~ V_max * S_data / (K_M + S_data))
plot(S_data,V_data, xlab = "Substrate Concentration", ylab = "Reaction Rate")  # first plot the data 
lines(S_data,predict(MM_model),lty=1,col="blue",lwd=2) # now overlay the fitted model 
coef(MM_model)

#使用更多的点来绘制曲线
Substrate2Plot <- seq(min(S_data), max(S_data),len=200) # generate some new x-axis values just for plotting
Predict2Plot <- coef(MM_model)["V_max"] * Substrate2Plot / (coef(MM_model)["K_M"] + Substrate2Plot) # calculate the predicted values by plugging the fitted coefficients into the model equation 

plot(S_data,V_data, xlab = "Substrate Concentration", ylab = "Reaction Rate")  # first plot the data 
lines(Substrate2Plot, Predict2Plot, lty=1,col="blue",lwd=2) # now overlay the fitted model

#summary 和LR一样，大部分函数都可以通用

summary(MM_model)

# Statistical inference using NLLS fits 如何推断统计学意义
anova(MM_model)


# confint函数用来对模型对象进行置信区间建立
confint(MM_model)



#with start value
MM_model2 <- nls(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 12, K_M = 7))
coef(MM_model2)

MM_model3 <- nls(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = .01, K_M = 20))
coef(MM_model3)

# 来看一下，当起始点很离谱之后带来的后果
plot(S_data,V_data)  # first plot the data 
lines(S_data,predict(MM_model),lty=1,col="blue",lwd=2) # overlay the original model fit
lines(S_data,predict(MM_model3),lty=1,col="red",lwd=2) # overlay the latest model fit

nls(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 0, K_M = 0.1))


#
MM_model4 <- nls(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 12.5, K_M = 7.1))
coef(MM_model4)

#==========the Levenberg-Marqualdt algorithm
require("minpack.lm")


# 这些在上面nls中无法准确拟合出来的起始点，在新算法中都能完成
MM_model5 <- nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 2, K_M = 2))
coef(MM_model5)

MM_model6 <- nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = .01, K_M = 20))
MM_model7 <- nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 0, K_M = 0.1))
MM_model8 <- nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = -0.1, K_M = 100))
coef(MM_model6)
coef(MM_model7)
coef(MM_model8)
#当然如果太荒谬，这个新算法也算不出来


#另外新算法还能设置parameter bound，这个可以减少电脑内存的使用量
nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 0.1, K_M = 0.1), lower=c(0.4,0.4), upper=c(100,100))

#如果限制范围太窄，会影响结果
nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start =  list(V_max = 0.5, K_M = 0.5), lower=c(0.4,0.4), upper=c(20,20))


hist(residuals(MM_model6))

#更多检测，可以使用这个包
require(nlstools) 


# SCALING

MyData <- read.csv("../data/GenomeSize.csv") # using relative path assuming that your working directory is "code"

head(MyData)
Data2Fit <- subset(MyData,Suborder == "Anisoptera")

Data2Fit <- Data2Fit[!is.na(Data2Fit$TotalLength),] # remove NA's

plot(Data2Fit$TotalLength, Data2Fit$BodyWeight, xlab = "Body Length", ylab = "Body Weight")

library("ggplot2")

ggplot(Data2Fit, aes(x = TotalLength, y = BodyWeight)) + 
  geom_point(size = (3),color="red") + theme_bw() + 
  labs(y="Body mass (mg)", x = "Wing length (mm)")

nrow(Data2Fit)
PowFit <- nlsLM(BodyWeight ~ a * TotalLength^b, data = Data2Fit, start = list(a = .1, b = .1))


# 或者函数化

powMod <- function(x, a, b) {
  return(a * x^b)
}

PowFit <- nlsLM(BodyWeight ~ powMod(TotalLength,a,b), data = Data2Fit, start = list(a = .1, b = .1))

# plotting 观察结果，为什么自己建点，主要是用BaseR画图，需要
Lengths <- seq(min(Data2Fit$TotalLength),max(Data2Fit$TotalLength),len=200)
Predic2PlotPow <- powMod(Lengths,coef(PowFit)["a"],coef(PowFit)["b"])


# Comparing models
QuaFit <- lm(BodyWeight ~ poly(TotalLength,2), data = Data2Fit)
Predic2PlotQua <- predict.lm(QuaFit, data.frame(TotalLength = Lengths))

plot(Data2Fit$TotalLength, Data2Fit$BodyWeight)
lines(Lengths, Predic2PlotPow, col = 'blue', lwd = 2.5)
lines(Lengths, Predic2PlotQua, col = 'red', lwd = 2.5)

# 先计算R方
RSS_Pow <- sum(residuals(PowFit)^2) # Residual sum of squares
TSS_Pow <- sum((Data2Fit$BodyWeight - mean(Data2Fit$BodyWeight))^2) # Total sum of squares
RSq_Pow <- 1 - (RSS_Pow/TSS_Pow) # R-squared value

RSS_Qua <- sum(residuals(QuaFit)^2) # Residual sum of squares
TSS_Qua <- sum((Data2Fit$BodyWeight - mean(Data2Fit$BodyWeight))^2) # Total sum of squares
RSq_Qua <- 1 - (RSS_Qua/TSS_Qua) # R-squared value

RSq_Pow 
RSq_Qua

# AIC
n <- nrow(Data2Fit) #set sample size
pPow <- length(coef(PowFit)) # get number of parameters in power law model
pQua <- length(coef(QuaFit)) # get number of parameters in quadratic model

AIC_Pow <- n + 2 + n * log((2 * pi) / n) + n * log(RSS_Pow) + 2 * pPow
AIC_Qua <- n + 2 + n * log((2 * pi) / n) + n * log(RSS_Qua) + 2 * pQua
AIC_Pow - AIC_Qua


# or
AIC(PowFit) - AIC(QuaFit)


