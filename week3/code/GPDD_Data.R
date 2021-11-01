# Language: R
# Script: GPDD_Data.R (self-sufficient)
# Des: visualize a map and a data including the distribution of several animals  
# Usage: Rscript GPDD_Data.R
# Date: Oct, 2021

load("../data/GPDDFiltered.RData") #load the GIS data

library("maps")
library("ggplot2")
library("ggthemes")

#gpdd["Group"] = as.factor(gpdd["common.name"])

world <-map_data("world")#
p = ggplot() + geom_polygon(data=world, aes(x=long, y=lat, group=group), fill="grey")  + 
  geom_point(data=gpdd,aes(x=long,y=lat),alpha=0.5, col = "red") + theme_clean()

pdf("../results/GPDD_Data_MAP.pdf") # Open blank pdf page using a relative path
print (p)
dev.off()

#Bias1: For diversity issues: No marine habitats
#Bias2: For global issues: The locations of animals recorded are not distributed evenly among the world.
#Most animals are found in Europe (especially in United Kingdom) and North America, 
