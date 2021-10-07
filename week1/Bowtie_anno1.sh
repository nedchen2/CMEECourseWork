#!/bin/bash
###
### Bowtie_anno
### Author:Congjia.chen
### Usage:
###   sh Bowtie_anno1.sh <species_choice> <FASTA FILE> 
### Options:
###   <FASTA FILE>   Choose the FASTA FILE
###   <species_choice>   Choose species from PLANT ANIMAL or MICRO
###   -h        Show this message.

help() {
	awk -F'### ' '/^###/ { print $2 }' "$0"
}

if [[ $# == 0 ]] || [[ "$1" == "-h" ]]; then
	help
	exit 1
fi
typesp=$1
fasta=$2

module load /home/wangcuihua/1.1.0
export PATH=/data/software/diamond/diamond-v0.9.22/:$PATH
/home/fanyucai/software/Anaconda3/bin/python /public/mid/mxy/GGY/oeanno/oeanno_for_ref.py -n gene -m $typesp -d nr,kegg -c 8 -s $fasta

module load /home/wangcuihua/1.1.0
export PATH=/data/software/diamond/diamond-v0.9.22/:$PATH
/home/fanyucai/software/Anaconda3/bin/python /public/mid/mxy/GGY/oeanno/oeanno_for_ref.py -n gene -m $typesp  -d swissprot,go -c 8 -s $fasta -p /public/cluster2/works/intern/wangcuihua/script/genome/

#后续升级，看能不能选择需不需要注释
