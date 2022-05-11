require(tidyverse)
require(ggthemes)
require(pheatmap)
require(reshape2)
require(RColorBrewer)


# ==========

library(qiime2R)

metadata<- read.table("./sample-metadata.tsv",header = T) %>% rename(SampleID = `sample_name`)
feature_table<-read_qza("../results/4.Diversity_ana/feature-table-correct.qza")$data
taxonomy<-read_qza("../results/4.Diversity_ana/taxonomy-corrected.qza")$data
relative.feature.table <- apply(feature_table, 2, function(x) x/sum(x)*100) #convert to percent

#problem here: use the table after taxa collapse might be better 
plot_percent_heatmap <- function(SVs = relative.feature.table,topn = 30){

  SVsToPlot <- data.frame(MeanAbundance=rowMeans(SVs)) %>% #find the average abundance of a SV
    rownames_to_column("Feature.ID") %>%
    arrange(desc(MeanAbundance)) %>%
    top_n(topn, MeanAbundance) %>%
    pull(Feature.ID) #extract only the names from the table
  
  data <- SVs %>% as.data.frame() %>%
    rownames_to_column("Feature.ID") %>%
    gather(-Feature.ID, key="SampleID", value="Abundance") %>%
    mutate(Feature.ID=if_else(Feature.ID %in% SVsToPlot,  Feature.ID, "Remainder")) %>% #flag features to be collapsed
    group_by(SampleID, Feature.ID) %>%
    summarize(Abundance=sum(Abundance))%>%
    left_join(metadata) %>%
    mutate(NormAbundance=log10(Abundance+0.01)) %>% # do a log10 transformation after adding a 0.01% pseudocount. Could also add 1 read before transformation to percent
    left_join(taxonomy) %>%
    mutate(Feature=gsub("[dpcofgs]__", "", Taxon)) %>% 
    replace_na(.,list(Feature = "others")) # trim out leading text from taxonomy string
    
  p <- ggplot(data = data, aes(x=SampleID, y=Feature, fill=NormAbundance)) +
    geom_tile() +
    facet_grid(~`Species`, scales="free_x") +
    theme_q2r() +
    theme(axis.text.x=element_text(angle=90, hjust=1,size = 4,face = "bold")) + 
    labs(title = paste0("Top ", topn, " Abundance Heatmap"), y = "Taxonomy") +
    scale_fill_viridis_c(name="log10(% Abundance)") 
  p
  ggsave(plot = p,filename = "../results/4.Diversity_ana/top_features_heatmap.pdf", height=4, width=11, device="pdf") # save a PDF 3 inches by 4 inches
}

#plot_percent_heatmap(topn = 10)

# for taxon
plot_percent_heatmap_taxon <- function(SVs = relative.feature.table,topn = 30){
  
  SVsToPlot <- data.frame(MeanAbundance=rowMeans(SVs)) %>% #find the average abundance of a SV
    rownames_to_column("Feature.ID") %>%
    arrange(desc(MeanAbundance)) %>%
    top_n(topn, MeanAbundance) %>%
    pull(Feature.ID) #extract only the names from the table
  
  data <- SVs %>% as.data.frame() %>%
      rownames_to_column("Feature.ID") %>%
      gather(-Feature.ID, key="SampleID", value="Abundance") %>%
      mutate(Feature.ID=if_else(Feature.ID %in% SVsToPlot,  Feature.ID, "Remainder")) %>%  #flag features to be collapsed
      left_join(taxonomy) %>%
      group_by(SampleID,Taxon) %>%
      summarize(Abundance=sum(Abundance))%>% 
    left_join(metadata) %>%
    mutate(NormAbundance=log10(Abundance+0.01)) %>% # do a log10 transformation after adding a 0.01% pseudocount. Could also add 1 read before transformation to percent
    mutate(Feature=gsub("[dpcofgs]__", "", Taxon)) %>% 
    replace_na(.,list(Feature = "others")) # trim out leading text from taxonomy string
  
  Taxon_num <- length(unique(data$Taxon)) - 1
  
  p <- ggplot(data = data, aes(x=SampleID, y=Feature, fill=NormAbundance)) +
    geom_tile() +
    facet_grid(~`Species`, scales="free_x") +
    theme_q2r() +
    theme(axis.text.x=element_text(angle=90, hjust=1,size = 4,face = "bold")) + 
    labs(title = paste0("Top ", topn," (",Taxon_num," unique taxon)", " Abundance Heatmap"), y = "Taxonomy") +
    scale_fill_viridis_c(name="log10(% Abundance)") 
  p
  ggsave(plot = p,filename = paste0("../results/4.Diversity_ana/top",topn,"_features_heatmap.pdf"), height=4, width=11, device="pdf") # save a PDF 3 inches by 4 inches
}
plot_percent_heatmap_taxon(topn = 10)
plot_percent_heatmap_taxon(topn = 50)

# ============ stackbarplot 
colors = brewer.pal(11,"Paired")

plot_stack_barplot <- function(SVs = relative.feature.table, subgroup = FALSE,topn = 10){ 
  
  SVsToPlot <- data.frame(MeanAbundance=rowMeans(SVs)) %>% #find the average abundance of a SV
    rownames_to_column("Feature.ID") %>%
    arrange(desc(MeanAbundance)) %>%
    top_n(topn, MeanAbundance) %>%
    pull(Feature.ID) #extract only the names from the table
  
  data <- SVs %>% as.data.frame() %>%
    rownames_to_column("Feature.ID") %>%
    gather(-Feature.ID, key="SampleID", value="Abundance") %>%
    mutate(Feature.ID=if_else(Feature.ID %in% SVsToPlot,  Feature.ID, "Remainder")) %>% #flag features to be collapsed
    group_by(SampleID, Feature.ID) %>%
    summarize(Abundance=sum(Abundance))%>%
    left_join(metadata) %>%
    mutate(NormAbundance=log10(Abundance+0.01)) %>% # do a log10 transformation after adding a 0.01% pseudocount. Could also add 1 read before transformation to percent
    left_join(taxonomy) %>%
    mutate(Feature=gsub("[dpcofgs]__", "", Taxon)) %>% 
    replace_na(.,list(Feature = "others")) # trim out leading text from taxonomy string
  
  if (!subgroup){
    p=ggplot(data, aes(x = SampleID, y = Abundance , fill = Feature)) +
      geom_bar(stat = "identity",
               position = "fill",
               width = 0.7) +
      scale_y_continuous(labels = scales::percent) +
      #facet_grid(~ group, scales = "free_x", switch = "x") +
      theme(strip.background = element_blank()) +
      theme(axis.ticks.x = element_blank(), axis.text.x = element_blank()) +
      xlab("Samples") + ylab("Percentage (%)") +
      theme_classic() + theme(axis.text.x = element_text(
        angle = 90,
        vjust = 1,
        hjust = 1,
        size = 5
      )) +
      theme(text = element_text(family = "sans", size = 10)) +
      scale_fill_manual(values = colors)
    #scale_fill_brewer(palette="Set3")
  }else{
    p=ggplot(data, aes(x = SampleID, y = Abundance , fill = Feature)) +
      geom_bar(stat = "identity",
               position = "fill",
               width = 0.7) +
      scale_y_continuous(labels = scales::percent) +
      facet_grid(~ Species, scales = "free_x", switch = "x") +
      theme(strip.background = element_blank()) +
      theme(axis.ticks.x = element_blank(), axis.text.x = element_blank()) +
      xlab("Samples") + ylab("Percentage (%)") + labs(fill = "Taxonomy") +
      theme_classic() + theme(axis.text.x = element_text(
        angle = 90,
        vjust = 1,
        hjust = 1,
        size = 4
      )) +
      theme(text = element_text(family = "sans", size = 10)) +
      scale_fill_manual(values = colors)
  }
  ggsave(plot = p,filename = "../results/4.Diversity_ana/top10_features_taxonomy.pdf", height=4, width=11, device="pdf") # save a PDF 3 inches by 4 inches
  return(p)
}

plot_stack_barplot(SVs= relative.feature.table)

plot_stack_barplot(SVs= relative.feature.table, subgroup = T)



