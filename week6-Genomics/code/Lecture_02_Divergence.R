
# geckos
#What is the genetic divergence? It is the proportion of sites which are fixed for different alleles between populations/species.

# 简单来说，就是同一位置，虽然本物种等位基因相同，但不同物种具有不同的碱基
## read data for each specie


# 对于数据来描述： 20kbp for 10 individuals from each species

len <- 20000
class(read.csv("./data/western_banded_gecko.csv"))
data_w <- read.csv("./data/western_banded_gecko.csv", stringsAsFactors=F, header=F, colClasses=rep("character", len))
dim(data_w)

data_b <- read.csv("./data/bent-toed_gecko.csv", stringsAsFactors=F, header=F, colClasses=rep("character", len))
dim(data_b)

data_l <- read.csv("./data/leopard_gecko.csv", stringsAsFactors=F, header=F, colClasses=rep("character", len))
dim(data_l)


## calculate divergence between sequences of B and L

sites_total <- 0
sites_divergent <- 0 

div_rate_BL <- sites_divergent / sites_total



for (i in 1:ncol(data_b)) {

	### you need to discard SNPs within each species
	if (length(unique(data_b[,i]))==1 & length(unique(data_l[,i]))==1) { # 要算divergence首先需要满足一个条件，就是本物种同一位置为相同碱基
		
		sites_total <- sites_total + 1

		### if different, then it's a divergent site
		if (data_b[1,i] != data_l[1,i]) {
		  sites_divergent <- sites_divergent + 1
		}
	}
}
### divergence rate
div_rate_BL <- sites_divergent / sites_total


## calculate divergence between sequences of W and L

sites_total <- 0
sites_divergent <- 0

for (i in 1:ncol(data_w)) {

        ### you need to discard SNPs within each species
        if (length(unique(data_w[,i]))==1 & length(unique(data_l[,i]))==1) {

                sites_total <- sites_total + 1 #（下一步是把两个物种间一样的allele组合去掉了，因为这样是non-divergent）

                ### if different, then it's a divergent site
                if (data_w[1,i] != data_l[1,i]) sites_divergent <- sites_divergent + 1

        }
}
### divergence rate
div_rate_WL <- sites_divergent / sites_total


## calculate divergence between sequences of W and B

sites_total <- 0
sites_divergent <- 0

for (i in 1:ncol(data_w)) {

        ### you need to discard SNPs within each species
        if (length(unique(data_w[,i]))==1 & length(unique(data_b[,i]))==1) {

                sites_total <- sites_total + 1

                ### if different, then it's a divergent site
                if (data_w[1,i] != data_b[1,i]) sites_divergent <- sites_divergent + 1

        }
}
### divergence rate
div_rate_WB <- sites_divergent / sites_total


div_rate_BL
div_rate_WL
div_rate_WB






## from these divergence rates we can infer that W and B are close species while L is the outgroup
# 因为这边发现了问题所在了，WB的divergence明显低于BL和WL，所以L是outgroup
## estimate mutation rate per site per year
mut_rate <- div_rate_BL / (2 * 3e7) # divergence 两个近缘的与远点差距不大，所以两个近缘的可以任取一，也可以取平均值


## estimate divergence time
div_time <- div_rate_WB / (2 * mut_rate)

cat("\nThe two species have a divergence time of", div_time, "years.")
cat("\nThe most likely species tree is L:(W:B).")








