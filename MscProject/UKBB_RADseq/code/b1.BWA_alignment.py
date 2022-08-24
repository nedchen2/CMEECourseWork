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
import logging
import sys
import re


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
parser.add_argument("-s", "--step", help="choose which step to run (1 for alignment to sam, 2 for SamtoBam,  3 for mapping stat, 4,5 for host specific alignment,6 to PercentageCoverage,7 to genome length  )",
                    default="2")                       
parser.add_argument("-t", "--threads", help="Threads",
                    default="2")

    # Might add something related to HPC
args = parser.parse_args()

# Process the command line arguments.

genomeDirecory =os.path.abspath(args.genome)
genome_path = genomeDirecory + "/GC*/*.fna"
genome_list = glob.glob(genome_path)


threads = str(args.threads)
step = str(args.step)


inputDirectory = args.inputDirectory
    # check the directory
if os.path.exists(inputDirectory):
    print ("Input dir exists")
else:
    os.mkdir(inputDirectory)

# check the step 

df_meta = pd.read_csv("../code/metadata_RADseq.csv")

input_fasta_path = inputDirectory  + "/*.fq.gz"
input_fasta_file  = glob.glob(input_fasta_path)

if step == str(4): # BomTerr
    input_fasta = df_meta.loc[df_meta.genome == "GCF_910591885.1_BomTerr_genomic.fna" , "relative_dir"].tolist()
    input_fasta = list(set(input_fasta_file).intersection(input_fasta))
elif step == str(5): # BomHort
    input_fasta = df_meta.loc[df_meta.genome == "GCA_905332935.1_iyBomHort1.1_genomic.fna" , "relative_dir"].tolist() 
    input_fasta = list(set(input_fasta_file).intersection(input_fasta))
else:
    input_fasta = input_fasta_file

def Alignment(genome):
    """_summary_

    Args:
        genome (character): the pathway of a genome
    """
    global input_fasta

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
        sam_name = outputDirectory + "/" + prefix_fasta + ".sam"
        bam_name = outputDirectory + "/" + prefix_fasta + ".sorted.bam"
        if os.path.exists(sam_name)|os.path.exists(bam_name):
            continue
        else: 
            Command1 = "bwa mem " + prefix_index + " " + fasta + " > " + sam_name
            subprocess.run(Command1,shell=True,check=True)
    return (prefix_index)


def SamToBam(genome):
    outputDirectory = os.path.abspath(args.outputDirectory)
    outputDirectory = outputDirectory + "/" + os.path.basename(genome).split(".fna")[0]

    samDirectory = outputDirectory + "/*.sam"
    samfiles = glob.glob(samDirectory)
    # We must specify that our input is in SAM format (by default it expects BAM) using the -S option. 
    # We must also say that we want the output to be BAM (by default it produces BAM) with the -b option.
    for i in range(len(samfiles)):
        prefix_sam =  os.path.basename(samfiles[i]).split(".sam")[0]
        bam_name = outputDirectory + "/" + prefix_sam + ".sorted.bam"
        if os.path.exists(bam_name):
            continue
        else: 
            Command3 = "samtools view -S -b " + samfiles[i]  + " | samtools sort -O bam > " + outputDirectory + "/" + prefix_sam + ".sorted.bam"
            subprocess.run(Command3,shell=True,check=True)
    # check if BAM successfully output
    # rm all the sam file.
    for i in range(len(samfiles)):
        prefix_sam =  os.path.basename(samfiles[i]).split(".sam")[0]
        bam_name = outputDirectory + "/" + prefix_sam + ".sorted.bam"
        if os.path.exists(bam_name):
            os.remove(samfiles[i])
        else:
            print (bam_name + " not find")


def SamtoolsflagStat(genome):
    """_summary_

    Args:
        genome (character): the pathway of a genome
    """
    # Using SAMtools to convert the SAM files into sorted BAM files
    # stat of map ratio
    outputDirectory = os.path.abspath(args.outputDirectory)
    outputDirectory = outputDirectory + "/" + os.path.basename(genome).split(".fna")[0]

    bamDirectory = outputDirectory + "/*.sorted.bam"
    bamfiles = glob.glob(bamDirectory)
    # We must specify that our input is in SAM format (by default it expects BAM) using the -S option. 
    # We must also say that we want the output to be BAM (by default it produces BAM) with the -b option.
    df_stat = pd.DataFrame()
    for i in range(len(bamfiles)):
        prefix_sam =  os.path.basename(bamfiles[i]).split(".sorted.bam")[0]
        # Command2 = "samtools view -S -b " + samfiles[i]  + " | samtools sort -O bam > " + outputDirectory + "/" + prefix_sam + ".sorted.bam" 
        # if we only want the map ratio, we do not need to transfer the sam into bam
        Command2 = "samtools flagstat " + outputDirectory + "/" + prefix_sam + ".sorted.bam"  + " > " + outputDirectory + "/flag_stats.txt"
        subprocess.run(Command2,shell=True,check=True)

        tmpfile = outputDirectory + "/flag_stats.txt"
        df = pd.read_csv(tmpfile)
        df_stat.loc[i,"sample"] =  os.path.basename(bamfiles[i])
        df_stat.loc[i,"mapping_ratio"] = df.loc[3].values
        df_stat.loc[i,"genome"] =  os.path.basename(genome)
    return (df_stat)



    

def SamtoolsStatPercentageCoverage(genome):

    Command = "seqkit stat -T " + genome + "| sed -n 2p | cut -f 5"
    genome_length = int(subprocess.getoutput(Command))

    outputDirectory = os.path.abspath(args.outputDirectory)
    outputDirectory = outputDirectory + "/" + os.path.basename(genome).split(".fna")[0]

    bamDirectory = outputDirectory + "/*.sorted.bam"
    bamfiles = glob.glob(bamDirectory)
    # We must specify that our input is in SAM format (by default it expects BAM) using the -S option. 
    # We must also say that we want the output to be BAM (by default it produces BAM) with the -b option.
    df_stat = pd.DataFrame()
    for i in range(len(bamfiles)):
        prefix_sam =  os.path.basename(bamfiles[i]).split(".sorted.bam")[0]
        #Command3 = "samtools view -S -b " + samfiles[i]  + " | samtools sort -O bam > " + outputDirectory + "/" + prefix_sam + ".sorted.bam"
        Command3 = "samtools depth -a " + outputDirectory + "/" + prefix_sam + ".sorted.bam"  + " > " + outputDirectory + "/tmp_read_depth.txt"
        subprocess.run(Command3,shell=True,check=True)
        tmpfile = outputDirectory + "/tmp_read_depth.txt"
        print (tmpfile)

       #calculate the length of covered area
        try:
          df = pd.read_csv(tmpfile,sep = "\t",header = None)
          if sum(df.loc[:,2] >= 1) >= 0:
            read_coverage_area = df[df.loc[:,2] >= 1].shape[0]
          else: 
            read_coverage_area = 0
        except:
          read_coverage_area = 0

        print (read_coverage_area)
        df_stat.loc[i,"sample"] =  os.path.basename(bamfiles[i])
        df_stat.loc[i,"genome"] =  os.path.basename(genome)
        df_stat.loc[i,"coverage_area"] = read_coverage_area
        df_stat.loc[i,"genomeLength"] =  genome_length
        df_stat.loc[i,"PercCoverage"] =  read_coverage_area/genome_length
    return (df_stat)


def calculate_genome_length(genome):
    Command = "seqkit stat -T " + genome + "| sed -n 2p | cut -f 5"
    genome_length = int(subprocess.getoutput(Command))/1000

    outputDirectory = os.path.abspath(args.outputDirectory)
    outputDirectory = outputDirectory + "/" + os.path.basename(genome).split(".fna")[0]
    df_stat = pd.DataFrame()

    df_stat.loc[1,"genome"] =  os.path.basename(genome)
    df_stat.loc[1,"genomeLength"] =  genome_length
    return (df_stat)



def main():

    df_result = pd.DataFrame()

    # parallel
    pool = mp.Pool(mp.cpu_count())
    if step == str(1):
        results_1 = pool.map(Alignment, genome_list)
    elif step == str(2):
        results_1 = pool.map(SamToBam, genome_list)
    elif step == str(3):
        results = pool.map(SamtoolsflagStat, genome_list)
        df_result = pd.concat(results,axis = 0)
        df_result.to_csv("../results/b.alignment/MapStat.csv")
    elif step == str(4):       
        #Terrestris
        #revise the input_genome
        genome_1 = [x for x in genome_list if "GCA_905332935.1_iyBomHort1.1_genomic.fna" in x]      
        #GCA_905332935.1_iyBomHort1.1_genomic.fna
        #GCF_910591885.1_BomTerr_genomic.fna     use terrestris genome in alignment 
        print (len(input_fasta))
        results_2 = pool.map(Alignment, genome_1)

    elif step == str(5):
        #hortorum
        genome_2 = [x for x in genome_list if "GCA_905332935.1_iyBomHort1.1_genomic.fna" in x]
        print (len(input_fasta))
        results_3 = pool.map(Alignment, genome_2)
    elif step == str(6):
        results = pool.map(SamtoolsStatPercentageCoverage, genome_list)
        df_result = pd.concat(results,axis = 0)
        df_result.to_csv("../results/b.alignment/PerCoverageStat.csv")
    elif step == str(7):
        results = pool.map(calculate_genome_length, genome_list)
        df_result = pd.concat(results,axis = 0)
        df_result.to_csv("../genome/Genome_length.csv")
    
    else:
        print ("Error")

    
    pool.close()
    
    end_time = time.time()
    print (" ------ Time: %s --------" % (timedelta(seconds=end_time - start_time)))
    return (0)


if (__name__ == "__main__"):    
    status = main()
    sys.exit(status)


