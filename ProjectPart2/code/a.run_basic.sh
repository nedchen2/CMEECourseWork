#!/bin/bash
#PBS -l walltime=7:00:00
#PBS -l select=1:ncpus=1:mem=2gb

module load anaconda3/personal

source activate stacks.2022 #loading my anaconda3 stacks environment

# this is where my submit directory is
cd $PBS_O_WORKDIR

mkdir ../results/a.process_radtags

touch ../results/a.process_radtags/stopwatch.txt #Make a stopwatch
echo -e "Start date: `date`" >> ../results/a.process_radtags/stopwatch.txt #Start time
process_radtags -p ../data/FASTQ_Sequence_Files -o ../results/a.process_radtags/ -e SgrAI -c -q -r -D -i gzfastq &> ../results/a.process_radtags/process_radtags.oe
# -p = directory where data files are
# -o = directory to put output files
# -e = enzyme used
# -c = clean data, remove any read with an uncalled base
# -q = discard reads with low quality scores
# -r = rescue barcodes and RAD-Tags
# -D = capture discarded reads to a file
# -i = input file type
# & = push the process to background
# > = save the output of the process here
echo -e "Finish date: `date`" >> ../results/a.process_radtags/stopwatch.txt #Finish time

# create the HPC environment 
# module load anaconda3/personal
# conda create -n stacks.2022 stacks

# create local work environment 
# conda create -n RAD-seq
# conda activate RAD-seq
# install tools
# conda install -c bioconda bwa
# conda install -c bioconda samtools


