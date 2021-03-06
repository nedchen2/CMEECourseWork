# clean

if(!require("dplyr")) {install.packages("dplyr")}
require(dplyr)
require(tidyverse)

#previous metadata

df_old= read.table("map_UKBB.txt",sep = "\t",header = T)

df_old = df_old[(df_old$Sample.ID != ""),]

# We found that the barcode of Index2i5Sequence TAGATCGC
index = df_old$Index2i5Sequence == "TAGATCGC"
replace = "GCGTAAGN"

df_old$Index2.modified = str_replace(df_old$Index2i5Sequence,pattern = "TAGATCGC",replacement = "GCGTAAGN")

df.old.revised  <- df_old %>% mutate(BarcodeSequence=paste0(substr(df_old$Index1i7Sequence,1,7),substr(df_old$Index2.modified,1,7)),
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
  full_join(df.old.revised,by = c("BarcodeSequence"))

write.table(df_top120Barcode,file = "./Top120Barcode.tsv",row.names = F,sep="\t")





#updated metadata
df_new = read.table("micro_map.txt",sep="\t",header = T)

df_new$Index2.modified = str_replace(df_new$Index2i5Sequence,pattern = "TAGATCGC",replacement = "GCGTAAGN")

df.new.revised <-  df_new %>% mutate(BarcodeSequence=paste0(substr(df_new$Index1i7Sequence,1,7),substr(df_new$Index2.modified,1,7)),
                                LinkerPrimerSequence=Linker1PrimerSequence,
                                sample_name=as.character(Bee_ID)) %>% dplyr::select( "sample_name" , "BarcodeSequence",  "LinkerPrimerSequence"  ,"radseq_ID_list", "sibling_sets", "Site", "conopid_larvae","Apicystis_binomial",    
                                                                                     "mean_Apicystis_sp_ul" , "Crithidia_binomial" ,"mean_Crithidia_cell_ul", "Nosema_binomial" , "mean_Nosema_sp_ul"  ,  
                                                                                     "para_richness")

write.table(df.new.revised,file = "./sample-metadata-NewMappingFile.tsv",row.names = F,sep="\t")



df.merged = df.new.revised %>%  left_join(df.old.revised,by = "sample_name")

df.merged$BarcodeSequence == df.merged$BarcodeSequence_old
str(df.merged)

#write.table(df.merged,file = "../results/1.Quality_Control/Demultiplexing/sample-metadata.tsv",row.names = F,sep="\t")

#write.table(df.merged,file = "./sample-metadata.tsv",row.names = F,sep="\t")


df_final = read.table("combined_mapping_file.csv",sep=",",header = T) %>% 
  mutate(Subgenus  = ifelse(test = finalised_species == "B.terrestris", yes = "Bombus.sensu.stricto", no= "Bombus.Megabombus"))%>% 
  rename(sample_name =`Bee_ID` ,
         Species = `finalised_species`,
         CollectionSite = `Site`)   %>% 
  mutate(Interaction = paste0(Species,".",CollectionSite))

write.table(df_final,file = "./sample-metadata.tsv",row.names = F,sep="\t")


# =========== test if the final one is consistent with the previous one

df_test <- df.old.revised %>% dplyr::select(sample_name,BarcodeSequence) %>% rename(BarcodeSequence_old=BarcodeSequence)

df_final %>% left_join(df_test) %>% mutate(test= BarcodeSequence == BarcodeSequence_old) %>% pull(test) %>% sum()
#91



