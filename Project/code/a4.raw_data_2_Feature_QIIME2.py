# 1.import the data to QIIME2 
# 2.Demultiplexing 
# 3. output exact sequence variant / in deblur, called sub-OTUs
# 4. Taxonomy analysis
# need anaconda
# based on QIIME2


# ========= import the module ======

import os
import argparse
import configparser
import subprocess

# ==================================
# read external argument
parser = argparse.ArgumentParser(description="Script for getting feature table")
parser.add_argument("-c", "--configfile", help="The config file.(default:./config.ini)",
                    default="./config.ini") #set the software location in this file
parser.add_argument("-o", "--outputDirectory", help="Output directory with results",
                    default="../results/1.Quality_Control/Demultiplexing")
parser.add_argument("-i", "--inputDirectory", help="input directory with fastq files",
                    default="../results/2.Feature_table/")
parser.add_argument("-t", "--threads", help="Threads",
                    default="2")
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
 
# get the software list by config file
config = configparser.ConfigParser()
config.read(configfile, encoding="utf-8")
python3 = config.get("software", "python3")
R = config.get("software", "R")
Trimmomatic = config.get("software", "Trimmomatic")
FastQC = config.get("software", "FastQC")

# write the command for QIIME2 preprocess

# check the directory
if os.path.exists(inputDirectory):
  print ("Input dir exists")
else :
  os.mkdir(inputDirectory)
if os.path.exists(outputDirectory):
  print ("Output dir exists")
else :
  os.mkdir(outputDirectory)

print ("============Start Trimming Low Quality============")

####
#run in cluster 
#
### 
## filter q-score and stat ---- Do the quality filter
Command3 = "qiime quality-filter q-score \
 --i-demux " + outputDirectory + "/Primer_trimmed-seqs.qza \
 --o-filtered-sequences " + outputDirectory + "/demux-filtered.qza \
 --o-filter-stats " + outputDirectory + "/demux-filter-stats.qza" # filter and stat
# demux-filterer.qza: a lot of filtered demutiplexed fastq file in qza
# demux-filter-stats.qza: stats of filtering 

## visualization in the qiime2
Command3 = Command3 + " && " + "qiime metadata tabulate \
  --m-input-file " + outputDirectory + "/demux-filter-stats.qza \
  --o-visualization " + outputDirectory + "/demux-filter-stats.qzv"

#subprocess.run(Command3,shell=True,check=True)

# I would suggest revisiting your demux summarize 12 visualization, and come up with a good value for your trim length!
# the trim length set here is not good ! 
# 350 fail
# 300
# 240


print ("============Start Denoising and Clustering into subOTU============")
## denoise -16s - Using deblur
Command = "qiime deblur denoise-16S \
  --i-demultiplexed-seqs  " + outputDirectory + "/demux-filtered.qza \
  --p-trim-length 310 \
  --o-representative-sequences  " + inputDirectory + "/rep-seqs-deblur.qza \
  --o-table " + inputDirectory + "/table-deblur.qza \
  --p-sample-stats \
  --o-stats  " + inputDirectory + "/deblur-stats.qza"

Command = Command + " && " +"qiime deblur visualize-stats \
  --i-deblur-stats " + inputDirectory + "/deblur-stats.qza \
  --o-visualization " + inputDirectory + "/deblur-stats.qzv" #visualize some of the stat resut
# use qiime tools view deblur-stats.qzv to see the chimeric situation proceesed by deblur


# =================== the trim length should be careful, data come from demux.qzv

# rep-seqs-deblur.qza : further rename to rep-seqs.qza
# table-deblur.qza: further rename to table.qza
# deblur-stats.qza : the information of deblur processing, some of the data related

subprocess.run(Command,shell=True,check=True)


print ("============Start Filtering the Feature table============")

#"qiime feature_table filter-features --p-min-samples"  ## queshi keyi

#"chimeric"
