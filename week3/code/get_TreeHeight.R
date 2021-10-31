# Language: R
# Script: get_TreeHeight.R (
# Des: Input the distance and degrees csv,output the csv with heights
# INPUT
#  trees csv (default: ../data/trees.csv)
#  
# ARGUMENTS
# degrees:   The angle of elevation of tree
# distance:  The distance from base of tree (e.g., meters)
# 
# OUTPUT
# ../results/infilename_TreeHts.csv
#
# Usage: Rscript get_TreeHeight.R infile(default: ../data/trees.csv)
# Date: Oct, 2020

arg <- commandArgs(T)
if(length(arg) < 1){
  cat("Argument: You need to provide the file \n Example: Rscript get_TreeHeight.R ../data/trees.csv\n")
  quit('no')
}

MyData <- read.csv(arg[1], header = TRUE)

#infilename <- gsub(".csv$","",basename(arg[1])) #use regular expression to remove .csv

infilename <- unlist(strsplit(basename(arg[1]), split = ".", fixed = T))[1] # split the basename

outfilename <- paste0("../results/",infilename,"_treeheights.csv") #create the outputfile name

TreeHeight <- function(degrees, distance){
  radians <- degrees * pi / 180 #
  height <- distance * tan(radians)
  #print(paste("Tree height is:", height))
  return (height)
}

MyData$Tree.Height.m=TreeHeight(MyData$Angle.degrees,MyData$Distance.m) # Calculate by vector

write.csv(MyData, outfilename, row.names = F)