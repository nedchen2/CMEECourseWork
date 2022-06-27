require(tidyverse)



metadata_microbiome <- read.csv("./metadata_Microbiome.csv")

metadata_RADseq <- read.csv("../../UKBB_RADseq/code/metadata_RADseq.csv") %>% dplyr::select("index_list","F_list") %>% 
  rename( SampleID = index_list) 

metadata_microbiome <- metadata_microbiome%>% left_join(metadata_RADseq)

metadata_test <- metadata_microbiome %>% dplyr::select(SampleID,Crithidia_total_per_bee,Nosema_total_per_bee,Apicystis_total_per_bee,gut_parasite_richness,F_list) %>% mutate(SampleID = paste0("Bee.", SampleID))

write_tsv(x = metadata_test,file = "../results/6.Network_analysis/metadata_crithidia.txt")

metadata_test2 <- metadata_microbiome %>% 
  dplyr::select(SampleID,Crithidia_total_per_bee,Nosema_total_per_bee,Apicystis_total_per_bee,gut_parasite_richness,F_list,Enterotype,Species) %>% 
  mutate(SampleID = paste0("Bee.", SampleID))

#== abundance table


df_taxa_test <- read_qza("../results/6.Network_analysis/table-l6.qza")$data %>% as.data.frame() 

colnames(df_taxa_test) <- paste0("Bee.",colnames(df_taxa_test))

df_taxa_test <- df_taxa_test %>%
  rownames_to_column("taxonomy") %>% rownames_to_column("#OTU ID") %>% relocate(taxonomy,.after = last_col()) %>% 
  mutate(taxonomy = str_replace(taxonomy, pattern = "d__" ,replacement = "k__"),
         taxonomy = paste0(taxonomy, "; s__")
  )


# == prepare for biom convert

vecter_for_biom <- c("# Constructed from biom file",rep("",86))

biom_for_import_filtered <- df_taxa_test 

colnames_vector <- colnames(biom_for_import_filtered)

biom_for_import_final_filtered <- as.data.frame(rbind(vecter_for_biom,rbind(colnames_vector,biom_for_import_filtered)))

write.table(biom_for_import_final_filtered , file = "../results/6.Network_analysis/feature-table-genus-network.tsv",row.names = F,col.names = F)

# open the feature-table-genus-network in the software , save it as txt file
# biom convert -i ../results/6.Network_analysis/feature-table-genus-network.tsv -o ../results/6.Network_analysis/new_otu_table.biom --to-hdf5 --table-type="OTU table" --process-obs-metadata taxonomy
# biom convert -i ../results/6.Network_analysis/new_otu_table.biom -o ../results/6.Network_analysis/otu_lineage.txt --to-tsv --header-key taxonomy --output-metadata-id "taxonomy"
# otu_lineage.txt is the file that we need


# ================ Extract files for Enterotype compare

split_data_frame <- function(data = df_taxa_test , metadata  =  metadata_test2,colna =  "Enterotype",output_dir = "../results/6.Network_analysis/"){
  expression <- data
  metadata_local <- metadata
  term_list = unique(metadata_local[,colna])
  ##############根据总表进行拆分#############
  for (i in 1:length(term_list)) {
    print (paste0("我们现在正在处理",term_list[i]))
    ####处理表达量文件
    
    idx <- metadata_local[,colna] == term_list[i]
    
    sampleID = metadata_local[idx, "SampleID"]
    
    selectColumn = c("#OTU ID",sampleID,"taxonomy")
    
    tmp <- expression %>% dplyr::select(all_of(selectColumn))
    
    groupname1 = colna
    groupname = term_list[i]
    
    output_path =  paste0(output_dir,"/",groupname1,"/")
    
    vecter_for_biom <- c("# Constructed from biom file",rep("",ncol(tmp)))
    
    biom_for_import_filtered <-tmp
    
    colnames_vector <- colnames(biom_for_import_filtered)
    
    biom_for_import_final_filtered <- as.data.frame(rbind(vecter_for_biom,rbind(colnames_vector,biom_for_import_filtered)))
  
    if (dir.exists(output_path)){
      write.table(biom_for_import_final_filtered , file = paste0(output_path,groupname,".split_result.tsv"),row.names = F,col.names = F)
    }else{
      dir.create(output_path)
      write.table(biom_for_import_final_filtered , file = paste0(output_path,groupname,".split_result.tsv"),row.names = F,col.names = F)
    }
    print ("================================================")
  }
}
  


split_data_frame(colna = "Species")

#biom convert -i ./Enterotype_1.split_result.tsv -o ./new_otu.biom --to-hdf5 --table-type="OTU table" --process-obs-metadata taxonomy
#biom convert -i ./new_otu.biom -o ./otu_lineage.txt --to-tsv --header-key taxonomy --output-metadata-id "taxonomy"











