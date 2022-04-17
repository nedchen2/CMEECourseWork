"""
DESCRIPTION:
This is the script for the integrated pipeline. 
It is composed of header lines and modules indicated by a line of "#". 
The header lines and each module can be combined together as another script. 
Modules include (1) quality control and host removing; (2) subsampling; (3) assembly-dependent species identification; (4) reference database construction; (5) fragment recruitment; (6) assembly-independent species identification; (7) functional annotation; (8) annotation integration.

DEPENDENCIES:
Python modules: os, sys, pandas, numpy, Biopython, re, taxomias (https://github.com/wegnerce/taxomias)
Conda-managed softwares: Fastqc, Trimmomatic, Bowtie2, SAMtools, BBmap, DIAMOND
Other softwares: SPAdes, MEGAN6, dataset (command-line tool of NCBI), EggNOG-mapper
Databases: nr.dmnd (DIAMOND database of nr), megan-map-Jul2020-2.db (MEGAN6 database)

ARGUMENTS:
args[1]: <file> raw fastq file 1
args[2]: <file> raw fastq file 2
args[3]: <directory> output directory
args[4]: <string> sample identifier
args[5]: <integer> threads
args[6]: <float> subsampling proportion
args[7]: <integer> indicate time of repeatedly subsampling
args[8]: <string> base name of Bowtie2 index of host genome. If None, host removing is skipped.

OUTPUT:
Seen in annotations of each module.
"""

import os
import sys
import pandas as pd
import numpy as np
# sys.path.append('/rds/general/user/cl3820/home/taxomias')
import taxomias as tx
import re

args = sys.argv

# Arguments
rawData1 = args[1] 
rawData2 = args[2]
outDir = args[3]
sample = args[4]
threads = str(args[5]) 
sample_percent = str(args[6])
repeat = str(args[7])
HostIndex = args[8]
# subdirectory of output
outDirsub = sample_percent+"_"+repeat # e.g. 0.1_1 (0.1 represents subsampling percent, and 1 indicates it is the first time of repeatedly subsampling)

if not os.path.exists(outDir):
    os.system("mkdir"+" "+outDir)
if not os.path.exists(outDir+"/"+outDirsub):
    os.system("mkdir"+" "+outDir+"/"+outDirsub)

print(args)

#########################################################################
# Quality control and host removing

# Fastqc: Check raw data quality
# INPUT: rawData1, rawData2
# OUTPUT: QC reports (2 .html and 2 .zip) in outDir
cmd = "fastqc -o "+outDir+" -t "+threads+" "+rawData1+" "+rawData2
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

# Trimmomatic: Data filtering
# INPUT: rawData1, rawData2, NexteraPE-PE.fa (fasta of Nextera adaptors)
# OUTPUT: outDir+"/"+sample+"_clean.1.fq", outDir+"/unpaired_"+sample+".1.fq"
#         outDir+"/"+sample+"_clean.2.fq", outDir+"/unpaired_"+sample+".2.fq"
cmd = "trimmomatic PE -threads "+threads+" -phred33 "+rawData1+" "+rawData2+" "+outDir+"/"+sample+"_clean.1.fq"+" "+outDir+"/unpaired_"+sample+".1.fq"+" "+outDir+"/"+sample+"_clean.2.fq"+" "+outDir+"/unpaired_"+sample+".2.fq"+" ILLUMINACLIP:NexteraPE-PE.fa:2:30:10:1:true HEADCROP:15 TRAILING:20 MINLEN:50 AVGQUAL:20"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

# Fastqc: Check clean data quality
# INPUT: outDir+"/"+sample+"_clean.1.fq", outDir+"/"+sample+"_clean.2.fq"
# OUTPUT: QC reports (2 .html and 2 .zip) in outDir
cmd = "fastqc -o "+outDir+" -t "+threads+" "+outDir+"/"+sample+"_clean.1.fq"+" "+outDir+"/"+sample+"_clean.2.fq"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

if HostIndex != "None": # Remove host
    # Bowtie2: Map reads to host genome
    # SAMtools: Convert SAM to BAM
    # INPUT: HostIndex
    #        outDir+"/"+sample+"_clean.1.fq"
    #        outDir+"/"+sample+"_clean.2.fq"
    # OUTPUT: outDir+"/"+sample+"_Host.sam.bam"
    cmd = "bowtie2 --sensitive --end-to-end -p "+threads+" -x "+HostIndex+" -1 "+outDir+"/"+sample+"_clean.1.fq"+" -2 "+outDir+"/"+sample+"_clean.2.fq"+" -S "+outDir+"/"+sample+"_Host.sam"
    print("Command: ")
    print(cmd)
    os.system(cmd)
    print("Done")
    cmd = "samtools view -@ "+threads+" -b -S "+outDir+"/"+sample+"_Host.sam"+" > "+outDir+"/"+sample+"_Host.sam.bam"
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")

    # Remove outDir+"/"+sample+"_Host.sam"
    os.system("rm "+outDir+"/"+sample+"_Host.sam")

    # SAMtools: Extract BAM of unmapped reads
    #           Convert extracted BAM to fq
    # INPUT: outDir+"/"+sample+"_Host.sam"+".bam"
    # OUTPUT: outDir+"/"+sample+"_Host.sam"+".bam_unmapped"
    #         outDir+"/"+sample+"_Host.sam"+".bam_unmapped.1.fq"
    #         outDir+"/"+sample+"_Host.sam"+".bam_unmapped.2.fq"
    cmd = "samtools view -@ "+threads+" -u -f 12 "+outDir+"/"+sample+"_Host.sam"+".bam"+" > "+outDir+"/"+sample+"_Host.sam"+".bam_unmapped"
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")
    cmd = "samtools fastq -1 "+outDir+"/"+sample+"_Host.sam.bam_unmapped.1.fq -2 "+outDir+"/"+sample+"_Host.sam.bam_unmapped.2.fq "+outDir+"/"+sample+"_Host.sam.bam_unmapped"+" -@ "+threads
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")

    # SAMtools: Extract BAM of mapped reads
    #           Convert extracted BAM to fq
    # INPUT: outDir+"/"+sample+"_Host.sam"+".bam"
    # OUTPUT: outDir+"/"+sample+"_Host.sam"+".bam_mapped"
    #         outDir+"/"+sample+"_Host.sam"+".bam_mapped.1.fq"
    #         outDir+"/"+sample+"_Host.sam"+".bam_mapped.2.fq"
    cmd = "samtools view -@ "+threads+" -u -G 12 "+outDir+"/"+sample+"_Host.sam"+".bam"+" > "+outDir+"/"+sample+"_Host.sam"+".bam_mapped"
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")
    cmd = "samtools fastq -1 "+outDir+"/"+sample+"_Host.sam.bam_mapped.1.fq -2 "+outDir+"/"+sample+"_Host.sam.bam_mapped.2.fq "+outDir+"/"+sample+"_Host.sam.bam_mapped"+" -@ "+threads
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")
else:
    # If HostIndex is "None", host removing is skipped
    os.system("mv "+outDir+"/"+sample+"_clean.1.fq"+" "+outDir+"/"+sample+"_Host.sam.bam_unmapped.1.fq")
    os.system("mv "+outDir+"/"+sample+"_clean.2.fq"+" "+outDir+"/"+sample+"_Host.sam.bam_unmapped.2.fq")
    print("HostIndex = "+HostIndex)
    print("Skip host removing")
    print("Rename "+outDir+"/"+sample+"_clean.1.fq"+" as "+outDir+"/"+sample+"_Host.sam.bam_unmapped.1.fq")
    print("Rename "+outDir+"/"+sample+"_clean.2.fq"+" as "+outDir+"/"+sample+"_Host.sam.bam_unmapped.2.fq")
#########################################################################
# Subsampling

if sample_percent != "1":
    Data1 = outDir+"/"+outDirsub+"/"+sample+"_"+sample_percent+"_1.fq"
    Data2 = outDir+"/"+outDirsub+"/"+sample+"_"+sample_percent+"_2.fq"
    if not os.path.exists(Data1) or not os.path.exists(Data2):
        # BBmap: Subsample metagenomic mate pairs
        # INPUT: outDir+"/"+sample+"_Host.sam.bam_unmapped.1.fq"
        #        outDir+"/"+sample+"_Host.sam.bam_unmapped.2.fq"
        # OUTPUT: Data1 = outDir+"/"+outDirsub+"/"+sample+"_"+sample_percent+"_1.fq"
        #         Data2 = outDir+"/"+outDirsub+"/"+sample+"_"+sample_percent+"_2.fq"
        cmd = "reformat.sh "+"in="+outDir+"/"+sample+"_Host.sam.bam_unmapped.1.fq"+" "+"in2="+outDir+"/"+sample+"_Host.sam.bam_unmapped.2.fq"+" "+"out="+Data1+" "+"out2="+Data2+" "+"samplerate="+sample_percent
        print("Command:")
        print(cmd)
        os.system(cmd)
        print("Done")  
else:
    # Ananlyze the whole dataset without subsampling
    Data1 = outDir+"/"+sample+"_Host.sam.bam_unmapped.1.fq"
    Data2 = outDir+"/"+sample+"_Host.sam.bam_unmapped.2.fq"
    print("Subsample percentage = 1")
    print("Analyzing the whole dataset")

#########################################################################
# Assembly-dependent species identification

if not os.path.exists(outDir+"/"+outDirsub+"/PreAssembly"):
    os.system("mkdir "+outDir+"/"+outDirsub+"/PreAssembly")
if not os.path.exists(outDir+"/"+outDirsub+"/PreAssembly/assembly"):
    os.system("mkdir "+outDir+"/"+outDirsub+"/PreAssembly/assembly")

if sample_percent != "1":
    Data1 = outDir+"/"+outDirsub+"/"+sample+"_"+sample_percent+"_1.fq"
    Data2 = outDir+"/"+outDirsub+"/"+sample+"_"+sample_percent+"_2.fq"
else:
    Data1 = outDir+"/"+sample+"_Host.sam.bam_unmapped.1.fq"
    Data2 = outDir+"/"+sample+"_Host.sam.bam_unmapped.2.fq"

# SPAdes: assemble subsampled reads
# INPUT: Data1
#        Data2
# OUTPUT: outDir+"/"+outDirsub+"/PreAssembly/assembly.tar"
cmd = "SPAdes-3.15.2-Linux/bin/spades.py -t"+" "+threads+" "+"-k 21,31,41,51,61,71,81,91,101 --only-assembler --meta -1 "+Data1+" -2 "+Data2+" -o "+outDir+"/"+outDir+"/PreAssembly/assembly"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")
# Compress outDir+"/"+sample_percent+"/PreAssembly/assembly"
cmd = "tar -cf "+outDir+"/"+outDirsub+"/PreAssembly/assembly"+".tar"+" "+outDir+"/"+outDirsub+"/PreAssembly/assembly"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

# Seqkit: Uncollapse assembled contigs
# INPUT: outDir+"/"+outDirsub+"/PreAssembly/assembly/scaffolds.fasta"
# OUTPUT: outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly.fa"
cmd = "seqkit seq -w 0 "+outDir+"/"+outDirsub+"/PreAssembly/assembly/scaffolds.fasta"+" > "+outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly.fa"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

# Remove contigs shorter than 500 bp
# INPUT: outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly.fa"
# OUTPUT: outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.fa"
l = []
f = open(outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly.fa","r")
for line in f:
    l.append(line.strip()) 

k_500 = []
for i in range(0, len(l)):
    if l[i][0] == ">":
        if len(l[i+1]) >= 500:
            k_500.append(l[i])
            k_500.append(l[i+1])

if len(k_500) != 0: # If there is contig longer than 500 bp 
    o = open(outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.fa","w")
    for i in k_500:
        o.write(i+"\n")
    o.close()
    
    # DIAMOND: Align contigs to nr
    # INPUT: outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.fa"
    # OUTPUT: outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.blast"
    cmd = "diamond blastx -p"+" "+threads+" "+"-d nr.dmnd -q "+outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.fa"+" --long-reads -e 1e-5 --id 50 -b 12 --top 10 --out "+outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.blast"+" -f 6"
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")

    # MEGAN6: Assign contigs to taxa
    # INPUT: outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.blast"
    # OUTPUT: outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.rma"
    #         outDir+"/"+outDirsub+"/PreAssembly/taxon_assembly_total.txt" (Three-column tabular table: rank, taxon path, contig count)
    #         outDir+"/"+outDirsub+"/PreAssembly/taxon_ID.txt" (Three-column tabular table: rank, txid, contig count)
    cmd = "megan/tools/blast2rma -i"+" "+outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.blast"+" -o "+outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.rma"+" -f BlastTab -bm BlastX --paired false -lg true -mdb megan-map-Jul2020-2.db -t 32 -ram readCount -ms 50 -me 1e-5 -mpi 50 -top 10 -supp 0"
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")
    cmd = "megan/tools/rma2info -i"+" "+outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.rma"+" -o "+outDir+"/"+outDirsub+"/PreAssembly/taxon_assembly_total.txt"+" "+"-c2c Taxonomy -n true -p true -r true -mro true -u false"
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")
    cmd = "megan/tools/rma2info -i"+" "+outDir+"/"+outDirsub+"/PreAssembly/"+sample+"_assembly_500bp.rma"+" -o "+outDir+"/"+outDirsub+"/PreAssembly/taxon_ID.txt"+" "+"-c2c Taxonomy -n false -p false -r true -mro true -u false"
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")
else:
    # Assembling failed
    print("No contigs longer than 500 bp.")
    print("Assembling failed.")

#########################################################################
# reference database construction

if not os.path.exists(outDir+"/"+outDirsub+"/Genomes"):
    os.system("mkdir "+outDir+"/"+outDirsub+"/Genomes")

# Get species txid found from assembly
if os.path.exists(outDir+"/"+outDirsub+"/PreAssembly/taxon_ID.txt"):
    taxonID = outDir+"/"+outDirsub+"/PreAssembly/taxon_ID.txt"
    f = open(taxonID,"r")
    ID_species = []
    for line in f:
        line = line.strip().split("\t")
        if line[0] == "S":
            ID_species.append(str(line[1]))
    f.close()

    # files of paths
    total_fna = open(outDir+"/"+outDirsub+"/Genomes/total_fna_list.txt","w") # Absolute paths to fna
    gff = open(outDir+"/"+outDirsub+"/Genomes/total_gff_list.txt","w") # Absolute paths to gff
    faa = open(outDir+"/"+outDirsub+"/Genomes/total_faa_list.txt","w") # Absolute paths to faa

    for txid in ID_species:
        if os.path.exists(outDir+"/"+outDirsub+"/Genomes/"+txid):
            os.system("rm -r "+outDir+"/"+outDirsub+"/Genomes/"+txid)
        if os.path.exists(outDir+"/"+outDirsub+"/Genomes/"+txid+".zip"):
            os.system("rm "+outDir+"/"+outDirsub+"/Genomes/"+txid+".zip")

        # If the genomic dataset of a species has already bee downloaded, copy it to outDir+"/"+outDirsub+"/Genomes/"
        percent = float(sample_percent)
        i = 0.1
        while i < percent:
            if os.path.exists(outDir+"/"+str(i)+"_"+repeat+"/Genomes/"+txid):
                os.system("cp -r "+outDir+"/"+str(i)+"_"+repeat+"/Genomes/"+txid+" "+outDir+"/"+outDirsub+"/Genomes/")
                os.system("cp "+outDir+"/"+str(i)+"_"+repeat+"/Genomes/"+txid+".zip"+" "+outDir+"/"+outDirsub+"/Genomes/")
                print("Dataset of "+txid+" already exists in "+outDir+"/"+str(i)+"_"+repeat+"/Genomes/")
                break
            else:
                i = i+0.1

        if not os.path.exists(outDir+"/"+outDirsub+"/Genomes/"+txid+".zip") and not os.path.exists(outDir+"/"+outDirsub+"/Genomes/"+txid):
            # Get reference genomes in RefSeq (GCF)
            os.system("datasets download genome taxon "+txid+" --filename "+outDir+"/"+outDirsub+"/Genomes/"+txid+".zip"+" --exclude-rna --reference --refseq")
        if not os.path.exists(outDir+"/"+outDirsub+"/Genomes/"+txid+".zip") and not os.path.exists(outDir+"/"+outDirsub+"/Genomes/"+txid):
            # If no reference genomes found in RefSeq, try GenBank (GCA)
            os.system("datasets download genome taxon "+txid+" --filename "+outDir+"/"+outDirsub+"/Genomes/"+txid+".zip"+" --exclude-rna --reference")
        if os.path.exists(outDir+"/"+outDirsub+"/Genomes/"+txid+".zip") and not os.path.exists(outDir+"/"+outDirsub+"/Genomes/"+txid):
            # unzip genome directory
            os.system("unzip "+outDir+"/"+outDirsub+"/Genomes/"+txid+".zip"+" -d "+outDir+"/"+outDirsub+"/Genomes/"+txid)
            
        for tup in os.walk(outDir+"/"+outDirsub+"/Genomes/"+txid):
            if tup[1] == []:
                Str = []
                for i in tup[2]:
                    Str.append(os.path.splitext(i)[1])
                if ".faa" in Str:
                    for i in tup[2]:
                        file = tup[0]+"/"+i
                        if file[-3:] == "fna":
                            total_fna.write(file+"\n") # Absolute paths to fna
                        elif file[-3:] == "gff":
                            gff.write(file+"\n") # Absolute paths to gff
                        elif file[-3:] == "faa":
                            faa.write(file+"\n") # Absolute paths to faa
                else:
                    print("Unannotated genome: "+txid)
                    os.system("rm -r "+outDir+"/"+outDirsub+"/Genomes/"+txid)
                    os.system("rm "+outDir+"/"+outDirsub+"/Genomes/"+txid+".zip")
    total_fna.close()
    gff.close()
    faa.close()
print("Done")
print("#########################################################################")

#########################################################################
# Fragment recruitment
if not os.path.exists(outDir+"/"+outDirsub+"/FirstRound"):
    os.system("mkdir "+outDir+"/"+outDirsub+"/FirstRound")

if sample_percent != "1":
    Data1 = outDir+"/"+outDirsub+"/"+sample+"_"+sample_percent+"_1.fq"
    Data2 = outDir+"/"+outDirsub+"/"+sample+"_"+sample_percent+"_2.fq"
else:
    Data1 = outDir+"/"+sample+"_Host.sam.bam_unmapped.1.fq"
    Data2 = outDir+"/"+sample+"_Host.sam.bam_unmapped.2.fq"

l = ""
if os.path.exists(outDir+"/"+outDirsub+"/Genomes/total_fna_list.txt"):
    f = open(outDir+"/"+outDirsub+"/Genomes/total_fna_list.txt","r")
    for line in f:
        line = line.strip()
        l = l+line+","
    l = l[:-1]
    f.close()

if len(l) != 0:
    if not os.path.exists(outDir+"/"+outDirsub+"/Genomes/Reference.1.bt2") and not os.path.exists(outDir+"/"+outDirsub+"/Genomes/Reference.1.bt2l"):
        # Bowtie2: Build index with basename "Reference"
        # INPUT: listed in l
        # OUTPUT: outDir+"/"+outDirsub+"/Genomes/Reference.*.bt2(l)"
        cmd = "bowtie2-build "+l+" "+outDir+"/"+outDirsub+"/Genomes/Reference"
        print("Command:")
        print(cmd)
        os.system(cmd)
        print("Done")

    # Bowtie2: Map reads to reference genomes (Index: outDir+"/"+sample_percent+"/Genomes/Reference.*.bt2(l))
    # SAMtools: Convert SAM to BAM
    # INPUT: Data1
    #        Data2
    # OUTPUT: outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam"
    cmd = "bowtie2 --sensitive --end-to-end -p "+threads+" -x "+outDir+"/"+outDirsub+"/Genomes/Reference"+" -1 "+Data1+" -2 "+Data2+" -S "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam"
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")
    cmd = "samtools view -@ "+threads+" -b -S "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam"+" > "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam"
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")

    # Remove SAM
    os.system("rm "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam")

    # SAMtools: Extract BAM of unmapped reads
    #           Convert BAM to fq
    # INPUT: outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam"+".bam"
    # OUTPUT: outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped"
    #         outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam"+".bam_unmapped.1.fq
    #         outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam"+".bam_unmapped.2.fq
    cmd = "samtools view -@ "+threads+" -u -f 12 "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam"+" > "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped"
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")
    cmd = "samtools fastq -1 "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.1.fq -2 "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.2.fq "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped"+" -@ "+threads
    print("Command:")
    print(cmd)
    os.system(cmd)
    print("Done")

    # Unmapped reads
    fq1 = outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.1.fq"
    fq2 = outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.2.fq"
else:
    fq1 = Data1
    fq2 = Data2

#########################################################################
# Assembly-independent species identification

if sample_percent != "1":
    Data1 = outDir+"/"+outDirsub+"/"+sample+"_"+sample_percent+"_1.fq"
    Data2 = outDir+"/"+outDirsub+"/"+sample+"_"+sample_percent+"_2.fq"
else:
    Data1 = outDir+"/"+sample+"_Host.sam.bam_unmapped.1.fq"
    Data2 = outDir+"/"+sample+"_Host.sam.bam_unmapped.2.fq"

l = ""
if os.path.exists(outDir+"/"+outDirsub+"/Genomes/total_fna_list.txt"):
    f = open(outDir+"/"+outDirsub+"/Genomes/total_fna_list.txt","r")
    for line in f:
        line = line.strip()
        l = l+line+","
    l = l[:-1]
    f.close()

if len(l) != 0:
    fq1 = outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.1.fq"
    fq2 = outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.2.fq"
else:
    fq1 = Data1
    fq2 = Data2

# DIAMOND: Align unmapped reads to nr
# INPUT: fq1, fq2
# OUTPUT: outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.1.blast"
#         outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.2.blast"
cmd = "diamond blastx -p"+" "+threads+" "+"-d nr.dmnd -q "+fq1+" -e 1e-5 --id 50 -b 12 --top 10 --out "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.1.blast"+" -f 6"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")
cmd = "diamond blastx -p"+" "+threads+" "+"-d nr.dmnd -q "+fq2+" -e 1e-5 --id 50 -b 12 --top 10 --out "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.2.blast"+" -f 6"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

# MEGAN6: Assign unmapped reads to taxa
# INPUT: outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.1.blast"
#        outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.2.blast"
# OUTPUT: outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.rma"
#         outDir+"/"+outDirsub+"/FirstRound/taxon_unmapped_total.txt"
#         outDir+"/"+outDirsub+"/FirstRound/taxon_ID.txt"
cmd = "megan/tools/blast2rma -i"+" "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.1.blast"+" "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.2.blast"+" "+"-o"+" "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.rma"+" -f BlastTab -bm BlastX --paired true -lg false -mdb megan-map-Jul2020-2.db -t 32 -ram readCount -ms 50 -me 1e-5 -mpi 50 -top 10 -supp 0.1"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")
cmd = "megan/tools/rma2info -i"+" "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.rma"+" -o "+outDir+"/"+outDirsub+"/FirstRound/taxon_unmapped_total.txt"+" "+"-c2c Taxonomy -n true -p true -r true -mro true -u false"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")
cmd = "megan/tools/rma2info -i"+" "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.rma"+" -o "+outDir+"/"+outDirsub+"/FirstRound/taxon_ID.txt"+" "+"-c2c Taxonomy -n false -p false -r true -mro true -u false"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

#########################################################################
# functional annotation

if not os.path.exists(outDir+"/"+outDirsub+"/FunctionAnnotation"):
    os.system("mkdir "+outDir+"/"+outDirsub+"/FunctionAnnotation")
if not os.path.exists(outDir+"/"+outDirsub+"/FunctionAnnotation/CDS"):
    os.system("mkdir "+outDir+"/"+sample_percent+"/FunctionAnnotation/CDS")

f = pd.read_table(outDir+"/"+outDirsub+"/PreAssembly/taxon_ID.txt",header=None,sep="\t")
f = f[f[0]=="S"][1].values.tolist() # list of species txid

Assembly2Txid = open(outDir+"/"+outDirsub+"/Assembly2Txid.txt","w")
for identifier in f:
    gffs_str = os.popen("grep "+"\"/"+str(identifier)+"/\""+" "+outDir+"/"+outDirsub+"/Genomes/total_gff_list.txt").read().strip()
    if gffs_str != "":
        gffs = gffs_str.split("\n")
        for gff in gffs:
            # line = line.split("/")[-6:]
            # gff = outDir+"/"+sample_percent+"/"
            # for i in line:
            #     gff = gff+i+"/"
            # gff = gff[:-1]

            ##############################################################################
            ## Extract txid and GCF id from absolute path of gff
            txid = gff.split("/")[10]
            GCF = gff.split("/")[13]
            ## Extract txid and GCF id from absolute path of gff
            ###############################################################################

            Assembly2Txid.write(GCF+"\t"+txid+"\n")

            # Convert gff to bed of CDS
            cmd = "awk -v OFS=\'\\t\' -v FS=\'\\t\' \'$3 == \"CDS\" {print $1, $4-1, $5, \".\",\".\",$7}' "+gff+" > "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS/"+GCF+"_"+txid+".bed"
            print("Command:")
            print(cmd)
            os.system(cmd)
            os.system("cat "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS/"+GCF+"_"+txid+".bed"+">>"+outDir+"/"+outDirsub+"/FunctionAnnotation/total_CDS.bed")
            
            # Merge fna files of one GCF
            fna = os.popen("grep \'"+GCF+"\'"+" "+outDir+"/"+outDirsub+"/Genomes/total_fna_list.txt").read().split("\n")[:-1]
            for fna_path in fna:
                # fna_path = outDir+"/"+sample_percent+"/"
                # file = f.split("/")[-6:]
                # for i in file:
                #     fna_path = fna_path+i+"/"
                # fna_path = fna_path[:-1]
                os.system("cat "+fna_path+" >> "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS/"+GCF+"_"+txid+".fna")
            
            # Extract CDS
            cmd = "bedtools getfasta"+" -fi "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS/"+GCF+"_"+txid+".fna"+" -bed "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS/"+GCF+"_"+txid+".bed"+" -s "+">"+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS/"+GCF+"_"+txid+"_CDS.fasta"
            print("Command:")
            print(cmd)
            os.system(cmd)
            os.system("cat "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS/"+GCF+"_"+txid+"_CDS.fasta"+">>"+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS.fasta")

            # Taxonomy information of CDS
            intervals = pd.read_csv(outDir+"/"+outDirsub+"/FunctionAnnotation/CDS/"+GCF+"_"+txid+".bed",header=None,sep="\t")
            AssemblyID = [GCF]*len(intervals)
            Species = [txid]*len(intervals)
            intervals["AssemblyID"] = AssemblyID
            intervals["species"] = Species
            intervals.to_csv(outDir+"/"+outDirsub+"/FunctionAnnotation/CDS/"+GCF+"_"+txid+"_info.txt",sep="\t",index=False,header=False)
            os.system("cat "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS/"+GCF+"_"+txid+"_info.txt"+">>"+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS_info.txt")

Assembly2Txid.close()

# Compute coverage
cmd = "bedtools coverage"+" "+"-a"+" "+outDir+"/"+outDirsub+"/FunctionAnnotation/total_CDS.bed"+" "+"-b"+" "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam"+" > "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDSquantify.txt"
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

# Extract CDS with non-zero coverage
from Bio import SeqIO

if os.path.exists(outDir+"/"+outDirsub+"/FunctionAnnotation/CDS_covered.fasta"):
    os.system("rm "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS_covered.fasta")

CDSquantify = pd.read_table(outDir+"/"+outDirsub+"/FunctionAnnotation/CDSquantify.txt",sep="\t",header=None) #fileds: nucleotide ID, start, end, name, score, strand, read count, read length, seq length, coverage
CDSquantify = CDSquantify[CDSquantify[6]!=0]
CDSquantify.to_csv(outDir+"/"+outDirsub+"/FunctionAnnotation/CDSquantify_covered.txt",header=False,index=False,sep="\t")

CDS_ID = CDSquantify.apply(lambda x:x[0]+":"+str(x[1])+"-"+str(x[2])+"("+x[5]+")",axis=1).values.tolist()
CDS_ID = set(CDS_ID)

with open(outDir+"/"+outDirsub+"/FunctionAnnotation/CDS_covered.fasta",'w') as fp:
    for seq in SeqIO.parse(outDir+"/"+outDirsub+"/FunctionAnnotation/CDS.fasta", "fasta"):
        if seq.id in CDS_ID: 
            fp.write('>')
            fp.write(str(seq.id)+"\n")
            fp.write(str(seq.seq)+"\n")

cmd = "eggnog-mapper/emapper.py"+" "+"-m diamond --itype CDS"+" "+"-i"+" "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS_covered.fasta"+" "+"-o"+" "+outDir+"/"+outDirsub+"/FunctionAnnotation/CDS_annotation.txt --no_file_comments --block_size 3000 --cpu "+threads
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

# if os.path.exists(outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.1.fq.gz"):
#     cmd = "gzip -d "+outDir+"/"+sample_percent+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.1.fq.gz"
#     os.system(cmd)
#     cmd = "gzip -d "+outDir+"/"+sample_percent+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.2.fq.gz"
#     os.system(cmd)

cmd = "eggnog-mapper/emapper.py"+" "+"-m diamond --itype CDS"+" "+"-i"+" "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.1.fq"+" "+"-o"+" "+outDir+"/"+outDirsub+"/FunctionAnnotation/forward_annotation.txt --no_file_comments --block_size 3000 --cpu "+threads
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

cmd = "eggnog-mapper/emapper.py"+" "+"-m diamond --itype CDS"+" "+"-i"+" "+outDir+"/"+outDirsub+"/FirstRound/"+sample+"_Ref.sam.bam_unmapped.2.fq"+" "+"-o"+" "+outDir+"/"+outDirsub+"/FunctionAnnotation/reverse_annotation.txt --no_file_comments --block_size 3000 --cpu "+threads
print("Command:")
print(cmd)
os.system(cmd)
print("Done")

#########################################################################
# annotation integration

dire = outDir+"/"+outDirsub+"/FunctionAnnotation"

# Merge taxon and abundance table of CDS
CDS_quantify = pd.read_table(dire+"/CDSquantify.txt",sep="\t",header=None) #fileds: nucleotide ID, start, end, name, score, strand, read count, read length, seq length, coverage
CDS_txid = pd.read_table(dire+"/CDS_info.txt",sep="\t",header=None) # fileds: nucleotide ID, start, end, name, score, strand, assembly ID, txid
CDS_txid.columns = ["SeqID","start","end","CDSname","score","strand","AssemblyID","txid"]
CDS_txid["ReadCount"] = CDS_quantify[6]
CDS_txid["Coverage"] = CDS_quantify[9]
CDS_txid = CDS_txid[CDS_txid["ReadCount"]!=0]
CDS_txid.to_csv(dire+"/CDS_txid_quantify.txt",sep="\t",index=False,header=True) # header: "SeqID","start","end","CDSname","score","strand","AssemblyID","txid", "ReadCount", "Coverage"

# Abundance of taxa identified
CDS = pd.read_table(dire+"/CDS_txid_quantify.txt",sep="\t",header=0) # header: "SeqID","start","end","CDSname","score","strand","AssemblyID","txid", "ReadCount", "Coverage"
read = pd.read_table(dire+"/../FirstRound/taxon_ID.txt",sep="\t",header=None) # fields: rank (S,G), txid, read count (pair)

txid_CDSquantify = CDS["ReadCount"].groupby(CDS["txid"]).sum() # read count
txid = CDS["txid"].values.tolist()+read[1].values.tolist()
txid = list(set(txid))

path = []
rank = []
for i in txid:
    rank.append(tx.RankByTaxid(i))
    path_id = tx.PathByTaxid(i)
    path_name = ""
    for j in path_id:
        path_name = path_name+"["+tx.RankByTaxid(j)+"]"+" "+tx.NameByTaxid(j)+";"
    path.append(path_name)

txid2path = pd.DataFrame({"txid":txid,"path":path})
txid2CDSquantify = pd.DataFrame({"txid":txid_CDSquantify.index,"CDS":txid_CDSquantify.values})
txid2readquantify = pd.DataFrame({"txid":read[1].values,"Read":2*read[2].values})

f = pd.merge(txid2CDSquantify,txid2readquantify,on="txid",how="outer")
f = pd.merge(f,txid2path,on="txid",how="outer")
f = f.fillna(0)
f["TotalCount"] = f["CDS"]+f["Read"]

f.to_csv(dire+"/TaxonQuantification.txt",header=True,sep="\t",index=False) # header: txid, CDS, Read, path, TotalCount

# merge annotations
read2txid = pd.read_table(dire+"/read_txid.txt",header=None,sep="\t") # readID, rank, txid
CDS2txid = pd.read_table(dire+"/CDS_txid_quantify.txt",header=0,sep="\t")
txid2path = pd.read_table(dire+"/TaxonQuantification.txt",header=0,sep="\t")

def CDSName(series):
    """
    Take row of bed as input, fill column of sequence name, return a row.
    """
    series["CDSname"] = str(series["SeqID"])+":"+str(series["start"])+"-"+str(series["end"])+"("+str(series["strand"])+")"
    return series
CDS2txid = CDS2txid.apply(func=CDSName,axis=1,raw=False)


def IDConvert(series):
    """
    Convert read identifier to show if it is forward or reverse.
    """
    if series["SeqType"]=="forward":
        series["SeqID"] = str(series["SeqID"])+"_forward"
        return series
    elif series["SeqType"]=="reverse":
        series["SeqID"] = str(series["SeqID"])+"_reverse"
        return series
    else:
        return series

def MergeAnnotation(SeqType):
    """
    Merge taxonomic and functional annotation of sequences of different types.
    """

    Annotations = pd.read_table(dire+"/"+SeqType+"_annotation.txt.emapper.annotations",header=0,sep="\t")

    Seq2KEGG = pd.DataFrame({"SeqID":Annotations["#query"],"KEGG_KO":Annotations["KEGG_ko"]})
    
    if SeqType=="CDS":
        Seq2Taxon = pd.DataFrame({"SeqID":CDS2txid["CDSname"],"txid":CDS2txid["txid"],"ReadCount":CDS2txid["ReadCount"]})
    else:
        Seq2Taxon = pd.DataFrame({"SeqID":read2txid[0],"txid":read2txid[2],"ReadCount":np.repeat(np.array([1]),read2txid[0].size)})
    
    Taxon2Path = pd.DataFrame({"txid":txid2path["txid"],"TxPath":txid2path["path"],"TxGroup":txid2path["Group"]})

    ret = pd.merge(Seq2KEGG,Seq2Taxon,on="SeqID",how="outer")
    ret = pd.merge(ret,Taxon2Path,on="txid",how="left")
    ret["SeqType"] = np.repeat(np.array([SeqType]),ret["SeqID"].size)

    ret = ret.apply(func=IDConvert,axis=1,raw=False)

    return ret

CDS = MergeAnnotation("CDS")
forward = MergeAnnotation("forward")
reverse = MergeAnnotation("reverse")

final = pd.concat([CDS,forward,reverse],axis=0,join="outer")

if os.path.exists(dire+"/SeqAnnotations.txt"):
    os.system("rm "+dire+"/SeqAnnotations.txt")

final.to_csv(dire+"/SeqAnnotations.txt",header=True,sep="\t",index=False)

data = pd.read_table(dire+"/TaxonQuantification.txt",header=0,sep="\t") # header: txid, CDS, Read, path, TotalCount, Group
def RankQuantify(rank):
    """
    This function take taxonomic rank (i.e. phylum, class) as argument.

    OUTPUT:
    outDir+"/"+sample_percent+"/FunctionAnnotation/"+rank+"Quantify.txt" (tabular, "rank" can be phylum, class, order, family, genus, species, header: Name, CDS, Read, TotalCount, Rel_Abundance)
    """
    pattern = "\["+rank+"\] [A-Za-z <>.0-9]*;"
    names = []
    for path in data["path"].values:
        name = re.findall(pattern,path)
        if name == []:
            names.append(0)
        else:
            for j in name:
                j = j.split("]")[1][1:-1]
                names.append(j)
                
    Rankq = pd.DataFrame({"Name":names})
    Rankq["Group"] = data["Group"].values
    Rankq["CDS"] = data["CDS"].values
    Rankq["Read"] = data["Read"].values
    Rankq["TotalCount"] = data["TotalCount"]
    Rankq = Rankq[Rankq["Name"]!=0]
 

    CDS = Rankq["CDS"].groupby(Rankq["Name"]).sum()
    Read = Rankq["Read"].groupby(Rankq["Name"]).sum()
    Total = Rankq["TotalCount"].groupby(Rankq["Name"]).sum()

    out = pd.DataFrame({"Name":CDS.index.tolist(),"CDS":CDS.values.tolist(),"Read":Read.values.tolist(),"TotalCount":Total.values.tolist()})
    out["Rel_Abundance"] = out["TotalCount"]/out["TotalCount"].sum()

    Group = []
    for name in out["Name"].values:
        group = Rankq[Rankq["Name"]==name]["Group"].tolist()[0]
        Group.append(group)
    out["Group"] = Group

    out.to_csv(dire+"/"+rank+"Quantify.txt",header=True,index=False,sep="\t")
    return 0

RankQuantify("phylum")
RankQuantify("class")
RankQuantify("order")
RankQuantify("family")
RankQuantify("genus")
RankQuantify("species")