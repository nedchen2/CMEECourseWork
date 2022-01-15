# Language: R
# Script: PP_Dists.R
# Des: Body mass distribution subplots by feeding interaction type
# Usage: Rscript PP_Dists.R
# Date: Oct, 2021
# Author: Congjia Chen

rm(list = ls())

MyDF <- read.csv("../data/EcolArchives-E089-51-D1.csv")

require(tidyverse)
#The data shoule be converted into log or to ratio

TempData <- MyDF %>% select(Type.of.feeding.interaction,Predator.mass,Prey.mass) %>% 
  mutate(Log.predator_mass = as.numeric(log(Predator.mass)),
         Log.prey_mass = as.numeric(log(Prey.mass)),
         Log.MassRatio = as.numeric(log(Prey.mass/Predator.mass)))

#str(TempData)

#require 3 subplots 

#def the plot function
#hist function can only accept the numeric type
#can use [[1]] to convert the list to numeric
myplotfunction <- function(interaction_type, featurename){
    subdf <- subset(TempData,Type.of.feeding.interaction == interaction_type,select = featurename)[[1]]
    newname <- strsplit("Log.predator_mass",split = ".",fixed=T)[[1]][2]
    hist(subdf,
    xlab = paste0("log10(",newname,"(g))"),
    ylab = "Count",
    main = interaction_type)
}

#Plots of Predator
pdf("../results/Pred_Subplots.pdf",width = 4, height = 8)
par(mfcol=c(5,1))
sapply(unique(MyDF$Type.of.feeding.interaction),function(i) myplotfunction(i,"Log.predator_mass"))
dev.off()
#Plots of Prey
pdf("../results/Prey_Subplots.pdf",width = 4, height = 8)
par(mfcol=c(5,1))
sapply(unique(MyDF$Type.of.feeding.interaction),function(i) myplotfunction(i,"Log.prey_mass"))
dev.off()
#Plots of Ratio
pdf("../results/SizeRatio_Subplots.pdf",width = 4, height = 8)
par(mfcol=c(5,1))
sapply(unique(MyDF$Type.of.feeding.interaction),function(i) myplotfunction(i,"Log.MassRatio"))
dev.off()

#Calculate means and median
#method1 use tapply
#tapply(TempData$Log.predator_mass,TempData$Type.of.feeding.interaction, mean)

#method2
#use dplyr
resultdf <- TempData %>% group_by(Type.of.feeding.interaction) %>% summarise("Mean.Log.predator_mass" = mean(Log.predator_mass),
                                                                 "Median.Log.predator_mass" = median(Log.predator_mass),
                                                                 "Mean.Log.prey_mass" = mean(Log.prey_mass),
                                                                 "Median.Log.prey_mass" = median(Log.prey_mass),
                                                                 "Mean.Log.MassRatio" = mean(Log.MassRatio),
                                                                 "Median.Log.MassRatio" = median(Log.MassRatio),
                                                                 )
 

write.csv(resultdf, "../results/PP_Results.csv", row.names = F)
