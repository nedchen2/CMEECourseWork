# do blast
import os

os.system("mkdir ../results/greengene")
os.system("mkdir ../results/greengene/gg_13_8")

Command0 = "cd ../results/greengene"
#download NCBI
Command = Command0 + " &&  wget ftp://greengenes.microbio.me/greengenes_release/gg_13_5/gg_13_8_otus.tar.gz && tar xzf gg_13_8_otus.tar.gz"
#filter length

#os.system(Command)

Command1 = Command0 + " && sed '1i\Feature ID\tTaxon' gg_13_8_otus/taxonomy/99_otu_taxonomy.txt > gg_13_8_otus/taxonomy/99_otu_taxonomy.tsv "

Command1 = Command1 + " && qiime tools import \
  --input-path gg_13_8_otus/rep_set/99_otus.fasta \
  --type FeatureData[Sequence] \
  --output-path ./gg_13_8/gg_13_8_99_full_length.qza"

Command1 = Command1 + " && qiime tools import \
  --input-path gg_13_8_otus/taxonomy/99_otu_taxonomy.tsv \
  --type FeatureData[Taxonomy] \
  --output-path ./gg_13_8/gg_13_8_99_tax.qza"


Command1 = Command1 + "&& rm -r gg_13_8_otus"

#os.system(Command1)

# Region of 16S sequence
PRIMER1 = "AGAGTTTGATCCTGGCTCAG" #8F
PRIMER2 = "GCTGCCTCCCGTAGGAGT"   #338R

print ("=============Start Training the Classifier=============")

Command2 = Command0 + " && qiime feature-classifier extract-reads \
--i-sequences ./gg_13_8/gg_13_8_99_full_length.qza \
--p-f-primer " +  PRIMER1 + " \
--p-r-primer " + PRIMER2 + " \
--o-reads ./gg_13_8/gg_13_8_99-8F338R.qza \
--verbose"

Command2 = Command2 + " && qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads ./gg_13_8/gg_13_8_99-8F338R.qza \
    --i-reference-taxonomy ./gg_13_8/gg_13_8_99_tax.qza \
    --o-classifier ./gg-13_8-99-8F338R-classifier.qza"

os.system(Command2)

Command3 ="qiime feature-classifier classify-sklearn \
  --i-classifier ../results/greengene/gg-13_8-99-8F338R-classifier.qza\
  --i-reads ../results/2.Feature_table/rep-seqs.qza \
  --o-classification ../results/greengene/taxonomy.qza\
  --p-n-jobs 2"

Command3 = Command3 + " && qiime tools export \
      --input-path ../results/greengene/taxonomy.qza \
      --output-path ../results/greengene/Taxonomy_export"

os.system(Command3)

