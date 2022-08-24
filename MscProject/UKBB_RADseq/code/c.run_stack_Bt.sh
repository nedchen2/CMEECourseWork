#!/bin/bash
#PBS -l walltime=3:00:00
#PBS -l select=1:ncpus=32:mem=15gb

module load anaconda3/personal

source activate stacks.2022 #activate my stacks environment
# this is where my submit directory is
cd $PBS_O_WORKDIR

python3 $HOME/UKBB_RADseq/code/c1.stacks_ref_map.py -g ../data/Bt_popmap.tsv

echo "Mission complete" 
