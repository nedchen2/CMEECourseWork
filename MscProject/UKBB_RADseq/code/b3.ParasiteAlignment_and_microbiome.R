
# metadata of microbiome

metadata <- read.csv("../code/sample-metadata.tsv", stringsAsFactors = FALSE,sep ="\t")[-91,]

sampleINmicrobiome = metadata %>% pull(sample_name)

metadata_RADseq <-  read.csv("../code/metadata_RADseq.csv", stringsAsFactors = FALSE) %>% dplyr::rename(sample_name = index_list) %>% 
  mutate(sample_name = as.character(sample_name))


#
require(tidyverse)

stat_data = read.csv(file = "../results/b.alignment/stat_parasite_5/MapStat.csv") %>% dplyr::select(-"X") %>% 
  mutate(mapratio = str_extract(mapping_ratio,"(?<=mapped \\()(.*)(?= : N/A?)"),
         absolute_aligned_read = as.integer(str_extract(mapping_ratio,"(?<=\\')(.*)(?= \\+ ?)"))
  )

metadata_genome = read.csv(file = "../genome/genome_metadata.csv")

genome_length <- read.csv(file ="../genome/Genome_length.csv")

metadata_genome <- left_join(metadata_genome,genome_length) %>% dplyr::select(-X) %>% dplyr::rename(LenKb = genomeLength )

merged_data <- left_join(stat_data, metadata_genome) %>% 
  mutate(mapratio = as.numeric(str_remove(mapratio , "\\%")),
         sample_name =  str_extract(sample,"(?<=PG_)(.*)(?=_[12].sorted.bam?)")) %>%
  mutate(LOG.RPK = log(absolute_aligned_read/LenKb),RPK = absolute_aligned_read/LenKb) %>% left_join(metadata_RADseq,by = "sample_name" )

# ========test 

test <- Crithidia_df %>% mutate(infection = ifelse(Crithidia_total_per_bee > 0, "infected","No"))

summary(lm(mapratio~infection,data = test))


t.test(test$mapratio~test$infection)

t.test(log(test$RPK)~test$infection)

# remove thorax

Crithidia_df <- Crithidia_df %>% filter(tissue== "thorax")



# Analysis of Crithidia

metadata <-  read.csv("../../UKBB_Microbiomes//code/UKBB_NED_filtered.csv") %>% dplyr::rename(sample_name =`Bee_ID` ,
                                                                                              Species = `finalised_species`,
                                                                                              CollectionSite = `Site`)  

Crithidia_load <- metadata %>% dplyr::select(sample_name,Crithidia_total_per_bee,tissue) %>% mutate(sample_name = as.character(sample_name))
  
Crithidia_df <- subset(merged_data, shortname == "Crithidia") %>%  left_join(metadata_RADseq,by = "sample_name") %>%
  left_join(Crithidia_load) %>%   dplyr::select(sample_name,mapratio,absolute_aligned_read,LOG.RPK,tissue,Crithidia_total_per_bee) %>% filter(tissue != "thorax")





# Analysis of Nosema

Nosema_load <- metadata %>% dplyr::select(sample_name,Nosema_total_per_bee,tissue) %>% mutate(sample_name = as.character(sample_name))

Nosema_df <- subset(merged_data, shortname == "Nosema") %>%  left_join(metadata_RADseq,by = "sample_name") %>%
  left_join(Nosema_load) %>%   dplyr::select(sample_name,mapratio,absolute_aligned_read,LOG.RPK,tissue,Nosema_total_per_bee) %>% filter(tissue != "thorax")

test <- Nosema_df %>% mutate(infection = ifelse(Nosema_total_per_bee > 0, "infected","No"))

t.test(test$absolute_aligned_read~test$infection)

t.test(log(test$RPK)~test$infection)

summary(lm(absolute_aligned_read~infection,data = test))



# linear relation

plot_lm_scatter <- function(data = lm_genus, response = "Crithidia_total_per_bee",explantory = "shannon_entropy",Group = "Enterotype", confidence_interval = T,group = F) {
  library(ggpubr)
  library(ggplot2)
  library(ggthemes)
  
  df_subset <- subset(data, select=c(response,explantory,Group))
  
  
  #log10 transform to response variable
  df_subset[,response] <- log10(df_subset[,response]) 
  #df_subset[,explantory] <- log10(df_subset[,explantory]) 
  colnames(df_subset) <- c("response","explantory","group")
 
  
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

# ========= test the threshold 
Result <- c()
parameter <- c()
for (i in (seq(0, 0.6,0.01))){
  i = 0.15
  
  test <- Crithidia_df %>% mutate(Sequence = ifelse(mapratio > i, "SequenceInfect", "SequenceUninfect"),
                                  Microscopic = ifelse(Crithidia_total_per_bee > 0,"MicroInfect","MicroUninfect"))
  RESULT <- chisq.test(test$Sequence,test$Microscopic,simulate.p.value = T)
  
  table(test$Sequence,test$Microscopic)
  Result <- c(Result, RESULT$p.value)
  parameter <- c(parameter,i)
}

Result
parameter[16]

test <- Nosema_df %>% mutate(Sequence = ifelse(mapratio > i, "SequenceInfect", "SequenceUninfect"),
                                Microscopic = ifelse(Nosema_total_per_bee > 0,"MicroInfect","MicroUninfect"))
RESULT <- chisq.test(test$Sequence,test$Microscopic,simulate.p.value = T)

# =================================

plot_lm_scatter(data = Crithidia_df,response = "Crithidia_total_per_bee", explantory = "mapratio", Group = "mapratio",confidence_interval = T,group = T)

plot_lm_scatter(data = Crithidia_df,response = "Crithidia_total_per_bee", explantory = "absolute_aligned_read", Group = "mapratio",confidence_interval = T,group = T)

plot_lm_scatter(data = Crithidia_df,response = "Crithidia_total_per_bee", explantory = "LOG.RPK", Group = "mapratio",confidence_interval = T,group = F)

plot_lm_scatter(data = Nosema_df, response = "Nosema_total_per_bee", explantory = "mapratio", Group = "mapratio",confidence_interval = T,group = F)
plot_lm_scatter(data = Nosema_df, response = "Nosema_total_per_bee", explantory = "LOG.RPK", Group = "mapratio",confidence_interval = T,group = F)



#=========== lotmaria and Crithidia 


Lot = merged_data %>% subset(shortname == "Lotmaria ") %>% dplyr::select(sample_name,mapratio) %>% dplyr::rename(lotmaria = mapratio)

Crithidia = merged_data %>% subset(shortname == "Crithidia") %>% dplyr::select(sample_name,mapratio) %>% dplyr::rename(Crithidia = mapratio)

LotCrithdia = left_join(Lot,Crithidia)

plot_lm_scatter(data =LotCrithdia ,response = "lotmaria",explantory = "Crithidia",Group = "sample_name",confidence_interval = T,group = F)






# =========== wil issue type influence the map ratio



Crithidia_df2 <- Crithidia_df <- subset(merged_data, shortname == "Crithidia") %>% 
  dplyr::select(sample_name,mapratio,absolute_aligned_read,LOG.RPK,RPK) %>% left_join(metadata_RADseq) %>% filter(tissue != "thorax")

t.test(mapratio ~ tissue,data = Crithidia_df2)

t.test(RPK ~ tissue,data = Crithidia_df2)

kruskal.test(mapratio ~ tissue,data = Crithidia_df2)



Nosema_df2 <- subset(merged_data, shortname == "Nosema") %>% 
  dplyr::select(sample_name,mapratio,absolute_aligned_read,LOG.RPK,RPK) %>% left_join(metadata_RADseq)%>% filter(tissue != "thorax")

plot_lm_scatter(data =Nosema_df2  , response = "Nosema_total_per_bee", explantory = "LOG.RPK", Group = "mapratio",confidence_interval = T,group = F)

t.test(mapratio ~ tissue,data = Nosema_df2)

t.test(RPK ~ tissue,data = Nosema_df2)

kruskal.test(RPK ~ tissue,data = Nosema_df2)


Arsenophonus_df2 <- subset(merged_data, shortname == "Arsenophonus") %>% 
  dplyr::select(sample_name,mapratio,absolute_aligned_read,LOG.RPK,RPK) %>% left_join(metadata_RADseq) %>% filter(tissue != "thorax")

t.test(mapratio ~ tissue,data = Arsenophonus_df2)

t.test(RPK ~ tissue,data = Arsenophonus_df2)

kruskal.test(RPK ~ tissue,data = Arsenophonus_df2)


lotmaria_df2 <- subset(merged_data, shortname == "Lotmaria ") %>% 
  dplyr::select(sample_name,mapratio,absolute_aligned_read,LOG.RPK,RPK) %>% left_join(metadata_RADseq,by = "sample_name") %>% filter(tissue != "thorax")






t.test(mapratio ~ tissue,data = lotmaria_df2)

t.test(RPK ~ tissue,data = lotmaria_df2)

kruskal.test(RPK ~ tissue,data = lotmaria_df2)


# if we remove the samples with thorax


metadata <- read.csv("./metadata_Microbiome.csv") %>% dplyr::rename(sample_name= SampleID)

Arsenophonus_meta <- metadata %>% dplyr::select(sample_name,Arsenophonus) %>% mutate(sample_name = as.character(sample_name))

Arsenophonus_df <- subset(merged_data, shortname == "Arsenophonus") %>% 
  dplyr::select(sample_name,mapratio,absolute_aligned_read,LOG.RPK,tissue) %>% filter(sample_name %in% sampleINmicrobiome) %>% filter(tissue != "thorax") %>%filter(mapratio < 20) %>%
  left_join(Arsenophonus_meta) 


Enterotype1 = as.character(c(1,163,181,202,205,22,242,246,44,63,83))

Arsenophonus_df %>% filter(sample_name %in% Enterotype1)

list =  as.character(c(22,242,205))

test_df <- Arsenophonus_df %>% filter(sample_name %in% list) %>% left_join(metadata_RADseq)

plot_lm_scatter(data = Arsenophonus_df, response = "Arsenophonus" , explantory = "mapratio" ,Group = "mapratio" , confidence_interval = T,group = F)


plot_lm_scatter(data = Arsenophonus_df, response = "Arsenophonus" , explantory = "absolute_aligned_read" ,Group = "mapratio" , confidence_interval = T,group = F)


plot_lm_scatter(data = Arsenophonus_df, response = "Arsenophonus" , explantory = "LOG.RPK" ,Group = "mapratio" , confidence_interval = T,group = F)


# relative abundance of Apibacter and Crithidia

df_taxa_test <-read_qza("../results/6.Network_analysis/table-l6.qza")$data %>% as.data.frame() 

relative_genus_abundances <- apply(df_taxa_test , 2, function(x) x/sum(x)) 

teste <- t(relative_genus_abundances) %>% as.data.frame() %>% rownames_to_column("sample_name")

teste <- teste %>% dplyr::select("sample_name","d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Flavobacteriales;f__Weeksellaceae;g__Apibacter") %>% 
  mutate(sample_name = as.integer(sample_name))

colnames(teste) <- c("sample_name","Apibacter2")
metadata <- metadata %>% left_join(teste) %>% mutate(Apibacter2 = 100* Apibacter2)

plot_lm_scatter(data = metadata, response = "Crithidia_total_per_bee" , explantory = "Apibacter2" ,Group = "Species" , confidence_interval = T,group = F)


