#!/usr/bin/env R
#15/02/2022
###A script for assaying the sample performance after process_radtags

rm(list = ls())
graphics.off()
library(ggplot2)
require(tidyverse)


process_radtags_log <- read.table("../results/a.process_radtags/reads_stat_table.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE)

metadata <- read.csv("../code/sample-metadata.tsv", stringsAsFactors = FALSE, sep = "\t")


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
