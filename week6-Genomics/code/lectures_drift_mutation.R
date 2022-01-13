library("ggplot2")

###########################################################################################
####################### GENETIC DRIFT


#Assumptions:
# haploid population
#asexual (no mating)
#discrete generations
###########################################################################################


#sample size is 10
N<-10

#Biallelic SNP with alleles A and G
alleles<-c(rep("A",2*N/2),rep("G",2*N/2))
alleles

#How many A's?
sum(alleles=="A")
#Frequences is...
sum(alleles=="A")/(2*N)

###############################
##### Genetic drift
###############################

#Each generation is random sample of the alleles of the previous generation, with replacement.
sample.int(2*N,2*N,replace=TRUE) #RANDOM SAMPLING WITH REPLACEMENT
alleles[(sample.int(2*N,2*N,replace=TRUE))]

#new generation alleles for this SNP

alleles<-alleles[(sample.int(2*N,2*N,replace=TRUE))]
alleles

#new frequency
sum(alleles=="A")/(2*N)

# what is the probability that any gene copy in generation t + 1 is A?
frequencies<c()
frequencies
for (i in c(1:10000)){
  f < sum(alleles[(sample.int(2*N,2*N,replace=TRUE))]=="A")/(2*N) #鍓嶉潰涓�涓?2N浠ｈ〃鐨勬槸鍙栨牱鎬绘暟锛屽悗闈竴涓?2N浠ｈ〃鐨勬槸鍙栨牱鐨勬暟閲忥紝replace=True鐨勬剰鎬濆氨鏄細琛ュ厖锛屾瘡娆″彇鐨勬牱閮芥槸浠庝竴涓簱鍙?
  frequencies<-c(frequencies,f)
}
mean(frequencies)

###########


freq_drift<-matrix(ncol=5,nrow=0)
totalcount=0
N<-10 # 这个是种群的样本数量
for (run in c(1:1)) {
  alleles<-c(rep("A",2*N/2),rep("G",2*N/2))
  totalcount=totalcount+1
  for (generation in c(0:99)) { # 在每一代中都是随机取样，重新计算A的频率
    fA <- sum(alleles=="A")/(2*N) # 这边是初始的A频率
    freq_drift<-rbind(freq_drift, c(generation, fA, N,run,totalcount))
    alleles<-alleles[(sample.int(2*N,2*N,replace=TRUE))] #循环替代
  }
}
require(ggplot2)
freq_drift<-as.data.frame(freq_drift,stringsasFactors=F )
names(freq_drift)<-c("generation","fA","N","run","totalcount")
freq_drift$N<-as.factor(as.character(freq_drift$N))
freq_drift$run<-as.factor(as.character(freq_drift$run))
freq_drift
ggplot(data=freq_drift,aes(x=generation,y=fA,color=run,group=totalcount))+
  ylim(0,1)+
  geom_line()



#Each generation is random sample of the alleles of the previous generation, with replacement...
#...or the probability of each frequency is given a by a binomial distribution. 
fA<-0.5
(rbinom(1, 2*N, fA))/(2*N)

# Find 1 random values from a sample of 2N with probability of fA.

?rbinom


###Binomial distribuiton for a sample size of 10 diploid individuals
N<-10
hist_10 <- hist((rbinom(100000, 2*N, fA))/(2*N),breaks=seq(0,1,by=1/(2*N)),plot = FALSE)
hist_10_df<-as.data.frame(cbind(hist_10$mids,hist_10$counts))
ggplot(hist_10_df,aes(x=V1,y=V2))+geom_bar(stat="identity",fill="#419D78")

###Binomial distribuiton for a sample size of 100 diploid individuals
N<-100
hist_100 <- hist((rbinom(100000, 2*N, fA))/(2*N),breaks=seq(0,1,by=1/(2*N)),plot=FALSE)
hist_100_df<-as.data.frame(cbind(hist_100$mids,hist_100$counts))
ggplot(hist_100_df,aes(x=V1,y=V2))+geom_bar(stat="identity",fill="#419D78")

###Binomial distribuiton for a sample size of 1000 diploid individuals
N<-1000
hist_1000 <-hist((rbinom(100000, 2*N, fA))/(2*N),breaks=seq(0,1,by=1/(2*N)),plot=FALSE)
hist_1000_df<-as.data.frame(cbind(hist_1000$mids,hist_1000$counts))
ggplot(hist_1000_df,aes(x=V1,y=V2))+geom_bar(stat="identity",fill="#419D78")


# ======随着样本数量的增多，越来越趋向于初始的0.5

# Although the sd is higher in lowerN, The expected mean is the same



###Starting at a frequency of 0.5 let's simulate the frequency of an allele
###through the generations, in function of the sample size
freq_drift<-matrix(ncol=5,nrow=0)
totalcount=0
for (N in c(10,100,1000,10000)){
    for (run in c(1:5)) {
      fA=0.5
      totalcount=totalcount+1
      for (generation in c(0:99)) {
        freq_drift<-rbind(freq_drift, c(generation, fA, N,run,totalcount))
        fA<-(rbinom(1, 2*N, fA))/(2*N)
      }
    }
  }

freq_drift<-as.data.frame(freq_drift,stringsasFactors=F )
names(freq_drift)<-c("generation","fA","N","run","totalcount")
freq_drift$N<-as.factor(as.character(freq_drift$N))
freq_drift$fA_0_type<-as.factor(as.character(freq_drift$fA_0_type))
ggplot(data=freq_drift,aes(x=generation,y=fA,color=N,group=totalcount))+
  geom_line()
  

###starting from very small frequencies, like if there was a new mutation,
## What are the chances of the new allele to get fixed, depending on sample size?
freq_drift<-matrix(ncol=6,nrow=0)
totalcount=0
for (N in c(10,100,1000,10000)){
  for (run in c(1:100)) {
    fA=0.01
    totalcount=totalcount+1
    for (generation in c(0:99)) {
      freq_drift<-rbind(freq_drift, c(generation, fA, N,run,totalcount))
      fA<-(rbinom(1, 2*N, fA))/(2*N)
    }
  }
}

freq_drift<-as.data.frame(freq_drift,stringsasFactors=F )
names(freq_drift)<-c("generation","fA","N","run","totalcount","fA_0_type")
freq_drift$N<-as.factor(as.character(freq_drift$N))
freq_drift$fA_0_type<-as.factor(as.character(freq_drift$fA_0_type))
freq_drift
ggplot(data=freq_drift,aes(x=generation,y=fA,color=N,group=totalcount))+
  geom_line()
















###########################################################################################
####################### MUTATIONS
###########################################################################################
#####

###1. Mutation rate from a to A
mu <- 1e-2 #high mutation rate
# over 1000 generations
fA <- rep(NA, 1000)
# starting allele frequency is 0
fA[1] <- 0

for (t in 1:999) {
  fA[t+1] <- fA[t] + mu*(1-fA[t])
}

plot(x=1:1000, y=fA, type="l", xlab="generations", lty=1, ylim=c(0,1), ylab="Allele frequency")
lines(x=1:1000, y=1-fA, lty=2)

###2. Equal mutation rates from a to A, and from A to a 结果两个都，会趋向于0.5
# mutation rates
mu_aA <- 1e-2
mu_Aa <- 1e-2
# over 1000 generations
fA <- rep(NA, 1000)
# starting allele frequency
fA[1] <- 0
for (t in 1:999) fA[t+1] <- (1-mu_Aa)*fA[t] + mu_aA*(1-fA[t])
plot(x=1:1000, y=fA, type="l", lty=1, ylim=c(0,1), ylab="Allele frequency", xlab="generations")
lines(x=1:1000, y=1-fA, lty=2)

###2. Unqeual mutation rates from a to A, and from A to a
mu_aA <- 2e-2
mu_Aa <- 1e-2
fA <- rep(NA, 1000)
fA[1] <- 0

for (t in 1:999) fA[t+1] <- (1-mu_Aa)*fA[t] + mu_aA*(1-fA[t])
plot(x=1:1000, y=fA, type="l", lty=1, ylim=c(0,1), ylab="Allele frequency", xlab="generations")
lines(x=1:1000, y=1-fA, lty=2)
cat("final frequency:", fA[length(fA)])
