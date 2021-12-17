#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=1gb
module load anaconda3/personal
echo "R is about to run"
R --vanilla < $HOME/HPC2021/code/cc421_HPC_2021_cluster.R
mv SimulationOutput* $HOME/HPC2021/results
echo "R has finished running" 