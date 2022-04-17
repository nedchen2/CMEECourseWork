# clean

if(!require("dplyr")) {install.packages("dplyr")}
require(dplyr)

#previous metadata

df_old= read.table("map_UKBB.txt",sep = "\t",header = T)

df_old = df_old[(df_old$Species != ""),] 
df_old = na.omit(df_old)

df.old.revised  <- df_old %>% mutate(BarcodeSequence_old=paste0(substr(df_old$Index1i7Sequence,1,7),substr(df_old$Index2i5Sequence,1,7)),
                     LinkerPrimerSequence_old=Linker1PrimerSequence,
                     sample_name=Sample.ID) %>% dplyr::select("sample_name","BarcodeSequence_old","LinkerPrimerSequence_old","CollectionSite","Species","Infection","Infection.intensity","Description")
  
#updated metadata
df_new = read.table("micro_map.txt",sep="\t",header = T)
df.new.revised <-  df_new %>% mutate(BarcodeSequence=paste0(substr(df_new$Index1i7Sequence,1,7),substr(df_new$Index2i5Sequence,1,7)),
                                LinkerPrimerSequence=Linker1PrimerSequence,
                                sample_name=as.character(Bee_ID)) %>% dplyr::select("sample_name","BarcodeSequence","LinkerPrimerSequence")


df.merged = df.new.revised %>%  left_join(df.old.revised,by = "sample_name")

df.merged$BarcodeSequence == df.merged$BarcodeSequence_old
str(df.merged)

write.table(df.merged,file = "../results/1.Quality_Control/Demultiplexing/sample-metadata.tsv",row.names = F,sep="\t")

write.table(df.merged,file = "./sample-metadata.tsv",row.names = F,sep="\t")