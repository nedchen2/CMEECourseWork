

arg <- commandArgs(T)
if(length(arg) < 1){
  cat("Argument: You need to provide the criteria that you want to use!")
  quit('no')
}


# ====================== first look at the feature table
require(tidyverse)

feature_abundance_with_seq <- read.csv("../results/3.Taxonomy_ana/Corrected_Abundance_taxa_table.csv",check.names = F)

feature_abundance_matrix = feature_abundance_with_seq %>% dplyr::select(!c("Sequence","Taxon","Confidence","Suspectable","Frequency","Consensus","Improve")) %>% 
  column_to_rownames(var = "Row.names")

#depth_per_sample <- colSums(feature_abundance_matrix)

#data <- as.data.frame(depth_per_sample) %>% rownames_to_column("Sample_name") %>% 
#  write_csv("../results/4.Diversity_ana/depth_per_sample.csv")

#hist(colSums(feature_abundance_matrix),breaks = seq(1,500000,2000),main = "Distribution of sampling depth")

# ============== Prepare for reimport biom===================

#find OTUs limited to one sample7

sum(rowSums(feature_abundance_matrix[] == 0) == ncol(feature_abundance_matrix)  - 1)
hist(rowSums(!feature_abundance_matrix[] == 0),main = "Distributions" , xlab = "The number of samples", ylab = "Frequency of ASVs" )
#
sum(rowSums(feature_abundance_matrix) == 0)
# 58

#find singletons
sum(rowSums(feature_abundance_matrix) == 1)
# 3

#find doubletons
sum(rowSums(feature_abundance_matrix) == 2)
# 247

# =======filter
#Contingency-based 

filtered <- function(){
  
  # filter sample with low sampleing depth
  
  feature_abundance_matrix <- feature_abundance_matrix[,colSums(feature_abundance_matrix) > 5000]
  
  
  #
  idx_contigency = rowSums(feature_abundance_matrix[] == 0) == ncol(feature_abundance_matrix)  - 1
  idx_total_frequency_based = rowSums(feature_abundance_matrix) <= 1
  idx_final = !(idx_contigency|idx_total_frequency_based)
  
  print (paste0("Ratio of retained ",sum(idx_final)/nrow(feature_abundance_matrix)*100, "%"))
  
  vecter_for_biom <- c("# Constructed from biom file",rep("",90))
  
  biom_for_import_filtered <- feature_abundance_matrix[idx_final,] %>% rownames_to_column("#OTU ID")
  
  colnames_vector <- c("#OTU ID ",colnames(feature_abundance_matrix))
  
  biom_for_import_final_filtered <- as.data.frame(rbind(vecter_for_biom,rbind(colnames_vector,biom_for_import_filtered)))
  
  write.table(biom_for_import_final_filtered , file = "../results/4.Diversity_ana/corrected_abundance_table.tsv",row.names = F,col.names = F)
  
  IDtoretain <-biom_for_import_filtered %>% #find the average abundance of a SV
    pull("#OTU ID")
  
  idx2 <- feature_abundance_with_seq$Row.names %in% IDtoretain 
  
  feature_abundance_with_seq[idx2,] %>% dplyr::select(Row.names,Taxon,Confidence) %>% rename("Feature ID" = `Row.names`) %>% 
    write_tsv("../results/4.Diversity_ana/taxonomy-corrected.tsv")
  
  
} 

filtered()

# ==========unfilter
unfilter <- function() {
  
  vecter_for_biom <- c("# Constructed from biom file",rep("",90))
  
  biom_for_import <- feature_abundance_matrix %>% rownames_to_column("#OTU ID")
  
  colnames_vector <- c("#OTU ID ",colnames(feature_abundance_matrix))
  
  biom_for_import_final <- as.data.frame(rbind(vecter_for_biom,rbind(colnames_vector,biom_for_import)))
  
  write.table(biom_for_import_final , file = "../results/4.Diversity_ana/corrected_abundance_table.tsv",row.names = F,col.names = F)
  
  # =============== Prepare for reimport taxonomy ==================
  
  feature_abundance_with_seq %>% select(Row.names,Taxon,Confidence) %>% rename("Feature ID" = `Row.names`) %>% 
    write_tsv("../results/4.Diversity_ana/taxonomy-corrected.tsv")
}

if (arg[1] == "filter") {
  print ("======================Start filtering=====================")
  cat ("We will filter the taxa data with default set  ")
  filtered()
}else {
  print ("======================Start ====================")
  cat ("We will use the original taxa data with default  ")
  unfilter()
}






