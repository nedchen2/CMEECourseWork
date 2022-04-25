# do blast
import os

os.system("mkdir ../results/blast")

os.system("cd ../results/blast")

os.system("qiime rescript get-ncbi-data \
    --p-query '33175[BioProject] OR 33317[BioProject]' \
    --o-sequences ncbi-refseqs-unfiltered.qza \
    --o-taxonomy ncbi-refseqs-taxonomy-unfiltered.qza")

#filter length
os.system("qiime rescript filter-seqs-length-by-taxon \
    --i-sequences ncbi-refseqs-unfiltered.qza \
    --i-taxonomy ncbi-refseqs-taxonomy-unfiltered.qza \
    --p-labels Archaea Bacteria \
    --p-min-lens 900 1200 \
    --o-filtered-seqs ncbi-refseqs.qza \
    --o-discarded-seqs ncbi-refseqs-tooshort.qza")

os.system("qiime rescript filter-taxa \
    --i-taxonomy ncbi-refseqs-taxonomy-unfiltered.qza \
    --m-ids-to-keep-file ncbi-refseqs.qza \
    --o-filtered-taxonomy ncbi-refseqs-taxonomy.qza")

#filter uncultured

os.system("qiime taxa filter-seqs \
    --i-sequences ncbi-refseqs.qza \
    --i-taxonomy ncbi-refseqs-taxonomy.qza \
    --p-exclude  \"uncultured\",\"Uncultured\"  \
    --o-filtered-sequences ncbi-refseqs-filtered.qza")

os.system("qiime rescript filter-taxa \
    --i-taxonomy ncbi-refseqs-taxonomy.qza \
    --m-ids-to-keep-file  ncbi-refseqs-filtered.qza\
    --o-filtered-taxonomy ncbi-refseqs-taxonomy-filtered.qza")


#do blast
os.system("qiime feature-classifier classify-consensus-blast \
    --i-query ../results/2.Feature_table/rep-seqs.qza\
    --i-reference-reads ncbi-refseqs-filtered.qza\
    --i-reference-taxonomy ncbi-refseqs-taxonomy-filtered.qza\
    --p-perc-identity 0.9\
    --p-query-cov 0.9\
    --p-maxaccepts 10\
    --o-classification taxonomy.qza")

os.system("qiime tools export \
     --input-path ./taxonomy.qza \
     --output-path ./")
