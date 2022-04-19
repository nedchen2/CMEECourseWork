# clean

if(!require("dplyr")) {install.packages("dplyr")}
require(dplyr)
require(tidyverse)

#previous metadata

df_old= read.table("map_UKBB.txt",sep = "\t",header = T)

df_old = df_old[(df_old$Sample.ID != ""),]

df.old.revised  <- df_old %>% mutate(BarcodeSequence=paste0(substr(df_old$Index1i7Sequence,1,7),substr(df_old$Index2i5Sequence,1,7)),
                     LinkerPrimerSequence=Linker1PrimerSequence,
                     sample_name=Sample.ID) %>% dplyr::select("sample_name","BarcodeSequence","LinkerPrimerSequence","CollectionSite","Species","Infection","Infection.intensity","Description")  %>% 
                      replace_na(list(CollectionSite = "Blank",Species = "Blank",Infection = "Blank",Infection.intensity = "Blank"))
  


write.table(df.old.revised,file = "../results/1.Quality_Control/Demultiplexing/sample-metadata.tsv",row.names = F,sep="\t")

write.table(df.old.revised,file = "./sample-metadata.tsv",row.names = F,sep="\t")

#to discover the pattern of barcode sequence
#zcat lane1_Undetermined_L001_R2_1.fastq.gz | grep '^@' | cut -d: -f10 | sort | uniq -c | sort - -k1rn | head -n120 > result.txt

df_top120Barcode = read.delim("../16sRaw/result.txt",header = F) %>% 
  mutate(repeats = extract_numeric(V1),
  BarcodeSequence = str_sub(V1,-14)) %>%
  select("repeats","BarcodeSequence" ) %>% 
 left_join(df.old.revised,by = c("BarcodeSequence"))

write.table(df_top120Barcode,file = "./Top120Barcode.tsv",row.names = F,sep="\t")






#updated metadata
df_new = read.table("micro_map.txt",sep="\t",header = T)
df.new.revised <-  df_new %>% mutate(BarcodeSequence=paste0(substr(df_new$Index1i7Sequence,1,7),substr(df_new$Index2i5Sequence,1,7)),
                                LinkerPrimerSequence=Linker1PrimerSequence,
                                sample_name=as.character(Bee_ID)) %>% dplyr::select("sample_name","BarcodeSequence","LinkerPrimerSequence")


df.merged = df.new.revised %>%  left_join(df.old.revised,by = "sample_name")

df.merged$BarcodeSequence == df.merged$BarcodeSequence_old
str(df.merged)

#write.table(df.merged,file = "../results/1.Quality_Control/Demultiplexing/sample-metadata.tsv",row.names = F,sep="\t")

#write.table(df.merged,file = "./sample-metadata.tsv",row.names = F,sep="\t")