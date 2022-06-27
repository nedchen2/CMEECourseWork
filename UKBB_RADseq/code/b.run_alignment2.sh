#!/bin/bash
#PBS -l walltime=24:00:00
#PBS -l select=8:ncpus=8:mem=8gb

module load anaconda3/personal

# this is where my submit directory is
cd $PBS_O_WORKDIR

mkdir ../results/b.alignment

# RAD-seq env include - seqkit samtools bwa
source activate RAD-seq

python3 $HOME/UKBB_RADseq/code/b1.BWA_alignment.py -s 1 -g ../genome/parasite

echo "Mission complete" 
