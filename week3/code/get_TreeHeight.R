#!/usr/bin/Rscript 
#get_TreeHeight.R

rm(list=ls())

# to do:
#includes the input file name in the output file name as InputFileName_treeheights.csv. 
# remove the prefix and the suffix from the file to get only the name 
args = commandArgs(trailingOnly=TRUE) # function to scan the arguments supplied to R 

if (length(args) == 0) {
  print("No input file was given: using trees.csv as a default file")
  args[1] <- "../data/trees.csv"
} else if (length(args) >1){
  print("too many inputs were provided: using trees.csv as a default file")
  args[1] <- "../data/trees.csv" 
} else if (length(args) == 1 && file.exists(args[1])){
  print(paste("The input file is:", args[1]))
} else{
   print("we can not find the input file. Using trees.csv")
   args[1] <- "../data/trees.csv"
}


Trees <- read.csv(args[1], header = TRUE) #reading the csv of args[1]

#degrees <- Trees$Angle.degrees #puts angle in degrees
#distance <- Trees$Distance.m # puts distances in distance

TreeHeight <- function(degrees, distance){
 radians <- degrees * pi / 180 #this i to convert the degrees to radian
  height <- distance * tan(radians)
  return (height)
}

Trees$Tree.Height.m <- TreeHeight(Trees$Angle.degrees, Trees$Distance.m) #runs the function and rint output in TreeHeight
#Trees # to display the table in bash 

#write.csv(Trees, "../results/trees.csv", row.names  =F)#write in new file

#outputfilename <- paste0(basename(tools::file_path_sans_ext(args[1])),"_treeheights.csv") 

# removing the extansion with the tools::file_path_
# paste0 is like paste() but it has sep = "" as default argument , so any string gets merged together

#write.csv(Trees, paste0(tools::file_path_sans_ext(args[1]),"_treeheights.csv"), "../results")
write.csv(Trees, paste0("../results/",basename(tools::file_path_sans_ext(args[1])),"_treeheights.csv"),row.names = FALSE)

#output_folder <- paste0("../results/",outputfilename)
#write.csv(Trees, output_folder)
print("Script complete!")
