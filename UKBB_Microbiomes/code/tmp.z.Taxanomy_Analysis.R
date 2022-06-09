require(tidyverse)
require(ggthemes)
require(pheatmap)
require(reshape2)
require(RColorBrewer)


# =======================Taxanomy analysis
taxonomy.l6 <- read.delim("../results/3.Taxonomy_ana/Taxonomy_export/level-6.csv",sep = ",")

metadata <- read.table("./sample-metadata.tsv",header = T)

palette <- colorRampPalette(c("blue","white","red"))(n=256)


Metadata_extract <- function(groupinfo = "Infection") {
  metadata.sorted <- metadata %>% arrange(nchar(Infection)) %>% column_to_rownames(var = "sample_name") %>% dplyr::select(groupinfo) 
  return(metadata.sorted)
}


Text_extract <- function(x,level = "g"){
  # function for extract the information from the taxanomy
  # level = "g" means extract genus from the taxanomy
  if (level == "g"){
    name_vector <- str_extract(x,"g__.*") %>% str_remove("; s__") %>% str_remove("g__") 
    name_vector[name_vector==""] = NA
    mask = is.na(name_vector)
    name_vector[mask] = str_extract(x[mask],"f__.*")
    name_vector[name_vector==""] = NA
    mask1 = is.na(name_vector)
    name_vector[mask1] = str_extract(x[mask1],"o__.*")
    
    name_vector[name_vector==""] = NA
    mask2 = is.na(name_vector)
    name_vector[mask2] = str_extract(x[mask2],"c__.*")
    
    name_vector[name_vector==""] = NA
    mask3 = is.na(name_vector)
    name_vector[mask3] = str_extract(x[mask3],"p__.*")
    
    name_vector[name_vector==""] = NA
    mask4 = is.na(name_vector)
    name_vector[mask4] = str_extract(x[mask4],"d__.*")
  }
  return (name_vector)
}

# ============================ absolute abundance
df_taxa= read.table("../results/3.Taxonomy_ana/Feature-table-result/feature-table-taxa2.tsv",sep = "\t",header = T,check.names = F) %>%
  column_to_rownames(var = "Feature.ID") %>%
  mutate(Frequency = rowSums(.)) %>% 
  arrange(desc(Frequency)) %>% 
  rownames_to_column(var = "Feature.ID") %>% 
  mutate(Genus = paste0(Text_extract(Feature.ID, level = "g"), " - ",row.names(.))) %>%
  column_to_rownames(var = "Genus") %>% dplyr::select(!c("Feature.ID","Frequency")) 


# ============ Explore the assigned and unassigned

# Transform the Unassigned Taxa in certain level to unassigned

length(unique(metadata$sample_name))
length(unique(metadata$BarcodeSequence))

idx1 = grepl("Snodgrassella",row.names(df_taxa))
idx2 = grepl("Gilliamella",row.names(df_taxa))
idx_attention = c(idx1,idx2)

df_attention = rbind(df_taxa[idx1,],df_taxa[idx2,]) %>% rownames_to_column(var="Genus")

write.table(df_attention,file="../results/3.Taxonomy_ana/SnodgrassellaAndGilliamella.tsv",row.names = F)

idx = grepl(";__",
            row.names(df_taxa),
            ignore.case = T)

rate_of_assigned = round((1 - sum(idx)/nrow(df_taxa)) * 100)

print (paste0("the rate of assigned is ",rate_of_assigned,"%"))

# 把末分类调整到最后面
df_taxa.sorted = rbind(df_taxa[!idx, ], df_taxa[idx, ])


# ===================================== relative abundance
test <- function(x){
  return(x/sum(x))
}

df_relative_abundance = as.data.frame (apply(df_taxa,MARGIN = 2,FUN = test))

df_relative_abundance.sorted =  as.data.frame (apply(df_taxa.sorted,MARGIN = 2,FUN = test))

#===== Function of heatmap 
plot_heatmap <- function (df_abundance_matrix, cluster = T,annotation_col = Metadata_extract(), main = "Top 10 Microbe" ,disp = F, color = palette) {
  # function for plotting the heatmap
  p = pheatmap(log(df_abundance_matrix+0.0000001),
               main = main, annotation_col = annotation_col, annotation_row = NA, scale="row",
               treeheight_row=30, treeheight_col=30, lwd=1,
               color = color, show_rownames = T, fontsize=8, border= T,cellwidth = 8,cellheight = 8,
               cluster_rows = T , cluster_cols = cluster , angle_col = 90, display_numbers = disp)
  return (p)
}

# ===== Function of Barplot


colors = brewer.pal(11,"Paired")

plot_stack_barplot <- function(data = data_all, subgroup = FALSE){ 

if (!subgroup){
p=ggplot(data, aes(x = variable, y = value, fill = Taxonomy)) +
  geom_bar(stat = "identity",
           position = "fill",
           width = 0.7) +
  scale_y_continuous(labels = scales::percent) +
  #facet_grid(~ group, scales = "free_x", switch = "x") +
  theme(strip.background = element_blank()) +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank()) +
  xlab("Samples") + ylab("Percentage (%)") +
  theme_classic() + theme(axis.text.x = element_text(
    angle = 45,
    vjust = 1,
    hjust = 1
  )) +
  theme(text = element_text(family = "sans", size = 10)) +
  scale_fill_manual(values = colors)
 #scale_fill_brewer(palette="Set3")
}else{
  p=ggplot(data, aes(x = variable, y = value, fill = Taxonomy)) +
    geom_bar(stat = "identity",
             position = "fill",
             width = 0.7) +
    scale_y_continuous(labels = scales::percent) +
    facet_grid(~ Group, scales = "free_x", switch = "x") +
    theme(strip.background = element_blank()) +
    theme(axis.ticks.x = element_blank(), axis.text.x = element_blank()) +
    xlab("Samples") + ylab("Percentage (%)") +
    theme_classic() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      hjust = 1
    )) +
    theme(text = element_text(family = "sans", size = 10)) +
    scale_fill_manual(values = colors)
}
  return(p)
}


#=====Function for plot corplot

library(corrplot)
plot_corplot <- function() {
  
}

pairs(taxa_correlation)


require(PerformanceAnalytics)
chart.Correlation(taxa_correlation.abundance,method = "spearman")



# ========== heatmap

Top15.collapsed.df = df_taxa[seq(1:15),] 

Top10.collapsed.df = df_taxa[seq(1:10),]

plot_heatmap(Top10.collapsed.df)

plot_heatmap(Top15.collapsed.df)






# ========== heatmap
Top10.collapsed.relative.df = df_relative_abundance[seq(1:10),]


Top10.collapsed.relative.df.sorted = df_relative_abundance.sorted[seq(1:10),]

plot_heatmap(Top10.collapsed.relative.df)


#Check if the calculation works
#df_relative_abundance %>% mutate(Frequency = rowSums(.))%>% dplyr::select(Frequency) == 1

# ========== corplot
# association between taxa

taxa_correlation.relative.sorted <- t(Top10.collapsed.relative.df.sorted)

taxa_correlation.relative <- t(Top10.collapsed.relative.df)

require(PerformanceAnalytics)
chart.Correlation(taxa_correlation.relative,method = "spearman")

chart.Correlation(taxa_correlation.relative.sorted,method = "spearman")



Create_Table_topN <- function(data = df_relative_abundance  ,topN=10) {
  
  other = colSums(data[(topN+1):dim(data)[1],])
  
  df_relative_abundance_top =data[1:(topN),]
  
  df_relative_abundance_top = rbind(df_relative_abundance_top, other)
  
  rownames(df_relative_abundance_top)[topN+1] = c("Other")
  
  df_relative_abundance_top$Taxonomy = rownames(df_relative_abundance_top)
  
  data_all = as.data.frame(melt(df_relative_abundance_top, id.vars = c("Taxonomy")))
  
  #To let the bar plot sorted with abundance
  data_all$Taxonomy  = factor(data_all$Taxonomy, levels = rownames(df_relative_abundance_top))
  
  return (data_all)
  
}

# if we need to filter out the unassigned 

data_all.sorted <- Create_Table_topN(data = df_relative_abundance.sorted  ,topN=10)

# create data for bar plot
data_all <- Create_Table_topN(data = df_relative_abundance  ,topN=10)


# =========== Barplot

plot_stack_barplot(subgroup = FALSE) 

plot_stack_barplot(data = data_all.sorted , subgroup = FALSE) 

# ===================================== subgroup analysis

# ======================= Infection

sampFile <- Metadata_extract(groupinfo = "Infection")
colnames(sampFile) <- c("Group")

data_all.Infection = merge(data_all, sampFile, by.x = "variable", by.y = "row.names")

data_all.Infection.sorted = merge(data_all.sorted, sampFile, by.x = "variable", by.y = "row.names")



# =========== Barplot

plot_stack_barplot(data = data_all.Infection, subgroup = TRUE) 

plot_stack_barplot(data = data_all.Infection.sorted, subgroup = TRUE) 

# =========== Random Forest
require(randomForest)
library(caret)
require(tidyverse)


# We will use Top_10_relative abundance table here
# use row.names to represent the index column

data <- data_all.Infection %>% pivot_wider(names_from = "Taxonomy",values_from = "value",id_cols = "variable") %>% 
  column_to_rownames(var = "variable") %>%  merge( sampFile, by.x = "row.names", by.y = "row.names")%>% 
  column_to_rownames(var = "Row.names")

#sorted
data <- data_all.Infection.sorted %>% pivot_wider(names_from = "Taxonomy",values_from = "value",id_cols = "variable") %>% 
  column_to_rownames(var = "variable") %>%  merge( sampFile, by.x = "row.names", by.y = "row.names")%>% 
  column_to_rownames(var = "Row.names")

data$Group <- as.factor(data$Group)

colnames(data) <- str_remove(colnames(data)," - *") %>%  str_remove(";__")  %>%  str_remove(";__") %>%  str_remove("-")

set.seed(222)
ind <- sample(2, nrow(data), replace = TRUE, prob = c(0.8, 0.2))
train <- data[ind==1,]
test <- data[ind==2,]

rf <- randomForest(Group~., data=train, proximity=TRUE) 
print(rf)

#confusion matrix
p1 <- predict(rf, train)
confusionMatrix(p1, train$ Group)

p2 <- predict(rf, test)
confusionMatrix(p2, test$ Group)

#importance(rf)

varImpPlot(rf,
           sort = T,
           n.var = 10,
           main = "Top 10 - Variable Importance")




# ======================== Species

sampFile <- Metadata_extract(groupinfo = "Species")
colnames(sampFile) <- c("Group")
data_all.Species = merge(data_all, sampFile, by.x = "variable", by.y = "row.names")

data_all.Species.sorted = merge(data_all.sorted, sampFile, by.x = "variable", by.y = "row.names")


plot_stack_barplot(data = data_all.Species, subgroup = TRUE) 

plot_stack_barplot(data = data_all.Species.sorted, subgroup = TRUE) 



#  ======================= CollectionSite

sampFile <- Metadata_extract(groupinfo = "CollectionSite")
colnames(sampFile) <- c("Group")
data_all.CollectionSite = merge(data_all, sampFile, by.x = "variable", by.y = "row.names")
data_all.CollectionSite.sorted = merge(data_all.sorted, sampFile, by.x = "variable", by.y = "row.names")

plot_stack_barplot(data =data_all.CollectionSite, subgroup = TRUE) 

plot_stack_barplot(data =data_all.CollectionSite.sorted, subgroup = TRUE) 





