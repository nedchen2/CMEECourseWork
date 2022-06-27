require(tidyverse)
require(qiime2R)
df_taxa_test <- read_qza("../results/6.Network_analysis/table-l7.qza")$data %>% as.data.frame() 
colnames(df_taxa_test) <- paste0("Bee.",colnames(df_taxa_test))

df_taxa_test <- df_taxa_test %>%
  rownames_to_column("taxonomy") %>% rownames_to_column("#OTU ID") %>% relocate(taxonomy,.after = last_col()) %>% 
  mutate(taxonomy = str_replace(taxonomy, pattern = "d__" ,replacement = "k__")
  )




write_tsv(df_taxa_test,file = "../results/6.Network_analysis/Feature-taxa-l7.tsv")


metadata_microbiome <- read.csv("./metadata_Microbiome.csv")

metadata_RADseq <- read.csv("../../UKBB_RADseq/code/metadata_RADseq.csv") %>% dplyr::select("index_list","F_list") %>% 
  rename( SampleID = index_list) 

metadata_microbiome <- metadata_microbiome%>% left_join(metadata_RADseq)

metadata_test <- metadata_microbiome %>% dplyr::select(SampleID,Crithidia_total_per_bee,Nosema_total_per_bee,Apicystis_total_per_bee,gut_parasite_richness,F_list) %>% mutate(SampleID = paste0("Bee.", SampleID))


idx = grepl(pattern = "kunkeei", df_taxa_test$taxonomy)
idx2 =  grepl(pattern = "g__Lactobacillus;s__Lactobacillus", df_taxa_test$taxonomy)


idx3 = rowSums(df_taxa_test[,2:85]) > 20
df_taxa_test[idx,]


df_lactobacillus = df_taxa_test[idx2 & idx3,]

df_lactobacillus <- df_lactobacillus %>% mutate(taxonomy = str_extract(taxonomy,"(?<=s__)(.*)")) 

df_lactobacillus <- df_lactobacillus %>% dplyr::select(-"#OTU ID") %>% t() %>% as.data.frame() 

colnames(df_lactobacillus) <- df_lactobacillus["taxonomy",]

df_lactobacillus <-  df_lactobacillus[1:84,]%>% rownames_to_column( var = "SampleID") %>% left_join(metadata_test)


# =========== transfer character to numeric 
char_columns <- sapply(df_lactobacillus, is.character)             # Identify character columns

first_column <- ! colnames(df_lactobacillus) %in%  "SampleID" 

idx = char_columns & first_column

df_lactobacillus[,idx] = apply(df_lactobacillus[ ,idx], 2, as.numeric)

sapply(df_lactobacillus, class)        

colSums(df_lactobacillus [,2:10])


# LINEAR REGRESSION
plot_lm_scatter <- function(data = lm_genus, response = "Crithidia_total_per_bee",explantory = "shannon_entropy",Group = "Enterotype", confidence_interval = T,group = F) {
  library(ggpubr)
  library(ggplot2)
  library(ggthemes)
  
  df_subset <- subset(data, select=c(response,explantory,Group)) 
  
  
  #log10 transform to response variable
  df_subset[,response] <- log10(df_subset[,response]) 
  colnames(df_subset) <- c("response","explantory","group")
  
  df_subset <- df_subset %>% mutate(explantory = log10(as.numeric(explantory)))
  
  #replace the "-/Inf"
  if( "Inf" %in% df_subset[,"response"] | "-Inf" %in% df_subset[,"response"]){
    tmp <- df_subset[which(df_subset[,"response"] != "Inf" & df_subset[,"response"] != "-Inf"),]
    max = max(tmp[,"response"])
    min = min(tmp[,"response"])
    df_subset[,"response"] <-  as.numeric(sub("-Inf", 0, df_subset[,"response"]))
    df_subset[,"response"] <- as.numeric(sub("Inf", max, df_subset[,"response"]))
  }
  
  
  if( "Inf" %in% df_subset[,"explantory"] | "-Inf" %in% df_subset[,"explantory"]){
    tmp <- df_subset[which(df_subset[,"explantory"] != "Inf" & df_subset[,"explantory"] != "-Inf"),]
    max = max(tmp[,"explantory"])
    min = min(tmp[,"explantory"])
    df_subset[,"explantory"] <- as.numeric(sub("-Inf", min,  df_subset[,"explantory"]))
    df_subset[,"explantory"] <- as.numeric(sub("Inf", max, df_subset[,"explantory"]))
  }
  # remove uninfected samples
  df_subset <- subset(df_subset, response !=0)
  
  fit_model <- try(lm(data = df_subset,response ~  explantory),silent = T)
  if (as.vector(summary(fit_model))[2] != "try-error"){
    
    report_tmp <- as.data.frame(coef(summary(fit_model)))
    report_tmp["Parameter"] <- rownames(report_tmp) #add parameter to one col
    # convert to longer sheet
    report_tmp2 <- report_tmp 
    report_tmp2["Explantory"] <- explantory
    report_tmp2["Response"]   <- response
    report_tmp2["SampleSize"] <- nrow(df_subset)
    report_tmp2["Adjusted_R"] <- summary(fit_model)$adj.r.squared
    report_tmp2["p_value"]    <- pf(summary(fit_model)$fstatistic[1],summary(fit_model)$fstatistic[2],summary(fit_model)$fstatistic[3],lower.tail = F)
  }else{
    cat("========================")
    stop("please check the table")
  }
  
  if (group){
    p = ggplot(df_subset,aes(x=explantory,y=response,color=group)) + 
      geom_point(aes(color=group ),size = 3) + 
      geom_smooth(method = "lm",formula = y~x, se = confidence_interval) +
      stat_cor(data = df_subset, method = "pearson",label.sep = " ",label.x.npc = 0.8) + 
      theme_clean() + 
      labs(y = bquote(paste(.(response),(Log[10]))),x = explantory, title = "linear regression")
    
    
  }else{
    p = ggplot(df_subset,aes(x=explantory,y=response)) + 
      geom_point(size = 3) + 
      geom_smooth(method = "lm",formula = y~x, se = confidence_interval) +
      stat_cor(data = df_subset, method = "pearson",label.sep = " ",label.x.npc = 0.8) + 
      theme_clean() + 
      labs(y =  bquote(paste(.(response),(Log[10]))),x = explantory, title = "linear regression")
  }
  
  return(list(picture = p, report = report_tmp2))
}

plot_lm_scatter(data = df_lactobacillus ,response = "Crithidia_total_per_bee", explantory = "Lactobacillus_bombicola",Group = "Lactobacillus_bombicola",group = F )
plot_lm_scatter(data = df_lactobacillus ,response = "Crithidia_total_per_bee", explantory = "Lactobacillus_bombi",Group = "Crithidia_total_per_bee",group = F )
plot_lm_scatter(data = df_lactobacillus ,response = "Crithidia_total_per_bee", explantory = "Lactobacillus_similis",Group = "Crithidia_total_per_bee",group = F )

plot_lm_scatter(data = df_lactobacillus ,response = "Nosema_total_per_bee", explantory = "Lactobacillus_bombicola",Group = "Lactobacillus_bombicola",group = F )
plot_lm_scatter(data = df_lactobacillus ,response = "Nosema_total_per_bee", explantory = "Lactobacillus_bombi",Group = "Lactobacillus_bombi",group = F )
plot_lm_scatter(data = df_lactobacillus ,response = "Nosema_total_per_bee", explantory = "Lactobacillus_similis",Group = "Lactobacillus_similis",group = F )
