#!/bin/bash
#PBS -l walltime=24:00:00
#PBS -l select=3:ncpus=3:mem=60gb

module load anaconda3/personal

# this is where my submit directory is
cd $PBS_O_WORKDIR

mkdir ../results/b.alignment

# RAD-seq env include - seqkit samtools bwa
source activate RAD-seq

python3 $HOME/UKBB_RADseq/code/b1.BWA_alignment.py -s 3
python3 $HOME/UKBB_RADseq/code/b1.BWA_alignment.py -s 6

echo "Mission complete" 