# Author : Congjia Chen

# ========= import the module ======

import os
import argparse
import subprocess
import glob
import pandas as pd
import multiprocessing as mp
import time
from datetime import timedelta

start_time = time.time()

# ==================================
# read external argument
parser = argparse.ArgumentParser(description="Use BWA do alignment and output SAM")
parser.add_argument("-o", "--outputDirectory", help="Output directory with results",
                    default="../results/b.alignment")
parser.add_argument("-g", "--genome", help="input directory with fastq files",
                    default="../genome")
parser.add_argument("-i", "--inputDirectory", help="input directory with fastq files",
                    default="../results/a.process_radtags/")                    
parser.add_argument("-t", "--threads", help="Threads",
                    default="2")

# Might add something related to HPC

args = parser.parse_args()

# Process the command line arguments.

inputDirectory = os.path.abspath(args.inputDirectory)
genomeDirecory =os.path.abspath(args.genome)

genome = genomeDirecory + "/GC*/*.fna"
input_fasta = inputDirectory  + "/*.fq.gz"

genome = glob.glob(genome)
input_fasta  = glob.glob(input_fasta)


threads = str(args.threads)

# check the directory
if os.path.exists(inputDirectory):
  print ("Input dir exists")
else :
  os.mkdir(inputDirectory)



def Alignment(genome):
    """_summary_

    Args:
        genome (character): the pathway of a genome
    """
   

    index_dir = os.path.dirname(genome) 
    print(index_dir)
    outputDirectory = os.path.abspath(args.outputDirectory)
    outputDirectory = outputDirectory + "/" + os.path.basename(genome).split(".fna")[0]
    if os.path.exists(outputDirectory):
        print ("Output dir exists")
    else :
        os.mkdir(outputDirectory)

    # build the index with bwa
    prefix_index = index_dir + "/" + os.path.basename(genome).split(".fna")[0]
    Command = "bwa index -p " + prefix_index + " -a is " + genome
    subprocess.run(Command,shell=True,check=True)
    
    # Using BWA to align each sample to the reference genome to generate SAM files
    for fasta in input_fasta:
        prefix_fasta =  os.path.basename(fasta).split(".fq.gz")[0]
        Command1 = "bwa mem " + prefix_index + " " + fasta + " > " + outputDirectory + "/" + prefix_fasta + ".sam"
        subprocess.run(Command1,shell=True,check=True)
    
    # Using SAMtools to convert the SAM files into sorted BAM files
    # stat of map ratio
    samDirectory = outputDirectory + "/*.sam"
    samfiles = glob.glob(samDirectory)
    # We must specify that our input is in SAM format (by default it expects BAM) using the -S option. 
    # We must also say that we want the output to be BAM (by default it produces BAM) with the -b option.
    df_stat = pd.DataFrame()
    for i in range(len(samfiles)):
        prefix_sam =  os.path.basename(samfiles[i]).split(".sam")[0]
        Command2 = "samtools view -S -b " + samfiles[i]  + " | samtools sort -O bam > " + outputDirectory + "/" + prefix_sam + ".sorted.bam" 
        Command2 = Command2 + " && samtools flagstat " + outputDirectory + "/" + prefix_sam + ".sorted.bam"  + " > " + outputDirectory + "/flag_stats.txt"
        subprocess.run(Command2,shell=True,check=True)

        tmpfile = outputDirectory + "/flag_stats.txt"
        df = pd.read_csv(tmpfile)
        df_stat.loc[i,"sample"] =  os.path.basename(samfiles[i])
        df_stat.loc[i,"mapping_ratio"] = df.loc[3].values
        df_stat.loc[i,"genome"] =  os.path.basename(genome)
    return (df_stat)
    
df_result = pd.DataFrame()

# parallel
pool = mp.Pool(mp.cpu_count())

results = pool.map(Alignment, genome)

pool.close()

df_result = pd.concat(results,axis = 0)

df_result.to_csv("../results/b.alignment/MapStat.csv")

end_time = time.time()

print (" ------ Time: %s --------" % (timedelta(seconds=end_time - start_time)))