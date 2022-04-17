
# ========= import the module ======

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
                    default="../results/4.Alpha_result/")
parser.add_argument("-i", "--inputDirectory", help="input directory with fastq files",
                    default="../results/2.Feature_table/")
parser.add_argument("-t", "--threads", help="Threads",
                    default="2")
parser.add_argument("-m", "--metadata", help="metadata",
                    default="./")   
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
metadata =  os.path.abspath(args.metadata)

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

Command = "qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences " + inputDirectory + "/rep-seqs.qza \
  --o-alignment  " + outputDirectory + "/aligned-rep-seqs.qza \
  --o-masked-alignment  " + outputDirectory + "/masked-aligned-rep-seqs.qza \
  --o-tree  " + outputDirectory + "/unrooted-tree.qza \
  --o-rooted-tree  " + outputDirectory + "/rooted-tree.qza"




# 1500 --- should be the sequence count of each sample
# decided from table.qzv

Command = Command + " && " + "\
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny " + outputDirectory + "/rooted-tree.qza \
  --i-table " + inputDirectory + "/table.qza \
  --p-sampling-depth 1500 \
  --m-metadata-file " + metadata + "/sample-metadata.tsv \
  --output-dir " + outputDirectory + "/core-metrics-results"
# this core matrix give out certain outpt
# No difference in alpha diversity

#
# stat and visualize
Command = Command + " && " + "qiime diversity alpha-group-significance \
  --i-alpha-diversity " + outputDirectory + "/core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization " + outputDirectory + "/core-metrics-results/faith-pd-group-significance.qzv"

Command = Command + " && " + "qiime diversity alpha-group-significance \
  --i-alpha-diversity " + outputDirectory + "/core-metrics-results/shannon_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization " + outputDirectory + "/core-metrics-results/shannon-group-significance.qzv"

Command = Command + " && " + "qiime diversity alpha-group-significance \
  --i-alpha-diversity " + outputDirectory + "/core-metrics-results/evenness_vector.qza \
  --m-metadata-file " + metadata + "/sample-metadata.tsv \
  --o-visualization " + outputDirectory + "/core-metrics-results/evenness-group-significance.qzv"

Command = Command + " && " + "qiime diversity alpha-group-significance \
  --i-alpha-diversity " + outputDirectory + "/core-metrics-results/observed_features_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization " + outputDirectory + "/core-metrics-results/observed_features_vector-group-significance.qzv"

#subprocess.run(Command,shell=True,check=True)

Alpha_index_list = ["observed_features","ace","simpson","shannon"]

Command1 = " echo '=============Start Alpha Diversity Analysis=============' "

for i in Alpha_index_list:
  Command1 = Command1 + " && qiime diversity alpha \
  --i-table  "  + inputDirectory + "/table.qza \
  --p-metric " + i + " \
  --o-alpha-diversity " + outputDirectory + "/" + i + "_vector.qza"
  Command1 = Command1 + "&& qiime tools export \
      --input-path  " + outputDirectory + "/" + i + "_vector.qza \
      --output-path  " + outputDirectory + "/alpha_diversity_vector/" + i  

#subprocess.run(Command1,shell=True,check=True)

#===============================================

## we wll add the alpha rarefaction analysis here

Command2 = "qiime diversity alpha-rarefaction \
  --i-table "  + inputDirectory + "/table.qza \
  --p-max-depth 50000 \
  --m-metadata-file " + metadata + "/sample-metadata.tsv \
  --o-visualization " + outputDirectory + "/alpha-rarefaction.qzv"

subprocess.run(Command2,shell=True,check=True)

#=================================================

