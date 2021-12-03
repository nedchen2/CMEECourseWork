#Author :Congjia.chen
#Function : Data preprocess 
#Input ../data/LogisticGrowthData.csv
#Output ../results/Csvafterpreprocessing2.csv
#dep: tidyverse

#import the package
suppressPackageStartupMessages(require("tidyverse"))

#read the data
data <- read.csv("../data/LogisticGrowthData.csv",stringsAsFactors = T)

#levels(data$Medium)
#str(data)
#17 levels of temp
#45 levels of Species
#18 levels of Medium
#4 levels of popUnits
#1 levels of timeUnits

# give the id according to the combination of several col
## create a col combining Species, Medium, Temp and Citation columns (each species-medium-citation combination is unique)

data_tmp <- data %>% 
  mutate(unite(data,"combination",c("Species","Medium","Temp","Citation"),sep="_")) %>% 
  select(c("Time","PopBio","combination","Time_units","PopBio_units","Temp","Medium"))

# optical density 595,N  should be the number, CFU colony-forming-unit, Dryweight
# unique(data$PopBio_units)
# subset(data_tmp, data_tmp$PopBio_units == "DryWeight")

## create a dataframe with ID and corresponding combination
datawith_ID <- cbind(as.data.frame(table(data_tmp$combination)),1:nrow(as.data.frame(table(data_tmp$combination))))
colnames(datawith_ID) <- c("combination","counts","ID")
#combine two dataframe
Data_final <- left_join(data_tmp,datawith_ID,by="combination") %>% select(-counts,-combination)
#the amount of id
print (paste0("ID numbers:",length(unique(Data_final$ID))))


# =====================aggressive data pre-processing==============================
# Below, we fix the problems which might influence the accuracy of the model fitting.

#change the popbio which equals to or smaller than 0 to a extremely small value

print (paste0(length(Data_final[Data_final["PopBio"] <= 0,"ID"])," rows can not be log transformed, therefore, they will be replaced by 0.0000000000000000001"))

Data_final[Data_final["PopBio"] <= 0,"PopBio"] = 0.0000000000000000001
Data_final["LogPopBio"] = log(Data_final["PopBio"])

#change the time which belows the zero to 0
print (length(Data_final[Data_final["Time"] <= 0,"ID"]))
print ("Time can not be negative, therefore, they will be replaced by 0")
Data_final[Data_final["Time"] <= 0, "Time"] = 0
#output the Data_final_with_log to csv file

write.csv(Data_final,"../results/Csvafterpreprocessing2.csv",row.names = F)


print("====================Data preparation done====================")