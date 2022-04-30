require(tidyverse)

# ======== Summary of the OTU table including confidence, taxa annotation and sequence,and total frequency

taxonomy <- read.delim ("../results/3.Taxonomy_ana/Taxonomy_export/taxonomy.tsv")


#feature_table <- read.table("../results/2.Feature_table/Feature-table-result/feature-table2.tsv",header=T,check.names = F)
#feature_table_seq <-  read.table("../results/2.Feature_table/Feature-table-result/feature-table-with-seq.tsv",header=T,check.names = F) 

NUMBER <- ncol(read.table("../results/2.Feature_table/Feature-table-result/feature-table-with-seq.tsv",header=T,check.names = F))
test = read.table("../results/2.Feature_table/Feature-table-result/feature-table-with-seq.tsv",header=T,check.names = F) %>%
  column_to_rownames(var = "Feature.ID")

feature_table_with_seq <- read.table("../results/2.Feature_table/Feature-table-result/feature-table-with-seq.tsv",header=T,check.names = F)  %>%
  column_to_rownames(var = "Feature.ID") %>%
  mutate(Frequency = rowSums(.[1:(NUMBER-2)])) %>%  # 2 is the Non-sample column number
  arrange(desc(Frequency)) %>% rownames_to_column(var = "Feature.ID")


Join_Three_table <-left_join(feature_table_with_seq,taxonomy,by = "Feature.ID") %>% arrange(desc(Frequency))

Join_Three_table[,"Suspectable"] = ""

# first load the possible contaminant genus to the R

list_of_contaminate <- read.csv("../code/List_of_contaminent.tsv",sep = "\t")

vector_of_contaminate <- str_remove(unlist(str_split(list_of_contaminate$List.of.constituent.contaminant.genera,","))," " )


for (i in seq(length(vector_of_contaminate))){
  index <- grepl(paste0("g__",vector_of_contaminate[i]),
                 Join_Three_table$Taxon,
                 ignore.case = F)
  Join_Three_table[index,"Suspectable"] = paste0(Join_Three_table[index,"Suspectable"],"; ",vector_of_contaminate[i]) 
}

# See what kind of contaminant we have 
unique(Join_Three_table[Join_Three_table$Suspectable != "","Suspectable"])
Join_Three_table[seq(1:10),"Taxon"]

write.table(Join_Three_table,file="../results/3.Taxonomy_ana/Feature_abundance_table_with_seq_and_taxa_annotation.tsv",row.names = F)


# ===== deal with unassigned and add URL to the fasta file

idx1 = !grepl("g__",Join_Three_table$Taxon,ignore.case = T)
idx2 = grepl("uncultured",Join_Three_table$Taxon,ignore.case = T)

idx = idx1 | idx2

add_blastn <- function(data){
  blasteURL = paste0("http://www.ncbi.nlm.nih.gov/BLAST/Blast.cgi?ALIGNMENT_VIEW=Pairwise&PROGRAM=blastn&DATABASE=nt&CMD=Put&QUERY=",data$Sequence)
  return(blasteURL)
}

print (paste0("Ratio of unassigned:",sum(idx)/nrow(Join_Three_table)*100,"%"))
unassigned = Join_Three_table[idx,] %>% mutate(blastURL = add_blastn(.))

# output for autoblast
write.table(unassigned,file="../results/3.Taxonomy_ana/Unassigned_blastn-result.tsv",row.names = F)



# =============== test for remove the contaminate
df_test <- feature_table_with_seq %>% select(!c("Sequence","Frequency")) %>% column_to_rownames(var = "Feature.ID")

# Here, we assume sample 2 as the blank sample
# subtract the feature from blank sample

df_subtraction = df_test - df_test$Blank 

df_subtraction[df_subtraction < 0 ] = 0 

# read the taxonomy information
df_taxonomy <- Join_Three_table %>%select("Feature.ID","Sequence","Taxon","Confidence") %>% column_to_rownames(var = "Feature.ID")

df_join <- merge(df_subtraction,df_taxonomy,by="row.names")

df_join[,"Suspectable"] = ""

# first load the possible contaminant genus to the R

list_of_contaminate <- read.csv("../code/List_of_contaminent.tsv",sep = "\t")

vector_of_contaminate <- str_remove(unlist(str_split(list_of_contaminate$List.of.constituent.contaminant.genera,","))," " )

for (i in seq(length(vector_of_contaminate))){
  index <- grepl(paste0("g__",vector_of_contaminate[i]),
                 df_join$Taxon,
                 ignore.case = F)
  df_join[index,"Suspectable"] = paste0(df_join[index,"Suspectable"],"; ",vector_of_contaminate[i]) 
}

# See what kind of contaminant we have 
unique(df_join[df_join$Suspectable != "","Suspectable"])


df_final = df_join  %>% mutate(Frequency = rowSums(.[2:92])) %>%  # 2 is the Non-sample column number
  arrange(desc(Frequency))

write.table(df_final,file="../results/3.Taxonomy_ana/Feature_abundance_table_without_blank_sample.tsv",row.names = F)

# ===== deal with unassigned and add URL to the fasta file

idx3 = !grepl("g__",df_final$Taxon,ignore.case = T)
idx4 = grepl("uncultured",df_final$Taxon,ignore.case = T)

idx_noblank = idx3 | idx4

add_blastn <- function(data){
  blasteURL = paste0("http://www.ncbi.nlm.nih.gov/BLAST/Blast.cgi?ALIGNMENT_VIEW=Pairwise&PROGRAM=blastn&DATABASE=nt&CMD=Put&QUERY=",data$Sequence)
  return(blasteURL)
}

unassigned_noblank = df_final[idx_noblank,] %>% mutate(blastURL = add_blastn(.))

# output for autoblast
write.table(unassigned_noblank,file="../results/3.Taxonomy_ana/Unassigned_blastn-result-noblank.tsv",row.names = F)


# ============ Combine the consensus blast result with the unassigned table ==============

uninomial_to_bionomial <- function(){
  test <- 
  
  
  
}



Combine_unassigned_0.99 <- function(){
  taxonomy_blast <- read.delim ("../results/blast/0.99-1hit/taxonomy.tsv")
  colnames(taxonomy_blast) <- c("Row.names","Taxon_blast","Consensus")
  
  df_test2 <- left_join(unassigned_noblank,taxonomy_blast,by="Row.names") 
  
  df_final2 <- df_test2 %>% mutate(Taxon_blast_revised =str_replace(str_replace(Taxon_blast,"k__","d__"),"c__Betaproteobacteria; o__Burkholderiales","c__Gammaproteobacteria; o__Burkholderiales")) %>% 
    select("Row.names","Taxon","Confidence","Taxon_blast_revised","Consensus","Frequency")
  
  # index of possibly improved
  idx5 = !grepl("g__",df_test2$Taxon_blast,ignore.case = T)
  idx6 = grepl("uncultured",df_test2$Taxon_blast,ignore.case = T)
  
  idx_blast = !(idx5 | idx6)
  
  # index of whether the result from silva is identical to result the blast
  index_blast2 =c()
  for (i in seq(nrow(df_final2))){
    result <- grepl(df_final2$Taxon[i],df_final2$Taxon_blast_revised[i],ignore.case = T)
    index_blast2 = c(index_blast2,result)
  }
  
  idx_final <- idx_blast & index_blast2
  idx_dissimilar <- idx_blast & !index_blast2
  idx_residue <- !(idx_final | idx_dissimilar)
  
  df_final2[idx_final,"Improve"] = "Improve(0.99-1hit)"
  df_final2[idx_dissimilar,"Improve"] = "Improve but not identical with silva"
  df_final2[idx_residue,"Improve"] = "No improve"
  
  write.table(df_final2,file="../results/3.Taxonomy_ana/Unassigned_blastn-result-noblank-corrected_blast_99.tsv",row.names = F)
}

Combine_unassigned_0.99()


Combine_unassigned_0.97 <- function(){
  taxonomy_blast <- read.delim ("../results/blast/0.97-5hit/taxonomy.tsv")
  colnames(taxonomy_blast) <- c("Row.names","Taxon_blast","Consensus")
  
  df_test2 <- left_join(unassigned_noblank,taxonomy_blast,by="Row.names") 
  
  df_final2 <- df_test2 %>% mutate(Taxon_blast_revised =str_replace(str_replace(Taxon_blast,"k__","d__"),"c__Betaproteobacteria; o__Burkholderiales","c__Gammaproteobacteria; o__Burkholderiales")) %>% 
    select("Row.names","Taxon","Confidence","Taxon_blast_revised","Consensus","Frequency")
  
  # index of possibly improved
  idx5 = !grepl("g__",df_test2$Taxon_blast,ignore.case = T)
  idx6 = grepl("uncultured",df_test2$Taxon_blast,ignore.case = T)
  
  idx_blast = !(idx5 | idx6)
  
  # index of whether the result from silva is identical to result the blast
  index_blast2 =c()
  for (i in seq(nrow(df_final2))){
    result <- grepl(df_final2$Taxon[i],df_final2$Taxon_blast_revised[i],ignore.case = T)
    index_blast2 = c(index_blast2,result)
  }
  
  idx_final <- idx_blast & index_blast2
  idx_dissimilar <- idx_blast & !index_blast2
  idx_residue <- !(idx_final | idx_dissimilar)
  
  df_final2[idx_final,"Improve"] = "Improve(0.97-5hit)"
  df_final2[idx_dissimilar,"Improve"] = "Improve but not identical with silva"
  df_final2[idx_residue,"Improve"] = "No improve"
  
  write.table(df_final2,file="../results/3.Taxonomy_ana/Unassigned_blastn-result-noblank-corrected_blast_97.tsv",row.names = F)
}


Combine_unassigned_0.97()


# =============================================

# fix some of the content by manual blast

final_fix <- function(){
  TOP20 = read.delim("../results/3.Taxonomy_ana/Final_____Unassigned_blastn-result-noblank-corrected_blast.tsv")[1:20,] %>% 
    select(c("Row.names","Taxon_blast_revised","Consensus","Improve"))
  
  TOP20[TOP20$Improve == "Improve","Improve"] = "Improve(0.97–5hit)"
  
  # We decide to only correct the top20 unassigned feature
  
  df_correct = TOP20[TOP20$Improve == "Improve(0.97–5hit)"|TOP20$Improve == "Improve(0.99–1hit)",]
  
  
  idx_replace = df_final$Row.names%in%df_correct$Row.names
  
  df_final <- left_join(df_final,df_correct,by="Row.names")
  
  df_final[idx_replace,"Taxon"] <- df_final[idx_replace,"Taxon_blast_revised"]
  
  
  df_final <- df_final %>% select(!"Taxon_blast_revised") %>% arrange(desc(Frequency)) %>% replace_na(list("Improve"="No change"))
  
  
  write.table(df_final,file="../results/3.Taxonomy_ana/Corrected_Abundance_taxa_table.csv",row.names = F,sep=",")
}











#  ============ Deal with the blast result downloaded from the Website ========


#label = unassigned %>% select("Feature.ID","Frequency","Taxon","Confidence")

#blast_dir = "../results/blast/"

#blast_result = c()
#for (i in 1:length(list.files(blast_dir))){
#  df = read.csv(paste0(blast_dir, list.files(blast_dir)[i])) %>% mutate(Feature.ID = unlist(strsplit(list.files(blast_dir)[i],split = ".",fixed = T))[1])
#  blast_result =  rbind(blast_result,df[1,])
#}


#Top10_unassigned_genus_blast = left_join(blast_result,label,by = "Feature.ID") %>% 
#  select("Taxon", "Frequency" ,  "Confidence"  ,"Description","Scientific.Name", "Max.Score" ,
#         "Total.Score","Query.Cover","E.value","Per..ident",     
#        "Acc..Len", "Accession","Feature.ID"   )

#write.table(Top10_unassigned_genus_blast ,file="../results/blast/Top10_unassigned_genus_blast.xls",row.names = F)




