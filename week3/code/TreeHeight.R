# Language: R
# Script: TreeHeight.R (Self-sufficient)
# Des:
# This function calculates heights of trees given distance of each tree 
# from its base and angle to its top, using  the trigonometric formula 
#
# height = distance * tan(radians)
# INPUT
# ../data/trees.csv
#  
# ARGUMENTS
# degrees:   The angle of elevation of tree
# distance:  The distance from base of tree (e.g., meters)
#
# OUTPUT
# ../results/TreeHts.csv
#
# Usage: Rscript TreeHeight.R
# Date: Oct, 2021
# Author: Congjia Chen

TreeHeight <- function(degrees, distance){
    radians <- degrees * pi / 180 #
    height <- distance * tan(radians)
    #print(paste("Tree height is:", height))
    return (height)
}

MyData <- read.csv("../data/trees.csv", header = TRUE)

MyData$Tree.Height.m=TreeHeight(MyData$Angle.degrees,MyData$Distance.m) # Calculate by vector

write.csv(MyData, "../results/TreeHts.csv",row.names = F)
