################################################################
################## Wrangling the Pound Hill Dataset ############
################################################################
#use tidyverse to calculate the data

############# Load the dataset ###############
# header = false because the raw data don't have real headers
MyData <- as.matrix(read.csv("../data/PoundHillData.csv", header = FALSE))

# header = true because we do have metadata headers
MyMetaData <- read.csv("../data/PoundHillMetaData.csv", header = TRUE, sep = ";")

############# Inspect the dataset ###############
head(MyData)
dim(MyData)
dplyr::glimpse(MyData)    #str(MyData)
fix(MyData) #you can also do this
fix(MyMetaData) #fix could be used to see the file in the editor

############# Transpose ###############
# To get those species into columns and treatments into rows 
MyData <- t(MyData) 
head(MyData)
dim(MyData)

############# Replace species absences with zeros ###############
MyData[MyData == ""] = 0

############# Convert raw matrix to data frame ###############

TempData <- as.data.frame(MyData[-1,],stringsAsFactors = F) #stringsAsFactors = F is important! #factor should not be set in this case
colnames(TempData) <- MyData[1,] # assign column names from original data

############# Convert from wide to long format  ###############
#(reshape2) # load the reshape2 package
#?melt #check out the melt function
#MyWrangledData <- melt(TempData, id=c("Cultivation", "Block", "Plot", "Quadrat"), variable.name = "Species", value.name = "Count")

require(tidyverse)

#as_tibble(MyWrangledData)

MyWrangledData <- TempData %>% pivot_longer(cols = !c("Cultivation", "Block", "Plot", "Quadrat"),names_to = "Species", values_to = "Count") 
#cols provide the col that you want to transform into one col
#names_to give the col the name
#value.name "gives the name of the value"

MyWrangledData <- as.data.frame(MyWrangledData, stringsAsFactors = F)

MyWrangledData[, "Cultivation"] <- as.factor(MyWrangledData[, "Cultivation"])
MyWrangledData[, "Block"] <- as.factor(MyWrangledData[, "Block"])
MyWrangledData[, "Plot"] <- as.factor(MyWrangledData[, "Plot"])
MyWrangledData[, "Quadrat"] <- as.factor(MyWrangledData[, "Quadrat"])
MyWrangledData[, "Species"] <- as.factor(MyWrangledData[, "Species"])#as.factor could be useful for further analysis
MyWrangledData[, "Count"] <- as.integer(MyWrangledData[, "Count"]) 

dplyr::glimpse(MyWrangledData)  
head(MyWrangledData)
dim(MyWrangledData)


