
# turtle
setwd("~/PopGen/Imperial_College/GenomicsBioinformatics/genomics_and_bioinformatics/Practicals/Practicals2021/Genomics_Bionformatics_Practicals_2021/")


data2 <- as.matrix(read.csv("./turtle.csv", stringsAsFactors=F, header=F, colClasses=rep("numeric", len)))
dim(data2)
## 1) population subdivision

## split file into populations
popA<-data2[1:20,]
popB<-data2[21:40,]
popC<-data2[41:60,]
popD<-data2[61:80,]

#First we calculate the FST for just one SNP. The first polymorphic position in both populations 1 and 2.
first_snp_pop1 <- pop1[,3]
first_snp_pop2 <- pop2[,3]
fA1<-sum(first_snp_pop1)/length(first_snp_pop1)
fA2<-sum(first_snp_pop2)/length(first_snp_pop2)
HT <- 2 * ( (fA1 + fA2) / 2 ) * (1 - ((fA1 + fA2) / 2) )
HS <- fA1 * (1 - fA1) + fA2 * (1 - fA2) 
FST_first_snp_AB<- (HT - HS) / HT

#OptionA to caclulate the FST
FST_AB<-c()
for (i in 1:ncol(data2)) {
  nth_snp_pop1 <- pop1[,i]
  nth_snp_pop2 <- pop2[,i]
  fA1<-sum(nth_snp_pop1)/length(nth_snp_pop1)
  fA2<-sum(nth_snp_pop2)/length(nth_snp_pop2)
  HT <- 2 * ( (fA1 + fA2) / 2 ) * (1 - ((fA1 + fA2) / 2) )
  HS <- fA1 * (1 - fA1) + fA2 * (1 - fA2) 
  FST_nth_snp<- (HT - HS) / HT
  FST_AB<-c(FST_nth_snp,FST_AB)
}
#This is the FST between populations A and B of all snps
FST_AB
#This is the mean of FST across snps
mean(FST_AB,na.rm=TRUE)

##Option B to calculate the FST. Conceptually is the same, there are just small changes in the code (i.e. It's not another estimator of FST ...)
fA1 <- as.numeric(apply(X=popA,MAR=2,FUN=sum)/nrow(popA))
fA2 <- as.numeric(apply(X=popB,MAR=2,FUN=sum)/nrow(popB))
FST <- rep(NA, length(fA1))
for (i in 1:length(FST)) {
  HT <- 2 * ( (fA1[i] + fA2[i]) / 2 ) * (1 - ((fA1[i] + fA2[i]) / 2) )
  HS <- fA1[i] * (1 - fA1[i]) + fA2[i] * (1 - fA2[i]) 
  FST[i] <- (HT - HS) / HT
}

#This is the FST of all snps
FST_AB
#This is the mean of FST across snps
mean(FST_AB,na.rm=TRUE)



###We can define a function that calculates the FST. In this case using option B we have just seen
calcFST <- function(pop1, pop2) {
  
  # only for equal sample sizes!
  
  fA1 <- as.numeric(apply(X=pop1,MAR=2,FUN=sum)/nrow(pop1))
  fA2 <- as.numeric(apply(X=pop2,MAR=2,FUN=sum)/nrow(pop2))
  
  FST <- rep(NA, length(fA1))
  
  for (i in 1:length(FST)) {
    
    HT <- 2 * ( (fA1[i] + fA2[i]) / 2 ) * (1 - ((fA1[i] + fA2[i]) / 2) )
    HS <- fA1[i] * (1 - fA1[i]) + fA2[i] * (1 - fA2[i]) 
    
    FST[i] <- (HT - HS) / HT
    
  }
  return(FST)
}

####Here we just subset the snps with a frequency higher than 0.05. 
### We store the indices of the snps (3,7,16...)  in the vector "snps"
### In that way we can subset these positions from data 2
### This is a normal step in population genetics to assess for the population structure 
### without paying to much attention on private mutations or singletons carried by just one individual
### It is also used to avoid possible genotyping errors.
snps <- which(apply(FUN=sum, X=data2, MAR=2)/(nrow(data2))>0.05)

cat("\nFST value (average):",
    "\nA vs B", mean(calcFST(data2[1:20,snps], data2[21:40,snps]), na.rm=T),
    "\nA vs C", mean(calcFST(data2[1:20,snps], data2[41:60,snps]), na.rm=T),
    "\nA vs D", mean(calcFST(data2[1:20,snps], data2[61:80,snps]), na.rm=T),
    "\nB vs C", mean(calcFST(data2[21:40,snps], data2[41:60,snps]), na.rm=T),
    "\nB vs D", mean(calcFST(data2[21:40,snps], data2[61:80,snps]), na.rm=T),
    "\nC vs D", mean(calcFST(data2[41:60,snps], data2[61:80,snps]), na.rm=T),"\n")

### these values indicate a certain degree of population subdivision

###To say if there is isolation by distance we need to test if there is significant 
### correlation between genetic distance (FST) and geographical distance(in km).
### To do that we define a matrix for the genetic distances (FST) and a matrix for the geographical distances
geo_distance <- c(5,10,12,50)
geo_distances_matrix<-matrix(nrow=length(geo_distance),ncol=length(geo_distance))
colnames(geo_distances_matrix)<-c("A","B","C","D")
rownames(geo_distances_matrix)<-c("A","B","C","D")

FST_matrix<-matrix(nrow=length(geo_distance),ncol=length(geo_distance))
colnames(FST_matrix)<-c("A","B","C","D")
rownames(FST_matrix)<-c("A","B","C","D")
#They are empty matrices
geo_distances_matrix
FST_matrix
##We fill them iterating rows(i) for population 1 and columns(j) for population 2
##We extract the values from data2
for (i in 1:length(geo_distance)) {
  for (j in 1:length(geo_distance)) {
    geo_distances_matrix[i,j]<-abs(geo_distance[i]-geo_distance[j])
    pop1_indices<-c((((i-1)*20)+1):(20*i)) # this is just to get the indices of population 1 in function of i.  For population A I have c(1,20), for B c(21,40), etc. 
    pop2_indices<-c((((j-1)*20)+1):(20*j))
    FST_matrix[i,j]<-mean(calcFST(data2[pop1_indices,snps], data2[pop2_indices,snps]), na.rm=T)
  }
}
geo_distances_matrix
FST_matrix

## Now I just want to test if the correlation is significant. To do it, I can do a mantel test.
## I use mantel function of vegan package. But similar functions are found in other packages.

library(vegan)
mantel(geo_distances_matrix,FST_matrix)
## The correlation has a significance (p-value) of 0.45, above the threshold of 0.05.
## There is no statistical support to say there is correlation
## We can say that there is no evidence of isolation by distance

##############################
##We can also evaluate qualitatively if there is isolation by distance
##Both in PCA and the trees we get from the following code show a poor clustering 
##of individuals regarding their geographical location (A,B,C or D).
## This indicates it is not likely we have isolation by distance.
## Instead, it seems that there could be admixture. At least between B,C and D populations


###PCA and trees


### read data
len <- 2000
data <- as.matrix(read.csv("./turtle.genotypes.csv", stringsAsFactors=F, header=F, colClasses=rep("numeric", len)))
dim(data)
data[,6]

### assign an name for each location
locations <- rep(c("A","B","C","D"), each=10)




### to test whether there is population subdivision we can do several things

### for instance, we can build a tree of all samples and check whether we observe some cluster
### we can do this by first building a distance matrix and then a tree

distance <- dist(data)

tree <- hclust(distance)

plot(tree, labels=locations)

### or we can do a PCA
### we can filter our low-frequency variants first
colors <- rep(c("#ef6461","#e4b363","#5F0F40","#0eb1d2"), each=10)
points <- rep(c(15:18), each=10)

index <- which(apply(FUN=sum, X=data, MAR=2)/(nrow(data)*2)>0.05)

pca <- prcomp(data[,index], center=T, scale=T)

summary(pca)

plot(pca$x[,1], pca$x[,2], col=colors, pch=points)
legend("bottomleft", legend=sort(unique(locations)), col=unique(colors), pch=unique(points))

plot(pca$x[,2], pca$x[,3], col=colors, pch=points)
legend("topleft", legend=sort(unique(locations)), col=unique(colors), pch=unique(points))




































