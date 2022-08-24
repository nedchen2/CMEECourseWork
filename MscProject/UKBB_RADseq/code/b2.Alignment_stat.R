
require(tidyverse)





combine_two_table <- function(filename1 = "../results/b.alignment/stat_parasite_5/MapStat.csv",filename2 = "../results/b.alignment/stat_parasite_3//MapStat.csv"){
  parasite_table1 <- read.csv(file = filename1) 
  parasite_table2 <- read.csv(file = filename2) 
  parasite_table3 <- rbind(parasite_table1,parasite_table2)
  write.csv(parasite_table3,file="../results/b.alignment/MapStatParasite8.csv",row.names = F)
}

combine_two_table()



Process_map_result <- function(filename = "../results/b.alignment/stat_parasite/MapStat.csv"){
  require(tidyverse)
  
  stat_data = read.csv(file = filename) %>% dplyr::select(-"X") %>% 
    mutate(mapratio = str_extract(mapping_ratio,"(?<=mapped \\()(.*)(?= : N/A?)"),
           absolute_aligned_read = as.integer(str_extract(mapping_ratio,"(?<=\\')(.*)(?= \\+ ?)"))
    )%>% 
    mutate(sample_name =  str_extract(sample,"(?<=PG_)(.*)(?=_[12].sorted.bam?)"))
  
  metadata_genome = read.csv(file = "../genome/genome_metadata.csv")
  
  genome_length <- read.csv(file ="../genome/Genome_length.csv")
  
  metadata_genome <- left_join(metadata_genome,genome_length) %>% dplyr::select(-X) %>% rename(LenKb = genomeLength )
  
  merged_data <- left_join(stat_data, metadata_genome) %>% 
    mutate(mapratio = as.numeric(str_remove(mapratio , "\\%")))
  
  
  # Basic stat
  
  basic_stat = merged_data %>% group_by(species) %>% summarise(SampleNumber = n() ,
                                                               MeanMapRatio = mean(as.numeric(mapratio)),
                                                               MeanAbsoluteAlign = mean(as.numeric(absolute_aligned_read)),
                                                               MaxMapRatio = max(as.numeric(mapratio)),
                                                               MinMapRatio = min(as.numeric(mapratio)))
  
  
  outputdir = filename
  
  write.csv(merged_data,file = paste0(dirname(outputdir),"/MergedStat.csv"))
  write.csv(basic_stat,file =  paste0(dirname(outputdir),"/SpeciesStat.csv"))
  
  SampleNumber = basic_stat %>% dplyr::select(species, SampleNumber) 
  
  merged_data <- left_join(merged_data,SampleNumber) %>% mutate(Name = paste( shortname, "(n=" ,SampleNumber , ")"))
  # histogram is not informative  
  #merged_data[(merged_data$mapratio > 40 & merged_data$shortname == "Arsenophonus"),c("sample","mapratio")]
  
  p<- ggplot(merged_data, aes(x=mapratio))+
    geom_histogram(color="black", fill="white") +
    facet_wrap( ~Name,scales = "free_x",nrow = 2,ncol = 4) +
    xlab("MapRatio(%)") + theme_bw()
  p
  return (list(picture = p, table = merged_data))
}

Process_map_result()


Process_map_result(filename = "../results/b.alignment/stat_host/MapStat.csv")

Process_map_result(filename = "../results/b.alignment/MapStatParasite8.csv")


# ====================== calculate the RPK


table <- Process_map_result(filename = "../results/b.alignment/MapStatParasite8.csv")$table 

table <- table %>% mutate(RPK = absolute_aligned_read/LenKb)






# ======================= host lower than 90%


host_table = Process_map_result(filename = "../results/b.alignment/stat_host/MapStat.csv")$table
parasite_table = Process_map_result()$table
wolbachia_table =  Process_map_result(filename = "../results/b.alignment/stat_wolbachia/MapStat.csv")$table

parasite_table = rbind(parasite_table,wolbachia_table)

# prevalence 
prevalence_table <- parasite_table %>% 
  mutate(infection = ifelse(mapratio >= 0.01, "infected","uninfected") ) %>% group_by(shortname,infection) %>% count()

write.csv(prevalence_table,file="../results/b.alignment/ParasitePrevalenceTable.csv",row.names = F)


all_table = rbind(host_table,parasite_table)


metadata <- read.csv("../code/sample-metadata.tsv", stringsAsFactors = FALSE, sep = "\t")

sampleINmicrobiome = metadata %>% pull(sample_name)

final_table = all_table %>% dplyr::select(sample_name,mapratio,species,shortname) %>% 
  pivot_wider(id_cols = sample_name,names_from = shortname,values_from = mapratio ) %>% replace_na(list(hortorum = 0,terrestris = 0)) %>% 
  column_to_rownames(var = "sample_name") %>% mutate(sum_mapratio = rowSums(.)) %>% rownames_to_column(var = "sample_name") %>%
  mutate(Microbiome = ifelse(sample_name %in% sampleINmicrobiome, "Yes",  "No"))

#How many  samples higher than 90%
final_table %>% filter(sum_mapratio >= 90 ) %>% nrow() 
# 190
final_table %>% filter(sum_mapratio < 90 ) %>% pull(sample_name) 
# 16



write.csv(final_table,file="../results/b.alignment/MultiSpeciesMapRatio.csv",row.names = F)






table_for_plot <- final_table %>% dplyr::select(-c(Microbiome)) %>% 
  pivot_longer(cols = colnames(.)[! colnames(.) %in% c("sample_name","sum_mapratio")], names_to = "Name",values_to = "MapRatio") %>% 
  arrange(sum_mapratio) %>% mutate(sample_name = factor(sample_name, levels = unique(sample_name))) 

p = ggplot(table_for_plot, aes(x = sample_name, y = MapRatio , fill = Name)) +
  geom_bar(stat = "identity",
           position = "stack",
           width = 0.7) +
  #facet_grid(~ group, scales = "free_x", switch = "x") +
  theme(strip.background = element_blank()) +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank()) +
  xlab("Samples") + ylab("MapRatio (%)") +
  theme_classic() + theme(axis.text.x = element_text(
    angle = 90,
    vjust = 1,
    hjust = 1,
    size = 5
  )) +
  theme(text = element_text(family = "sans", size = 10)) + scale_fill_gdocs()





# coverage ----


Coverage_data = read.csv(file = "../results/b.alignment/stat_parasite/PerCoverageStat.csv") %>% dplyr::select(-"X") 

merged_COVERAGE_data <- left_join(Coverage_data, metadata_genome)

p<- ggplot(merged_COVERAGE_data, aes(x=coverage_area))+
  geom_histogram(color="black", fill="white") +
  facet_wrap( ~shortname,scales = "free_x",nrow = 1,ncol = 5) +
  xlab("coverage area(bp)") + theme_bw() + theme(axis.text.x = element_text(angle = 90))
p


p<- ggplot(merged_COVERAGE_data, aes(x=PercCoverage))+
  geom_histogram(color="black", fill="white") +
  facet_wrap( ~shortname,scales = "free_x",nrow = 2,ncol = 4) +
  xlab("Percentage Coverage") + theme_bw()
p


p<- ggplot(merged_COVERAGE_data, aes(x=PercCoverage))+
  geom_histogram(color="black", fill="white") +
  facet_wrap( ~shortname,scales = "free_x",nrow = 1,ncol = 5) +
  xlab("Percentage Coverage") + theme_bw() + theme(axis.text.x = element_text(angle = 90))
p




