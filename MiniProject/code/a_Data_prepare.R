require("tidyverse")
#read the data
data <- read.csv("../data/LogisticGrowthData.csv",stringsAsFactors = T)
str(data)
# give the id according to the combination of several col
## create a col combining Species, Medium, Temp and Citation columns (each species-medium-citation combination is unique)

data_tmp <- data %>% 
  mutate(unite(data,"combination",c("Species","Medium","Temp","Citation"),sep="_")) %>% select(c("Time","PopBio","combination"))

## create a dataframe with ID and corressponding combination
datawith_ID <- cbind(as.data.frame(table(data_tmp$combination)),1:nrow(as.data.frame(table(data_tmp$combination))))
colnames(datawith_ID) <- c("combination","counts","ID")
#combine two dataframe
Data_final <- left_join(data_tmp,datawith_ID,by="combination") %>% select(-counts)


