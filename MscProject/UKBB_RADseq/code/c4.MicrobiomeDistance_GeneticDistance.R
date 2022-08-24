require(tidyverse)
require(cultevo)
require(qiime2R)
require(plinkFile)
require(ggpubr)
require(ggthemes)

GeneticDistance2 <- read.table("../results/d.population/distance/plink.mdist",nrows = 197,col.names = seq(1,197,1),fill = T)
id <- read.table("../../UKBB_RADseq/results/d.population/distance/plink.mdist.id") %>%  mutate(sample_name =  str_extract(V1,"(?<=PG_)(.*)(?=_1.sorted?)"))
colnames(GeneticDistance2) <- id$sample_name 
row.names(GeneticDistance2) <- id$sample_name

GeneticDistance2 %>% rownames_to_column("SampleID") %>% write_csv('../../UKBB_Microbiomes/data/distance matrix/genetic_distance.csv')


# ==== extract the sample 



reshape_distance_matrix <- function(d = FinalBcDistance){
  library(reshape)
  
  m <- as.matrix(d)
  
  m2 <- melt(m)[melt(lower.tri(m))$value,]
  str(m2)
  names(m2) <- c("c1", "c2", "distance") 
  m2 <- m2 %>% mutate(c1 = as.character(c1),c2 = as.character(c2))
  metadata <- read.csv("../code/sample-metadata.tsv",sep ="\t") 
  metadata1 <- metadata %>% dplyr::select(sample_name,Species,Interaction) 
  str(metadata1)
  
  m3 <- left_join(m2,metadata1,by =c("c1"="sample_name"))%>% left_join(metadata1,by =c("c2"="sample_name") ) %>%
    mutate(Species_status = ifelse(Species.x == Species.y, "Within-HostSpecies","Between-HostSpecies"),
           Population_status = ifelse(Interaction.x == Interaction.y, "Within-population","Between-population")) 
  
  for (i in seq(nrow(m3))){
    if (m3[i,"Species.x"] == "B.terrestris" && m3[i,"Species_status"] == "Within-HostSpecies" ){
      m3[i,"Status"] = "Within-B.terrestris"
    }else if (m3[i,"Species.x"] == "B.ruderatus" && m3[i,"Species_status"] == "Within-HostSpecies" ){
      m3[i,"Status"] = "Within-B.ruderatus"
    }else if (m3[i,"Species.x"] == "B.hortorum" && m3[i,"Species_status"] == "Within-HostSpecies" ){
      m3[i,"Status"] = "Within-B.hortorum"
    }else{
      m3[i,"Status"] = "others"
    }
  }
  
  return (m3)
}



function_for_distance <- function(GeneticD = GeneticDistance2, MicrobialD = MicrobialDistance2, idx_of_sample, YLABS = "Bray-Curtis Dissimilarity",filter1 = "Between"){
  
  GeneticDistance <- GeneticD
  MicrobialDistance <- MicrobialD
  
  idx <- row.names(GeneticDistance) %in% idx_of_sample
  
  FinalGeneticDistance <- GeneticDistance[idx,idx]
  sampleInRAD <- row.names(FinalGeneticDistance)
  idx2 <- row.names(MicrobialDistance) %in% sampleInRAD
  
  FinalBcDistance <- MicrobialDistance[idx2,idx2]
  
  
  
  
  Bc_point <- reshape_distance_matrix(d = FinalBcDistance) %>% mutate(c1 = as.numeric(c1),c2 = as.numeric(c2)) %>%
    mutate(Pairs = ifelse(c1 > c2, paste0(c1,"To",c2), paste0(c2,"To",c1)), Label = paste0(Species.x,"-vs-",Species.y) ) %>% 
    dplyr::rename(`MicrobialDistance` = distance)
  
  Genetic_point <- reshape_distance_matrix(d = FinalGeneticDistance) %>% mutate(c1 = as.numeric(c1),c2 = as.numeric(c2)) %>%
    mutate(Pairs = ifelse(c1 > c2, paste0(c1,"To",c2), paste0(c2,"To",c1)), Label = paste0(Species.x,"-vs-",Species.y)) %>% 
    dplyr::rename(`GeneticDistance` = distance)
  
  #Genetic_point %>% filter(Pairs == "93To89")
  #Bc_point  %>% filter(Pairs == "93To89")
  
  final_point <- left_join(Bc_point, Genetic_point, by = c("Pairs")) %>% dplyr::select(-c1.y,-c2.y)
  
  
  final_point[final_point$Label.x == "B.hortorum-vs-B.terrestris","Label.x"] = "B.terrestris-vs-B.hortorum"
  final_point[final_point$Label.x == "B.ruderatus-vs-B.hortorum","Label.x"] = "B.hortorum-vs-B.ruderatus"
  final_point[final_point$Label.x == "B.ruderatus-vs-B.terrestris","Label.x"] = "B.terrestris-vs-B.ruderatus"
  
  
  # ========== reorder 
  
  FinalBcDistance <- FinalBcDistance[order(as.numeric(row.names(FinalBcDistance))),order(as.numeric(row.names(FinalBcDistance)))]
  # remove colnames and rownames
  #colnames(FinalBcDistance) <-seq(1,79,1)
  row.names(FinalBcDistance) <-NULL
  
  
  FinalGeneticDistance <- FinalGeneticDistance[order(as.numeric(row.names(FinalGeneticDistance))),order(as.numeric(row.names(FinalGeneticDistance)))]
  #colnames(FinalGeneticDistance) <- seq(1,79,1)
  row.names(FinalGeneticDistance) <-NULL
  
  
  # =========== mental test 
  require(ade4)
  mental_result = ade4::mantel.rtest(as.dist(FinalBcDistance),as.dist(FinalGeneticDistance),nrepet = 999)
  

  
  Ylabs = YLABS
  
  if (filter1 == "Between"){
    final_point <-  final_point 
    p = ggplot(final_point,aes(x=GeneticDistance,y=MicrobialDistance)) + 
      geom_point(aes(color = Label.x), size = 2) + 
      geom_smooth(data = final_point,aes(x=GeneticDistance,y=MicrobialDistance),method = "lm",formula = y~x, se = T) +
      scale_color_colorblind()+
      #stat_cor(data = final_point, method = "pearson",label.sep = "\n",label.y.npc = 0.2,label.x.npc = 0.5,) + 
      theme_clean()  + theme(legend.position = "top") +
      labs(y = Ylabs, color = "Comparison" )
    p
  }else if (filter1 == "Within"){
    final_point  <- final_point
    p = ggplot(final_point,aes(x=GeneticDistance,y=MicrobialDistance)) + 
      geom_point(aes(color = Species_status.x),size = 2) + 
      geom_smooth(method = "lm",formula = y~x, se = T) +
      scale_color_manual(values = c("black","grey"))+
      #stat_cor(data = final_point, method = "pearson",label.sep = " ",label.y.npc = 0.2,label.x.npc = 0.5,) + 
      theme_clean() + theme(legend.position = "top") +
      labs(y = Ylabs, color = "Comparison" )
    p
  }else if ( filter1 == "WithinSpecies" ){
    final_point  <- final_point %>% filter( Status.x != "others")
    p = ggplot(final_point,aes(x=GeneticDistance,y=MicrobialDistance,color = Status.x)) + 
      geom_point(aes(color = Status.x),size = 2) + 
      geom_smooth(inherit.aes = T,method = "lm",formula = y~x, se = F) +
      scale_color_manual(values = c("navy","firebrick","gold3"))+
      #stat_cor(data = final_point, method = "pearson",label.sep = " ",label.y.npc = 0.1,label.x.npc = 0.65,p.digits = 3) + 
      theme_clean() + theme(legend.position = "top") +
      labs(y = Ylabs, color = "Comparison" )
    p
    
  }else{
    p = ggplot(final_point,aes(x=GeneticDistance,y=MicrobialDistance)) + 
      geom_point(aes(color = Species_status.x), size = 2) + 
      geom_smooth(data = final_point,aes(x=GeneticDistance,y=MicrobialDistance),method = "lm",formula = y~x, se = T) +
      scale_color_manual(values = c("black","grey"))+
      #stat_cor(data = final_point, method = "pearson",label.sep = "\n",label.y.npc = 0.2,label.x.npc = 0.5,) + 
      theme_clean()  + theme(legend.position = "top") +
      labs(y = Ylabs, color = "Comparison" )
    p
  }
  
  return(list(picture = p, table = final_point, mental_p = mental_result$pvalue, mental_r = mental_result$obs))
}




# =============== WEIGHTED UNIFRAC
MicrobialDistance2 <- read_qza("../../UKBB_Microbiomes/results/4.Diversity_ana/core-metrics-results/weighted_unifrac_distance_matrix.qza")$data
MicrobialDistance2 <- as.matrix(MicrobialDistance2)

sampleINmicrobiome <- row.names(MicrobialDistance2)

table <- function_for_distance(idx_of_sample = sampleINmicrobiome)$table
p <- function_for_distance(idx_of_sample = sampleINmicrobiome, YLABS = "Weighted Unifrac Distance",filter1 = "ALL")$picture


function_for_distance(idx_of_sample = sampleINmicrobiome, YLABS = "Weighted Unifrac Distance",filter1 = "WithinSpecies")$picture

ggsave(p,filename = "../../UKBB_Microbiomes/results/7.Final_graph/GeneticDistance_WeiUnifrac_all_MicrobialDistance.png")

sampleInRodTerr <- metadata %>% filter(Species != "B.hortorum") %>% pull("sample_name")

p <-function_for_distance(idx_of_sample = sampleInRodTerr, YLABS = "Weighted Unifrac Distance")$picture

ggsave(p,filename = "../../UKBB_Microbiomes/results/7.Final_graph/GeneticDistance_WeiuUniFrac_RodTerr_MicrobialDistance.png")



# ===== bc
metadata <- read.csv("../code/sample-metadata.tsv",sep ="\t")

MicrobialDistance2 <- read_qza("../../UKBB_Microbiomes/results/4.Diversity_ana/core-metrics-results/bray_curtis_distance_matrix.qza")$data
MicrobialDistance2 <- as.matrix(MicrobialDistance2 )

MicrobialDistance2 %>% as.data.frame() %>% rownames_to_column('SampleID') %>% write_csv("../../UKBB_Microbiomes/data/distance matrix/B_C_microbial_distance.csv") 

sampleINmicrobiome <- row.names(MicrobialDistance2)

table <- function_for_distance(idx_of_sample = sampleINmicrobiome)$table
#p <- function_for_distance(idx_of_sample = sampleINmicrobiome,filter1 = "ALL")$picture
#ggsave(p,filename = "../../UKBB_Microbiomes/results/7.Final_graph/GeneticDistance_BC_All_MicrobialDistance.png",dpi = "print")

p <- function_for_distance(idx_of_sample = sampleINmicrobiome,filter1 = "Within")$picture
ggsave(p,filename = "../../UKBB_Microbiomes/results/7.Final_graph/GeneticDistance_BC_label_MicrobialDistance.png",dpi = "print",scale = 0.7,height = 6)

ggsave(p,filename = "../../UKBB_Microbiomes/results/7.Final_graph/GeneticDistance_BC_all_MicrobialDistance.png")
# ====

table <- function_for_distance(idx_of_sample = sampleINmicrobiome,filter1 = "WithinSpecies")$table

kruskal.test(table$GeneticDistance,table$Status.x)

one.way <- aov(GeneticDistance ~ Status.x, data = table)

summary(one.way)

TukeyHSD(one.way)


p <- function_for_distance(idx_of_sample = sampleINmicrobiome,filter1 = "WithinSpecies")$picture
ggsave(p,filename = "../../UKBB_Microbiomes/results/7.Final_graph/GeneticDistance_BC_withinSpecies_MicrobialDistance.png",dpi = "print",scale = 0.7,height = 6)

function_for_distance(idx_of_sample = sampleINmicrobiome,filter1 = "All")$mental_p
function_for_distance(idx_of_sample = sampleINmicrobiome,filter1 = "WithinSpecies")$mental_r


# =====


sampleInRodTerr <- metadata %>% filter(Species != "B.hortorum") %>% pull("sample_name")

p <-function_for_distance(idx_of_sample = sampleInRodTerr)$picture

ggsave(p,filename = "../../UKBB_Microbiomes/results/7.Final_graph/GeneticDistance_BC_RodTerr_MicrobialDistance.png")





# limit the sample to one species 



sampleInTerrestris <- metadata %>% filter(Species == "B.terrestris") %>% pull("SampleID")

function_for_distance(idx_of_sample = sampleInTerrestris,filter1 = "Within")

sampleInHor <- metadata %>% filter(Species == "B.hortorum") %>% pull("SampleID")

function_for_distance(idx_of_sample = sampleInHor,filter1 = "Between")

sampleInHor <- metadata %>% filter(Species == "B.hortorum") %>% pull("SampleID")

function_for_distance(idx_of_sample = sampleInHor,filter1 = "Within")



sampleInRoderatus <-  metadata %>% filter(Species == "B.ruderatus") %>% pull("SampleID")

function_for_distance(idx_of_sample = sampleInRoderatus,filter1 = "Within")



# ===================

sampleInHorRod <-  metadata %>% filter(Species != "B.terrestris") %>% pull("SampleID")

function_for_distance(idx_of_sample = sampleInHorRod,filter1 = "Between")

sampleInHorTerr <- metadata %>% filter(Species != "B.ruderatus") %>% pull("sample_name")

function_for_distance(idx_of_sample = sampleInHorTerr)




# 



# ============ Mantel test between distance matrix 



# ==== Crithidia Parasite Load

require("vegan")


output_parasite_distance <- function(parasite = "Crithidia_total_per_bee"){
  metadata <- read.csv("../code/sample-metadata.tsv",sep ="\t")
  
  if (parasite == "Nosema_total_per_bee"){
    metadata <-metadata %>% dplyr::select(!"Crithidia_total_per_bee") %>% dplyr::rename(Crithidia_total_per_bee = Nosema_total_per_bee)
  }else if (parasite == "Apicystis_total_per_bee") {
    metadata <-metadata %>% dplyr::select(!"Crithidia_total_per_bee") %>% dplyr::rename(Crithidia_total_per_bee = Apicystis_total_per_bee)
  }
  
  dist1 = metadata[-91,] %>% dplyr::select(sample_name,Crithidia_total_per_bee) %>% 
    filter(sample_name %in% sampleINmicrobiome,
           Crithidia_total_per_bee != 0) %>% 
    mutate(Crithidia_total_per_bee = log10(Crithidia_total_per_bee))%>%
    column_to_rownames("sample_name") 
  
  dist.crithidia = as.matrix(dist(dist1))
  dist.crithidia <- dist.crithidia[order(as.numeric(row.names(dist.crithidia))),order(as.numeric(row.names(dist.crithidia)))]
  sampleINCrithidia <- row.names(dist.crithidia)
  dist.crithidia <- as.dist(dist.crithidia)
  
  
  idx3 <- row.names(MicrobialDistance2) %in% sampleINCrithidia 
  MicrobialDistance <-MicrobialDistance2[idx3,idx3]
  MicrobialDistance <- MicrobialDistance[order(as.numeric(row.names(MicrobialDistance))),order(as.numeric(row.names(MicrobialDistance)))]
  MicrobialDistance <- as.dist(MicrobialDistance)
  
  return(list(Microbial = MicrobialDistance , Crithidia = dist.crithidia))
}

dist.Crithidia = output_parasite_distance()$Crithidia
dist.Crithidia.Micro = output_parasite_distance()$Microbial

ade4::mantel.rtest(dist.Crithidia,dist.Crithidia.Micro,nrepet = 999)

dist.Nosema = output_parasite_distance(parasite = "Nosema_total_per_bee")$Crithidia
dist.Nosema.Micro = output_parasite_distance(parasite = "Nosema_total_per_bee")$Microbial

ade4::mantel.rtest(dist.Nosema,dist.Nosema.Micro,nrepet = 999)

dist.Apicystis = output_parasite_distance(parasite = "Apicystis_total_per_bee")$Crithidia
dist.Apicystis.Micro = output_parasite_distance(parasite = "Apicystis_total_per_bee")$Microbial

ade4::mantel.rtest(dist.Apicystis,dist.Apicystis.Micro,nrepet = 999)



# filter some of the SNPs


output_parasite_genetic_distance <- function(parasite = "Crithidia_total_per_bee"){
  
  
  sampleInGenetics <- row.names(GeneticDistance2)
  
  metadata <-  read.csv("../../UKBB_Microbiomes//code/UKBB_NED_filtered.csv") %>% dplyr::rename(sample_name =`Bee_ID` ,
                                                                                                Species = `finalised_species`,
                                                                                                CollectionSite = `Site`) %>% filter(sample_name %in% sampleInGenetics  )
  
  if (parasite == "Nosema_total_per_bee"){
    metadata <-metadata %>% dplyr::select(!"Crithidia_total_per_bee") %>% dplyr::rename(Crithidia_total_per_bee = Nosema_total_per_bee)
  }else if (parasite == "Apicystis_total_per_bee") {
    metadata <-metadata %>% dplyr::select(!"Crithidia_total_per_bee") %>% dplyr::rename(Crithidia_total_per_bee = Apicystis_total_per_bee)
  }
  
  dist1 = metadata %>% dplyr::select(sample_name,Crithidia_total_per_bee) %>% 
    filter(Crithidia_total_per_bee != 0) %>% 
    mutate(Crithidia_total_per_bee = log10(Crithidia_total_per_bee))%>%
    column_to_rownames("sample_name") 
  
  dist.crithidia = as.matrix(dist(dist1,method = "euclidean"))
  dist.crithidia <- dist.crithidia[order(as.numeric(row.names(dist.crithidia))),order(as.numeric(row.names(dist.crithidia)))]
  sampleINCrithidia <- row.names(dist.crithidia)
  dist.crithidia <- as.dist(dist.crithidia)
  print (length(sampleINCrithidia))
  
  
  idx3 <- row.names(GeneticDistance2) %in% sampleINCrithidia 
  MicrobialDistance <-GeneticDistance2[idx3,idx3]
  MicrobialDistance <- MicrobialDistance[order(as.numeric(row.names(MicrobialDistance))),order(as.numeric(row.names(MicrobialDistance)))]
  MicrobialDistance <- as.dist(MicrobialDistance)
  
  return(list(Genetic = MicrobialDistance , Crithidia = dist.crithidia))
}

dist.Crithidia = output_parasite_genetic_distance()$Crithidia
dist.Crithidia.Genetic = output_parasite_genetic_distance()$Genetic

ade4::mantel.rtest(dist.Crithidia,dist.Crithidia.Genetic,nrepet = 999)

dist.Nosema = output_parasite_genetic_distance(parasite = "Nosema_total_per_bee")$Crithidia
dist.Nosema.Genetic = output_parasite_genetic_distance(parasite = "Nosema_total_per_bee")$Genetic

ade4::mantel.rtest(dist.Nosema,dist.Nosema.Genetic,nrepet = 999)

dist.Apicystis = output_parasite_genetic_distance(parasite = "Apicystis_total_per_bee")$Crithidia
dist.Apicystis.Genetic = output_parasite_genetic_distance(parasite = "Apicystis_total_per_bee")$Genetic

ade4::mantel.rtest(dist.Apicystis,dist.Apicystis.Genetic,nrepet = 999)



# ========================== dendrogram 




metadata <- read.csv("../code/metadata_Microbiome.csv") %>% mutate(SampleID=as.character(SampleID))

idx <- row.names(GeneticDistance2) %in% sampleINmicrobiome

GeneticDistance84 <- GeneticDistance2[idx,idx]

plot_dendrogram <- function(dist_object =  as.dist(GeneticDistance84)){
  library("ape")
  upgma <- hclust(dist_object)
  
  # label the dendrogram with 
  cluster <- as.data.frame(as.matrix(dist_object)) %>% rownames_to_column("SampleID") %>% left_join(metadata,by= "SampleID")%>%
    dplyr:: select("SampleID","Enterotype","Species","Crithidia_total_per_bee","CollectionSite")
  
  x = factor(cluster$Enterotype)
  y = factor(cluster$Species)
  
  colors2 = c("black","yellow","green")
  test_setname2 <- setNames(as.numeric(x),cluster$SampleID)
  
  colors = c("navy","firebrick","gold3")
  test_setname <- setNames(as.numeric(y),cluster$SampleID)
  
  plot(as.phylo(upgma),cex = 0.8,type = "fan",tip.color = colors[test_setname],label.offset = 0.01,edge.color = "steelblue",show.node.label = T,edge.lty = 1)
  graphics::legend("left",legend = levels(y),fill = colors,border = T,bty = "0",box.lwd = "white")
}


plot_dendrogram()

pdf("../results/7.Final_graph/dendrogram_unwei_unifrac.pdf", width = 10)
plot_dendrogram(dist_object = unwunifra$data)

dev.off()


# ==================== Try ggtree


if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("ggtree")

library("ggtree")


tree = ape::as.phylo(upgma)


 p <- ggtree(tree,layout = "fan",color = "steelblue") %<+% cluster
  
   
   
p2 <-  p +  geom_tiplab(size = 4,linesize=.5,offset = 0.051) +  
  geom_cladelabel(node=83, label="B.hortorum", color="navy", offset=.25, align=TRUE) + 
  geom_cladelabel(node=84, label="B.ruderatus", 
                  color="firebrick", offset=.25, align=TRUE) +  
  geom_cladelabel(node=81, label="B.terrestris", 
                  color="gold3", offset=.3, align=TRUE) + geom_tippoint(aes(color = Enterotype,size = Crithidia_total_per_bee,shape = CollectionSite)) + 
   scale_color_manual(values = c("yellow2","purple","red2")) + scale_shape_manual(values = c(15,16,17,18))


ggsave(p2, filename = "../../UKBB_Microbiomes/results/7.Final_graph/dendrogram_genetic_distance.png",width = 12, height =8)
  

p2 <-  p +  
  geom_cladelabel(node=83, label="B.hortorum", color="navy", offset=.35, align=TRUE) + 
  geom_cladelabel(node=84, label="B.ruderatus", 
                  color="firebrick", offset=.35, align=TRUE) +  
  geom_cladelabel(node=81, label="B.terrestris", 
                  color="gold3", offset=.4, align=TRUE) + geom_tippoint(aes(color = CollectionSite), size =2) + 
  scale_color_canva()

ggsave(p2, filename = "../../UKBB_Microbiomes/results/7.Final_graph/dendrogram_genetic_distance_withoutEnterotype.png",width = 12, height =8,scale = 0.6)


p2 <-  p +  geom_tiplab(size = 4,linesize=.5,offset = 0.051) +  
  geom_cladelabel(node=83, label="B.hortorum", color="navy", offset=.25, align=TRUE) + 
  geom_cladelabel(node=84, label="B.ruderatus", 
                  color="firebrick", offset=.25, align=TRUE) +  
  geom_cladelabel(node=81, label="B.terrestris", 
                  color="gold3", offset=.3, align=TRUE) + geom_tippoint(aes(color = Enterotype,shape = CollectionSite),size =3) + 
  scale_color_manual(values = c("yellow2","purple","red2")) + scale_shape_manual(values = c(15,16,17,18))

ggsave(p2, filename = "../../UKBB_Microbiomes/results/7.Final_graph/dendrogram_genetic_distance_without_parasite.png",width = 12, height =8)












