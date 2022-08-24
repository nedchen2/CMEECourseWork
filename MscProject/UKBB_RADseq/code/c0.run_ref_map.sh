!/bin/bash
#PBS -l walltime=2:00:00
#PBS -l select=1:ncpus=32:mem=15gb
source activate stacks.2022 #activate my stacks environment
cd $HOME/bombus_project/
# --samples [path] — path to the directory containing the samples BAM (or SAM) alignment files
# --popmap [path] — path to a population map file (format is "[name] TAB [pop]", one sample per line).
# -o [path] — path to an output directory.
# -T — the number of threads/CPUs to use (default: 1).

echo -e "Start date: `date`" >> code_final/ref_map_204n/stopwatch.txt #start time
ref_map.pl -T 32 --samples data_final/bwa/sorted_bam_bhor/ --popmap data_final/popmaps/204n_vspecies.csv -o data_final/ref_map_204n/
echo -e "Finish date: `date`" >> code_final/ref_map_204n/stopwatch.txt #finish time