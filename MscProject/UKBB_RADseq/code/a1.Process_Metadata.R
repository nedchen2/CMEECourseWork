#!/usr/bin/env R
#15/02/2022
###A script for assaying the sample performance after process_radtags

rm(list = ls())
graphics.off()
library(ggplot2)
require(tidyverse)


process_radtags_log <- read.table("../results/a.process_radtags/reads_stat_table.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE)

metadata <- read.csv("../code/sample-metadata.tsv", stringsAsFactors = FALSE, sep = "\t")


sampleINmicrobiome = metadata %>% pull(sample_name)

# ======= deal with the log file 

process_radtags_log <- process_radtags_log %>% 
  mutate( sample_name =  str_extract(File,"(?<=PG_)(.*)(?=_1.fastq.gz?)")) %>% 
  select("sample_name",everything()) %>% 
  mutate(total_retained = sum(Retained.Reads),
         sample_percentage = Retained.Reads/total_retained) %>% 
  arrange(desc(sample_percentage)) %>% 
  mutate(File = factor(File, levels = File)) %>% 
  mutate(sample_name = factor(sample_name, levels = sample_name),
         retained_percentages = Retained.Reads/Total)
  
glimpse(process_radtags_log)


sample_percentages_library_plot <- ggplot(data = process_radtags_log, aes(x = sample_name, y = sample_percentage, group = 1)) +
  geom_bar(stat = "identity", col = "black") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 5)) +
  scale_y_continuous(expand = c(0,0)) +
  labs(x = "Sample", y = "Retained read percentage of library per sample")

ggsave(plot = sample_percentages_library_plot, filename = "../results/a.process_radtags/Sample_percentages_library.png", width = 15)


retained_reads_number_plot <- ggplot(data = process_radtags_log, aes(x = sample_name, y = Retained.Reads, group = 1)) +
  geom_bar(stat = "identity", col = "black") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 5)) +
  scale_y_continuous(expand = c(0,0)) +
  geom_hline(yintercept = 1000000, color = "red") +
  labs(x = "Sample", y = "Retained reads of each sample")

ggsave(plot = retained_reads_number_plot, filename = "../results/a.process_radtags/retained_reads_number.png", width = 15)

#Assessing the percentage of retained reads per sample

process_radtags_log <- process_radtags_log %>% arrange(retained_percentages) %>% 
  mutate(sample_name = factor(sample_name, levels = sample_name))

retained_reads_percentage_plot <- ggplot(data = process_radtags_log, aes(x = sample_name, y = retained_percentages, group = 1)) +
  geom_bar(stat = "identity", col = "black") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 5)) +
  scale_y_continuous(expand = c(0,0)) +
  labs(x = "Sample", y = "Percentage of reads retained for each sample")

ggsave(plot = retained_reads_percentage_plot, filename = "../results/a.process_radtags/retained_reads_percentage.png", width = 15)

write.table(process_radtags_log, file = "../results/a.process_radtags/reads_table_assayed.tsv", quote = FALSE, sep = "\t", row.names = FALSE)  

#Removing the the following samples due to them having too low retained reads, retained reads percentage and too little contribution to the library: 170 and 166

process_radtags_log <- process_radtags_log %>% filter(! (sample_name == 170 |sample_name == 166)) 

write.table(process_radtags_log, file = "../results/204n_radtags_table.csv", quote = FALSE, sep = "\t", col.names = T, row.names = F)

metadata2 <- metadata %>% left_join(process_radtags_log)

write.table(metadata2, file = "../results/sample-microbial-stat.tsv", quote = FALSE, sep = "\t", col.names = T, row.names = F)

# ================================================================================= Use ryan's metadata

metadata_RADseq = read.csv(file = "../genome/metadata_individuals_2.csv") %>% 
  mutate(genome = ifelse( (field_ID_list == "Bh" | field_ID_list == "Br" ), "GCA_905332935.1_iyBomHort1.1_genomic.fna",  "GCF_910591885.1_BomTerr_genomic.fna"),
         relative_dir = paste0("../results/a.process_radtags/", name_list , ".fq.gz"),
         Microbiome = ifelse(index_list %in% sampleINmicrobiome, "Yes",  "No"))

write.csv(metadata_RADseq, file = "../code/metadata_RADseq.csv", quote = FALSE, row.names = F)

metadata_RADseq = read.csv(file = "../genome/metadata_individuals_2.csv") %>% 
  mutate(genome = ifelse( (field_ID_list == "Bh" | field_ID_list == "Br" ), "GCA_905332935.1_iyBomHort1.1_genomic.fna",  "GCA_905332935.1_iyBomHort1.1_genomic.fna"),
         relative_dir = paste0("../results/a.process_radtags/", name_list , ".fq.gz"),
         Microbiome = ifelse(index_list %in% sampleINmicrobiome, "Yes",  "No"))

write.csv(metadata_RADseq, file = "../code/metadata_RADseq2.csv", quote = FALSE, row.names = F)


# ==============================================================================
# 206 pop map
map_list = metadata_RADseq %>% dplyr::select(name_list,site_list, field_ID_list) %>% mutate(name_list = paste0(name_list,".sorted"))

write_tsv(map_list,file = "../data/206n_popmap.tsv",col_names = F)

# 204 pop map 

# Removing the the following samples due to them having too low retained reads, retained reads percentage and too little contribution to the library: 170 and 166

popmap_new <- map_list[-c(which(map_list$name_list == "BB_P2_PG_170_1.sorted"), which(map_list$name_list == "BB_P3_PG_166_1.sorted")), ]

write_tsv(popmap_new,file = "../data/204n_popmap.tsv",col_names = F)

map_list_Br = popmap_new %>% filter(field_ID_list != "Bt")

map_list_Bt = popmap_new %>% filter(field_ID_list == "Bt")

write_tsv(map_list_Br,file = "../data/Br_popmap.tsv",col_names = F)

write_tsv(map_list_Bt,file = "../data/Bt_popmap.tsv",col_names = F)


popmap_new <- map_list %>% filter(!(name_list == "BB_P2_PG_170_1.sorted"|
                                  name_list == "BB_P3_PG_166_1.sorted"|
                                  name_list == "BB_P1_PG_158_1.sorted"| ## Removing the samples that are problematic and have too few aligned reads
                                  name_list == "BB_P2_PG_205_1.sorted"|
                                  name_list == "BB_P2_PG_242_1.sorted"|
                                  name_list == "BB_P2_PG_237_1.sorted"|
                                  name_list == "BB_P1_PG_68_1.sorted"| ### Samples 64, 24 and 68 are all likely haploid males, so will be taken out and a new popmap made to represent only workers
                                  name_list == "BB_P1_PG_64_1.sorted"|
                                  name_list == "BB_P1_PG_24_1.sorted"))


popmap_new <- popmap_new %>% mutate(interaction = paste0(field_ID_list,"_",site_list)) %>% dplyr::select(name_list,interaction)

table(popmap_new$interaction)

write_tsv(popmap_new,file = "../data/197n_popmap.tsv",col_names = F)

map_list_Br = popmap_new %>% filter(field_ID_list != "Bt")

map_list_Bt = popmap_new %>% filter(field_ID_list == "Bt")

write_tsv(map_list_Br,file = "../data/197n_Br_popmap.tsv",col_names = F)

write_tsv(map_list_Bt,file = "../data/197n_Bt_popmap.tsv",col_names = F)

