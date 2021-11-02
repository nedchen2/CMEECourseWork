# Language: R
# Script: PP_Regress.R
# Des: Subgroup linear regression
# Usage: Rscript PP_Regress.R
# Date: Oct, 2021
# Output: PP_Regress_Results.csv and PP_Regress_Results.pdf

require(tidyverse)

MyDF <- read.csv("../data/EcolArchives-E089-51-D1.csv")
#dim(MyDF) #check the size of the data frame you loaded
#str(MyDF)

#Use dplyr #temp1
#temp2
#temp3
# DO a self created function to format the output of summary()
lmSum = function(df){
  my_lm <- summary(lm(Predator.mass ~ Prey.mass, data = df))
  
  #when looping, deal with the error
  safefstat <- possibly(function(.x) my_lm$fstatistic[[.x]], otherwise = NA_real_)
  safepValue <- possibly(function(.x) my_lm$coefficients[,4][[.x]] , otherwise = NA_real_)
  safecoeff <- possibly(function(.x) my_lm$coefficients[[.x]] , otherwise = NA_real_)
  
  mychoicelist <-list(
      R_sqaure = my_lm$r.squared,
   Intercept= sapply(1,safecoeff),
    Slope = sapply(2,safecoeff),
     pValue = sapply(2,safepValue),
  F_statistics_value = sapply(1,safefstat)
  )
  return(mychoicelist)
}

#Use dplyr to do looping
meaninful_df <- MyDF %>%
  group_by(Type.of.feeding.interaction,Predator.lifestage) %>%
  nest() %>% mutate(R_sqaured = sapply(data, function(df) lmSum(df)[[1]])) %>% #do() can also be used here
         mutate(Intercept = sapply(data, function(df) lmSum(df)[[2]])) %>%
  mutate( Slope = sapply(data, function(df) lmSum(df)[[3]])) %>%
  mutate( pValue = sapply(data, function(df) lmSum(df)[[4]])) %>%
  mutate( F_statistics_value = lapply(data, function(df) lmSum(df)[[5]])) %>% select(-data) %>% as_tibble()

#something not good when using lapply, ddply may be better
str(meaninful_df)

#flaten the output meaninful_df
resultdf <- apply(meaninful_df,2,as.character)

write.csv(resultdf, file = "../results/PP_Regress_Results.csv", row.names = FALSE)

#========================plotting=====================================================

p = ggplot(MyDF, aes(x = Prey.mass, y = Predator.mass, colour = Predator.lifestage)) +
  geom_point(size = 0.5, shape = 3) + 
  facet_grid(Type.of.feeding.interaction ~ .,) + # split by feed interaction
  scale_y_log10() + 
  scale_x_log10() +
  stat_smooth(method = lm, fullrange = T, level = 0.95, size = 0.7)+ #Regression 
  xlab("Prey Mass in grams") +
  ylab("Predator Mass in grams") +  
  guides(color = guide_legend(nrow = 1)) + #set the row of the legend to 1
  theme_bw()+ #set black and white
  theme(aspect.ratio=0.4)+ #adjuest the ratio
  theme(legend.position = "bottom",
        legend.title = element_text(size = 8,face = "bold"),
        legend.key.size = unit("5", "pt"),
        legend.direction = "horizontal"
        )

pdf("../results/PP_Regress_Results.pdf",width = 6, height = 8)

print(p)

dev.off()