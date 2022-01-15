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

usage = "\
usage:
Rscript get_TreeHeight.R infile(default: ../data/trees.csv)

input csv format:
Species,Distance.m,Angle.degrees
Populus tremula,31.6658337740228,41.2826361937914
Quercus robur,45.984992608428,44.5359166583512
Ginkgo biloba,31.2417666241527,25.1462585572153

"

arg <- commandArgs(T)
if(length(arg) > 1){
  cat("ERROR: You can only PROVIDE one csv file\n")
  cat(usage)
  quit('no')
}else if(length(arg) < 1){
  cat("Argument: You providing no input \nWe will run script with default ../data/trees.csv\n")
  cat(usage)
  input = "../data/trees.csv"
}else if (length(arg) == 1 && file.exists(arg[1])){
  input = arg[1]
}else{
  cat(usage)
}


MyData <- read.csv(input, header = TRUE)

#infilename <- gsub(".csv$","",basename(arg[1])) #use regular expression to remove .csv

infilename <- unlist(strsplit(basename(input), split = ".", fixed = T))[1] # split the basename

outfilename <- paste0("../results/",infilename,"_treeheights.csv") #create the outputfile name

TreeHeight <- function(degrees, distance){
  radians <- degrees * pi / 180 #
  height <- distance * tan(radians)
  #print(paste("Tree height is:", height))
  return (height)
}

MyData$Tree.Height.m=TreeHeight(MyData$Angle.degrees,MyData$Distance.m) # Calculate by vector

write.csv(MyData, outfilename, row.names = F)