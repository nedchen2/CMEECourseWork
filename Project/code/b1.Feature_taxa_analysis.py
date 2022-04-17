# In last script, we use some of the data from QIIME to do species construction analysis

# export the table
# qiime tools export   --input-path table.qza   --output-path exported-feature-table



# ========= import the module ======

from configparser import BasicInterpolation
from cProfile import run
import os
import argparse
import configparser
import subprocess

# ==================================
# read external argument
parser = argparse.ArgumentParser(description="Script for Demultiplexing")
parser.add_argument("-c", "--configfile", help="The config file.(default:./config.ini)",
                    default="./config.ini") #set the software location in this file
parser.add_argument("-o", "--outputDirectory", help="Output directory with results",
                    default="../results/3.Taxonomy_ana")
parser.add_argument("-i", "--inputDirectory", help="input directory with fastq files",
                    default="../results/2.Feature_table/")
parser.add_argument("-m", "--metadata", help="metadata",
                    default="./")     
parser.add_argument("-t", "--threads", help="Threads",
                    default="3")
parser.add_argument("-e", "--error", help="error rate",
                    default="1") # admit one error rate

# Might add something related to HPC

args = parser.parse_args()

# Process the command line arguments.
outputDirectory = os.path.abspath(args.outputDirectory)
configfile = os.path.abspath(args.configfile)
inputDirectory = os.path.abspath(args.inputDirectory)
threads = str(args.threads)
error =  str(args.error)
classifier =  os.path.abspath(args.metadata) # dir of the pre-trained classifier
 
# get the software list by config file
config = configparser.ConfigParser()
config.read(configfile, encoding="utf-8")
python3 = config.get("software", "python3")
R = config.get("software", "R")
Trimmomatic = config.get("software", "Trimmomatic")
FastQC = config.get("software", "FastQC")


# check the directory
if os.path.exists(inputDirectory):
  print ("Input dir exists")
else :
  os.mkdir(inputDirectory)
if os.path.exists(outputDirectory):
  print ("Output dir exists")
else :
  os.mkdir(outputDirectory)

# Region of 16S sequence
PRIMER1 = "AGAGTTTGATCCTGGCTCAG" #8F
PRIMER2 = "GCTGCCTCCCGTAGGAGT"   #338R


# Later could add some arguments (Outputdirectory etc)
# add some function to check and download the sequence and taxanomy

# silva data base sequence
# source and license
# https://docs.qiime2.org/2022.2/data-resources/
# Output the sequence into code

print ("=============Start Training the Classifier=============")

Command0 = "qiime feature-classifier extract-reads \
--i-sequences " + classifier + "/silva-138-99-seqs.qza \
--p-f-primer " +  PRIMER1 + " \
--p-r-primer " + PRIMER2 + " \
--o-reads "+ classifier + "/silva-138-99-8F338R.qza \
--verbose"

# Train the classifer
# Output the classifer to code 
Command0 = Command0 + " &&  qiime feature-classifier fit-classifier-naive-bayes \
--i-reference-reads "+ classifier + "/silva-138-99-8F338R.qza \
--i-reference-taxonomy "+ classifier + "/silva-138-99-tax.qza \
--o-classifier "+ classifier + "/silva-138-99-8F338R-classifier.qza"

#subprocess.run(Command0,shell=True,check=True)


## TAXONOMY analysis
# the region we amplified is 8F-338R--- V1,V2 region
# Given the sequence, I want to know the taxonomy  information
# Use silva pre-trained  database q2-feature-classifier 
# silva may better than greengene
# however, the trained database is much bigger than GG, which will cause memory inadequate,
# therefore,here we use gg full-length data

# We tried the pre-trained GG Database,silva database classifer

# We will use HPC to do silva classification

# We will try classify the taxanomy with self-trained classifier which is recommanded by QIIME
print ("=============Start Classification=============")

Command ="qiime feature-classifier classify-sklearn \
  --i-classifier " + classifier + "/silva-138-99-8F338R-classifier.qza \
  --i-reads " + inputDirectory + "/rep-seqs.qza \
  --o-classification " + outputDirectory + "/taxonomy.qza\
  --p-n-jobs " + threads

Command = Command + " && " + "qiime tools export \
      --input-path " + outputDirectory + "/taxonomy.qza \
      --output-path " + outputDirectory + "/Taxonomy_export\
      "
# visualize the barplot of taxonomy distribution
Command = Command + " && " + "qiime taxa barplot \
   --i-table " + inputDirectory + "/table.qza \
   --i-taxonomy " + outputDirectory + "/taxonomy.qza \
   --m-metadata-file " + classifier + "/sample-metadata.tsv \
   --o-visualization " + outputDirectory + "/taxa-bar-plots.qzv"
# taxa-bar-plots.qzv: the counts of taxa in different level
# could use the data in it for example the level-2.csv to visualize

Command = Command + " && " + "qiime tools export \
      --input-path " + outputDirectory + "/taxa-bar-plots.qzv \
      --output-path " + outputDirectory + "/Taxonomy_export \
      "

#subprocess.run(Command,shell=True,check=True)

# run 
#============
#===========may be add some taxa collapse here 
print ("=============Start Taxa Collapsing and Differential Abundance Analysis=============")

Command1 = "qiime taxa collapse \
      --i-table " + inputDirectory + "/table.qza\
      --i-taxonomy " + outputDirectory + "/taxonomy.qza\
      --p-level 6\
      --o-collapsed-table " + outputDirectory + "/table-l6.qza"

Command1 = Command1 + " && " + "qiime tools export \
      --input-path  " + outputDirectory + "/table-l6.qza \
      --output-path  " + outputDirectory + "/Feature-table-result \
      " + " && " + "biom convert \
      -i " + outputDirectory + "/Feature-table-result/feature-table.biom \
      -o  " + outputDirectory + "/Feature-table-result/feature-table-taxa.tsv --to-tsv \
       "

Command1 = Command1 + " && " + "qiime composition add-pseudocount\
    --i-table " + outputDirectory + "/table-l6.qza \
    --o-composition-table " + outputDirectory + "/comp-gut-table-l6.qza"

Metadatalist = ["CollectionSite", "Species","Infection"]

for i in Metadatalist:
  Command1 = Command1 + " && " + "qiime composition ancom \
    --i-table " + outputDirectory + "/comp-gut-table-l6.qza \
    --m-metadata-file " + classifier + "/sample-metadata.tsv \
    --m-metadata-column " + i + " \
    --o-visualization " + outputDirectory + "/Feature-table-result/l6-ancom-" + i +".qzv"


#subprocess.run(Command1,shell=True,check=True)


#according to the information so far, there are no difference taxa according to the current data.
#only difference exists between species



print ("=============Start Functional Profiling=============")

Command2 = "qiime picrust2 full-pipeline \
   --i-table " + inputDirectory + "/table.qza \
   --i-seq " + inputDirectory + "/rep-seqs.qza \
   --output-dir " + outputDirectory + "/q2-picrust2_output \
   --p-placement-tool sepp \
   --p-threads 2 \
   --p-hsp-method pic \
   --p-max-nsti 2 \
   --verbose"


Command2 = Command2 + " && " +  "qiime tools export \
      --input-path  " + outputDirectory + "/q2-picrust2_output/pathway_abundance.qza \
      --output-path  " + outputDirectory + "/q2-picrust2_output/Functional_profiling_pathway \
      " + " && " + "biom convert \
      -i " + outputDirectory + "/q2-picrust2_output/Functional_profiling_pathway/feature-table.biom \
      -o  " + outputDirectory + "/q2-picrust2_output/Functional_profiling_pathway/Pathway_abundance.tsv --to-tsv \
       "

Command2 = Command2 + " && " + "qiime tools export \
      --input-path  " + outputDirectory + "/q2-picrust2_output/ko_metagenome.qza \
      --output-path  " + outputDirectory + "/q2-picrust2_output/Functional_profiling_ko \
      " + " && " + "biom convert \
      -i " + outputDirectory + "/q2-picrust2_output/Functional_profiling_ko/feature-table.biom \
      -o  " + outputDirectory + "/q2-picrust2_output/Functional_profiling_ko/ko_metagenome.tsv --to-tsv \
       "

Command2 = Command2 + " && " + "qiime tools export \
      --input-path  " + outputDirectory + "/q2-picrust2_output/ec_metagenome.qza \
      --output-path  " + outputDirectory + "/q2-picrust2_output/Functional_profiling_ec \
      " + " && " + "biom convert \
      -i " + outputDirectory + "/q2-picrust2_output/Functional_profiling_ec/feature-table.biom \
      -o  " + outputDirectory + "/q2-picrust2_output/Functional_profiling_ec/ec_metagenome.tsv --to-tsv \
       "

#subprocess.run(Command2,shell=True,check=True)



# use PICRUST2 TO ADD THE DISCRIPTION
# =============== Enrichment analysis

# conda activate picrust2
# Command = "add_descriptions.py -i ../results/3.Taxonomy_ana/q2-picrust2_output/Functional_profiling_pathway/Pathway_abundance.tsv -o ../results/3.Taxonomy_ana/q2-picrust2_output/Functional_profiling_pathway/pred_metagenome_unstrat_descrip.tsv -m METACYC"
# add_descriptions.py -i ../results/3.Taxonomy_ana/q2-picrust2_output/Functional_profiling_ec/ec_metagenome.tsv -o ../results/3.Taxonomy_ana/q2-picrust2_output/Functional_profiling_ec/pred_metagenome_unstrat_descrip.tsv -m EC
# add_descriptions.py -i ../results/3.Taxonomy_ana/q2-picrust2_output/Functional_profiling_ko/ko_metagenome.tsv -o ../results/3.Taxonomy_ana/q2-picrust2_output/Functional_profiling_ko/pred_metagenome_unstrat_descrip.tsv -m KO


# ============== differential Analysis of KO and Metacyc 


Command3 = "echo '=============Start Differential Functional Analysis=============' "

Command3 = Command3 + " && " + "qiime composition add-pseudocount\
    --i-table " + outputDirectory + "/q2-picrust2_output/ko_metagenome.qza \
    --o-composition-table " + outputDirectory + "/q2-picrust2_output/comp-gut-table-ko.qza"

for i in Metadatalist:
  Command3 = Command3  + " && qiime composition ancom \
    --i-table " + outputDirectory + "/q2-picrust2_output/comp-gut-table-ko.qza\
    --m-metadata-file " + classifier + "/sample-metadata.tsv \
    --m-metadata-column " + i + " \
    --o-visualization " + outputDirectory + "/q2-picrust2_output/ko-ancom-" + i +".qzv"

subprocess.run(Command3,shell=True,check=True)

# Do a summary on the taxa classification 

# ========= combine the table together ===========

Command4 = " python3 fasta2tsv.py"

#subprocess.run(Command4,shell=True,check=True)





# ======================== Overview of Microbial Composition of Bee

# based on taxa collapse data

# ==================== Barplot ===

# = relative abundance (top10 and others)  - level 6- Genus

# = relative abundance (top10 and others)  - level 2- Phylum?


# ==================== Heatmap ===

# log transform + scale

# = absolute abundance (top10) Heatmap - level 6- Genus

# = absolute abundance (top10) Heatmap - level 2- Phylum?


# ========================   Different species Composition analysis

# ==same procedure



# ========================    Different sampling sites Composition anaslysis

# ==same procedure



#subprocess.run(Command1,shell=True,check=True)

# ============




