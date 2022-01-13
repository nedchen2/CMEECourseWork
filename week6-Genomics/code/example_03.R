
# killer whales

setwd("~/PopGen/Imperial_College/GenomicsBioinformatics/genomics_and_bioinformatics/Practicals/Practicals2021/Genomics_Bionformatics_Practicals_2021/")

## read data for each population
## since data is encoded as 0 and 1 it's better to store it as a matrix

len <- 50000

data_N <- as.matrix(read.csv("./killer_whale_North.csv", stringsAsFactors=F, header=F, colClasses=rep("numeric", len)))
dim(data_N)

data_S <- as.matrix(read.csv("./killer_whale_South.csv", stringsAsFactors=F, header=F, colClasses=rep("numeric", len)))
dim(data_S)


## 1) estimates of effective population size

### Tajima's estimator

n <- nrow(data_N) # nr of samples (chromosomes)
pi_N <- 0
for (i in 1:(n-1)) {
	for (j in (i+1):n) {
		pi_N <- pi_N + sum(abs(data_N[i,]-data_N[j,]))
	}
}
pi_N <- pi_N / ((n*(n-1))/2)

n <- nrow(data_S) # nr of samples (chromosomes)
pi_S <- 0
for (i in 1:(n-1)) {
        for (j in (i+1):n) {
                pi_S <- pi_S + sum(abs(data_S[i,]-data_S[j,]))
        }
}
pi_S <- pi_S / ((n*(n-1))/2)

## estimates of Ne from Tajima's estimator
Ne_N_pi <- pi_N / (4 * 1e-8 * len)
Ne_S_pi <- pi_S / (4 * 1e-8 * len)

Ne_N_pi
Ne_S_pi




### Watterson's estimator
?apply
### calculate nr of SNPs and then the estimator
freqs <- apply(X=data_N, MAR=2, FUN=sum)/nrow(data_N)
snps_N <- length(which(freqs>0 & freqs<1))

watt_N <- snps_N / sum(1/seq(1,n-1))

freqs <- apply(X=data_S, MAR=2, FUN=sum)/nrow(data_S)
snps_S <- length(which(freqs>0 & freqs<1))

watt_S <- snps_S / sum(1/seq(1,n-1))

### estimates of Ne from Wattersons' estimator
Ne_N_watt <- watt_N / (4 * 1e-8 * len)
Ne_S_watt <- watt_S / (4 * 1e-8 * len)

cat("\nThe North population has estimates of effective population size of", Ne_N_pi, "and", Ne_N_watt)
cat("\nThe South population has estimates of effective population size of", Ne_S_pi, "and", Ne_S_watt)


## 2) site frequency spectra

### North population
sfs_N <- rep(0, n-1)
### allele frequencies
derived_freqs <- apply(X=data_N, MAR=2, FUN=sum)
### the easiest (but slowest) thing to do would be to loop over all possible allele frequencies and count the occurrences
for (i in 1:length(sfs_N)) sfs_N[i] <- length(which(derived_freqs==i))

### South population
sfs_S <- rep(0, n-1)
### allele frequencies
derived_freqs <- apply(X=data_S, MAR=2, FUN=sum)
### the easiest (but slowest) thing to do would be to loop over all possible allele frequencies and count the occurrences
for (i in 1:length(sfs_S)) sfs_S[i] <- length(which(derived_freqs==i))

### plot
barplot(t(cbind(sfs_N, sfs_S)), beside=T, names.arg=seq(1,nrow(data_S)-1,1), legend=c("North", "South"))

cat("\nThe population with the greater population size has a higher proportion of singletons, as expected.")

### bonus: joint site frequency spectrum

sfs <- matrix(0, nrow=nrow(data_N)+1, ncol=nrow(data_S)+1)
for (i in 1:ncol(data_N)) {

	freq_N <- sum(data_N[,i])
	freq_S <- sum(data_S[,i])

	sfs[freq_N+1,freq_S+1] <- sfs[freq_N+1,freq_S+1] + 1

}
sfs[1,1] <- NA # ignore non-SNPs

image(t(sfs)) #绘制热图

















