
# brown bears

## 1) identify which positions are SNPs

### read data
data <- read.csv("./data/bears.csv", stringsAsFactors=F, header=F, colClasses=rep("character", 10000)) # colClasses 是设置每一列为character
dim(data)
data[,5]
data[1,(c(1:100))]



### SNPs are positions where you observed more than one allele
### the easiest thing is to loop over all sites and record the ones with two alleles

# Q1:identify which positions are SNPs (polymorphic, meaning that they have more than one allele)

# SNP本质上就是同一列中出现不同的字母，那我们这边通过unique加length就能算出一列中的字母有多少了

#我自己写的很复杂
find_snp <- function(i){
  if (length(unique(data[,i])) >= 2){
    return (i)
  }else{
    return ("FALSE")
  }
}
class(find_snp(262))
RESULT <- c()
for (i in seq(ncol(data))){
  if (is.numeric(find_snp(i))){
    RESULT <- c(RESULT,find_snp(i))
  }else{
    next
  }
}

#直接使用for loop
snps <- c()
for (i in 1:ncol(data)) {
	if (length(unique(data[,i]))==2){
	  snps <- c(snps, i)
	}
}
#使用apply解决
### this works to retain the indexes of SNPs; a smartest way would not involve doing a loop but using `apply` functions
cat("\nNumber of SNPs is", length(snps))

snps2 <- unlist(sapply(seq(ncol(data)),function(i) {if (length(unique(data[,i])) >= 2){return (i)} }))


### reduce the data set
data <- data[,snps]
dim(data)


## 2)  calculate, print and visualize allele frequencies for each SNP

输出等位基因：unique()



### alleles in this SNP
alleles <- unique(data[,1])
cat("\nSNP", "with alleles", alleles)

## frequencies of the alleles
freq_a1<-length(which(data[,1]==alleles[1]))/nrow(data)
freq_a2<-length(which(data[,1]==alleles[2]))/nrow(data)

### the minor allele is the one in lowest frequency
minor_allele<-alleles[which.min(c(freq_a1,freq_a2))] # which.min()可以用来输出最小值的位置

freq_minor_allele<-c(freq_a1,freq_a2)[which.min(c(freq_a1,freq_a2))] # 输出最小值

cat(" the minor allele is",minor_allele ,"and the minor allele frequency (MAF) is", freq_minor_allele)



### again we can loop over each SNP and easily calculate allele frequencies
frequencies <- c()
for (i in 1:ncol(data)) {

        ### alleles in this SNP
        alleles <- sort(unique(data[,i]))
        cat("\nSNP", i, "with alleles", alleles)
        
        ## frequencies of the alleles
        freq_a1<-length(which(data[,i]==alleles[1]))/nrow(data)
        freq_a2<-length(which(data[,i]==alleles[2]))/nrow(data)
        
        ### the minor allele is the one in lowest frequency
        minor_allele<-alleles[which.min(c(freq_a1,freq_a2))]
        freq_minor_allele<-c(freq_a1,freq_a2)[which.min(c(freq_a1,freq_a2))]

        cat(" the minor allele is",minor_allele ,"and the minor allele frequency (MAF) is", freq_minor_allele)

        frequencies <- c(frequencies, freq_minor_allele)
}
### we can plot is as a histogram
hist(frequencies)
### or simply the frequencies at each position
plot(frequencies, type="h")


## 3) calculate and print genotype frequencies


### alleles in the first SNP
alleles <- unique(data[,1])
cat("\nSNP", i, "with alleles", alleles)

## frequencies of the alleles
freq_a1<-length(which(data[,1]==alleles[1]))/nrow(data)
freq_a2<-length(which(data[,1]==alleles[2]))/nrow(data)

### the minor allele is the one in lowest frequency
minor_allele<-alleles[which.min(c(freq_a1,freq_a2))]
freq_minor_allele<-c(freq_a1,freq_a2)[which.min(c(freq_a1,freq_a2))]

genotype_counts <- c(0, 0, 0) # 先创一个空的

nsamples <- 20
for (j in 1:nsamples) {
  ### indexes of haplotypes for individual j (haplotype indices)
  haplotype_index <- c( (j*2)-1, (j*2) ) # Each individual as two chromosomes (copies), meaning that individual 1 has data on rows 1 and 2, individual 2 has data on rows 3 and 4, and so on
  ### count the minor allele instances
  genotype <- length(which(data[haplotype_index, 1]==minor_allele)) 
  ##
  genotype_index=genotype+1
  ### increase the counter for the corresponding genotype
  genotype_counts[genotype_index] <- genotype_counts[genotype_index] + 1
}
cat(" and genotype frequencies", genotype_counts)


#所以计算SNP的时候不需要考虑染色体的数量，但是计算基因型的时候需要考虑。

### again, we can loop over each SNPs and each individual and print the genotype frequencies

# 方法1： 利用之前算出来的东西。再利用一些巧妙的位置变化。
nsamples <- nrow(data)/2
for (i in 1:ncol(data)) {

  alleles <- sort(unique(data[,i]))
  cat("\nSNP", i, "with alleles", alleles)
  
  ## frequencies of the alleles
  freq_a1<-length(which(data[,i]==alleles[1]))/nrow(data)
  freq_a2<-length(which(data[,i]==alleles[2]))/nrow(data)
  
  ### as before, as there is no "reference" allele, we calculate the frequencies of the minor allele
  ### the minor allele is the one in lowest frequency
  minor_allele<-alleles[which.min(c(freq_a1,freq_a2))]
  freq_minor_allele<-c(freq_a1,freq_a2)[which.min(c(freq_a1,freq_a2))]

  ### genotypes are major/major major/minor minor/minor
	genotype_counts <- c(0, 0, 0)

	for (j in 1:nsamples) {
	  ### indexes of haplotypes for individual j (haplotype indices)
	  haplotype_index <- c( (j*2)-1, (j*2) )
	  ### count the minor allele instances
	  genotype <- length(which(data[haplotype_index, i]==minor_allele)) # 输出长度为2时，说明两者都是minor，再加上1就是minor/minor的位置了
	  ##
	  genotype_index=genotype+1
	  ### increase the counter for the corresponding genotype
	  genotype_counts[genotype_index] <- genotype_counts[genotype_index] + 1
	}
	cat(" and genotype frequencies", genotype_counts)
}

# 方法2 使用辅助列

# 提取第一列：
alleles <- unique(data[,1])
cat("\nSNP", 1, "with alleles", alleles)

nsamples=20
result <- list()
for (j in 1:nsamples) {
  haplotype_index <- c( (j*2)-1, (j*2) )
  result[paste0("sample",j)] <- as.data.frame(sort(data[haplotype_index, 1])) # 这边的sort是点睛之笔，让AC和CA同向
}
test =as.data.frame(result)  #list 转 dataframe
test2 <- as.data.frame(t(test)) # 转置
require(tidyr)
tidyr::unite(test2,col="Genotype","V1","V2",sep="_") #合并成辅助列
result2 <- as.data.frame(table(tidyr::unite(test2,col="Genotype","V1","V2",sep="_")$Genotype)) #table计数


### 接下来整理就很容易了，这边就不写了，重复for循环就行

## 4) calculate and print homozygosity and heterozygosity

### we can reuse the previous code and easily calculate the heterozygosity
nsamples <- 20
for (i in 1:ncol(data)) {

        ### alleles in this SNPs
        alleles <- sort(unique(data[,i]))
        cat("\nSNP", i, "with alleles", alleles)
        
        ## frequencies of the alleles
        freq_a1<-length(which(data[,i]==alleles[1]))/nrow(data)
        freq_a2<-length(which(data[,i]==alleles[2]))/nrow(data)
        
        ### as before, as there is no "reference" allele, we calculate the frequencies of the minor allele
        ### the minor allele is the one in lowest frequency
        minor_allele<-alleles[which.min(c(freq_a1,freq_a2))]
        freq_minor_allele<-c(freq_a1,freq_a2)[which.min(c(freq_a1,freq_a2))]
        
        ### genotypes are major/major major/minor minor/minor
        genotype_counts <- c(0, 0, 0)

        for (j in 1:nsamples) {
          ### indexes of haplotypes for individual j (haplotype indices)
          haplotype_index <- c( (j*2)-1, (j*2) )
          ### count the minor allele instances
          genotype <- length(which(data[haplotype_index, i]==minor_allele)) 
          ##
          genotype_index=genotype+1
          ### increase the counter for the corresponding genotype
          genotype_counts[genotype_index] <- genotype_counts[genotype_index] + 1
        }
        cat(" and heterozygosity", genotype_counts[2]/nsamples)
        cat(" and homozygosity", 1-genotype_counts[2]/nsamples)
}


## 5) test for HWE, with calculating of expected genotype counts

nonHWE <- c() # to store indexes of SNPs deviating from HWE
nsamples <- 20
for (i in 1:ncol(data)) {

  
        ### alleles in this SNPs
        alleles <- sort(unique(data[,i]))
        cat("\nSNP", i, "with alleles", alleles)
        
        ## frequencies of the alleles
        freq_a1<-length(which(data[,i]==alleles[1]))/nrow(data)
        freq_a2<-length(which(data[,i]==alleles[2]))/nrow(data)
        
        ### as before, as there is no "reference" allele, we calculate the frequencies of the minor allele
        ### the minor allele is the one in lowest frequency
        minor_allele<-alleles[which.min(c(freq_a1,freq_a2))]
        ffreq_minor_allele<-c(freq_a1,freq_a2)[which.min(c(freq_a1,freq_a2))]
        
        ### from the frequency, I can calculate the expected genotype counts under HWE p^2,2pq,q^2
	      genotype_counts_expected <- c( (1-freq_minor_allele)^2, 2*freq_minor_allele*(1-freq_minor_allele), freq_minor_allele^2) * nsamples

	      ### genotypes are major/major major/minor minor/minor
	      genotype_counts <- c(0, 0, 0)

	      for (j in 1:nsamples) {
	        ### indexes of haplotypes for individual j (haplotype indices)
	        haplotype_index <- c( (j*2)-1, (j*2) )
	        ### count the minor allele instances
	        genotype <- length(which(data[haplotype_index, i]==minor_allele)) 
	        ##
	        genotype_index=genotype+1
	        ### increase the counter for the corresponding genotype
	        genotype_counts[genotype_index] <- genotype_counts[genotype_index] + 1
	      }

      	### test for HWE: calculate chi^2 statistic
	      
	      
      	chi <- sum( (genotype_counts_expected - genotype_counts)^2 / genotype_counts_expected ) #计算卡方
      
      	## pvalue
      	pv <- 1 - pchisq(chi, df=1) # 计算卡方值对应的p值。 R自带的卡方不能设置degree of freedom，所有还是需要pchisq()
      	
        cat(" with pvalue for test against HWE", pv)
      
      	## retain SNPs with pvalue<0.05
      	if (pv < 0.05) nonHWE <- c(nonHWE, i)

}




## 6) calculate, print  and visualise inbreeding coefficients for SNPs deviating from HWE

### assuming we ran the code for point 5, we already have the SNPs deviating
F <- c()
nsamples <- 20
for (i in nonHWE) {

        ### alleles in this SNPs
        alleles <- sort(unique(data[,i]))
        cat("\nSNP", i, "with alleles", alleles)
        
        ## frequencies of the alleles
        freq_a1<-length(which(data[,i]==alleles[1]))/nrow(data)
        freq_a2<-length(which(data[,i]==alleles[2]))/nrow(data)
        
        ### as before, as there is no "reference" allele, we calculate the frequencies of the minor allele
        ### the minor allele is the one in lowest frequency
        minor_allele<-alleles[which.min(c(freq_a1,freq_a2))]
        freq_minor_allele<-c(freq_a1,freq_a2)[which.min(c(freq_a1,freq_a2))]
        
        ### from the frequency, I can calculate the expected genotype counts under HWE p^2,2pq,q^2
        genotype_counts_expected <- c( (1-freq_minor_allele)^2, 2*freq_minor_allele*(1-freq_minor_allele), freq_minor_allele^2) * nsamples
        
        ### genotypes are major/major major/minor minor/minor
        genotype_counts <- c(0, 0, 0)

        for (j in 1:nsamples) {
          ### indexes of haplotypes for individual j (haplotype indices)
          haplotype_index <- c( (j*2)-1, (j*2) )
          ### count the minor allele instances
          genotype <- length(which(data[haplotype_index, i]==minor_allele)) 
          ##
          genotype_index=genotype+1
          ### increase the counter for the corresponding genotype
          genotype_counts[genotype_index] <- genotype_counts[genotype_index] + 1
        }

	### calculate inbreeding coefficient
	inbreeding <- ( 2*freq_minor_allele*(1-freq_minor_allele) - (genotype_counts[2]/nsamples) ) / ( 2*freq_minor_allele*(1-freq_minor_allele) )
	F <- c(F, inbreeding)
	cat(" with inbreeding coefficient", inbreeding)
}
### plot
hist(F)
plot(F, type="h")




