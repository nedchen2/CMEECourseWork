#!/bin/bash
#PBS -l walltime=1:00:00
#PBS -l select=1:ncpus=1:mem=5gb

module load anaconda3/personal

source activate stacks.2022 #activate my stacks environment
# this is where my submit directory is
cd $PBS_O_WORKDIR

mkdir ../results/d.population
mkdir ../results/d.population/

populations -P ../results/c.ref_map/ -O ../results/d.population/ -M ../data/197n_popmap.tsv -r 0.8 -p 2 --min-mac 3 --max-obs-het 0.7 --vcf

