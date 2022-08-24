# Author : Congjia Chen

# ========= import the module ======

import os
import argparse
import subprocess
import glob
import multiprocessing as mp
import time
from datetime import timedelta
import logging
import sys
import re


start_time = time.time()



# ==================================
# read external argument
parser = argparse.ArgumentParser(description="Use stacks")
parser.add_argument("-o", "--outputDirectory", help="Output directory with results",
                    default="../results/c.ref_map")
parser.add_argument("-g", "--popmap", help=" — path to a population map file (format is <name TAB pop>, one sample per line).",
                    default="../data/204n_popmap.tsv")
parser.add_argument("-i", "--inputDirectory", help="input directory with bam/sam files",
                    default="../results/b.alignment/host_alignment/")                           
parser.add_argument("-t", "--threads", help="Threads",
                    default="32")

    # Might add something related to HPC
args = parser.parse_args()

# Process the command line arguments.

popmap =os.path.abspath(args.popmap)

threads = str(args.threads)

inputDirectory = args.inputDirectory
    # check the directory
if os.path.exists(inputDirectory):
    print ("Input dir exists")
else:
    os.mkdir(inputDirectory)
outputDirectory = os.path.abspath(args.outputDirectory)    
if os.path.exists(outputDirectory):
  print ("Output dir exists")
else :
  os.mkdir(outputDirectory)

# check the step 


def Ref_map():
    Command = "ref_map.pl -T " + threads + " --samples " + inputDirectory + " --popmap " + popmap + " -o " + outputDirectory
    subprocess.run(Command,shell=True,check=True)


def vcftools():
    """Running VCFtools to find the F value for each individual. If F=1, then the sample is 100% homozygous, haploid."""
    Command = "vcftools --vcf data_final/pop_vcf_200n/populations.snps.vcf --out data_final/pop_vcf_200n/males_identify --het"
    subprocess.run(Command,shell=True,check=True)

def population_all_individuals():
    """ 
    Get the VCF file
    
    """
    Command = "populations -P data_final/ref_map_204n/ -O data_final/pop_gbs_197n/ -M data_final/popmaps/197n_vspecies.csv -r 0.8 -p 3 --min-mac 3 --max-obs-het 0.7 --vcf"
    subprocess.run(Command,shell=True,check=True)

def main():
    Ref_map()
    end_time = time.time()
    print (" ------ Time: %s --------" % (timedelta(seconds=end_time - start_time)))
    return (0)

if (__name__ == "__main__"):    
    status = main()
    sys.exit(status)