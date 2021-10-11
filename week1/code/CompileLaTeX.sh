#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   CompileLaTex.sh
# Description: 
#   render the .tex file to .pdf
# Usage:
#   bash CompileLaTex.sh < File.tex > 
# Arguments: 
#   1 -> LaTex file
# Date: Oct 2021
# -h        Show this message.

help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}

if [[ $# != 1 ]] || [[ "$1" == "-h" ]]; then
    echo "[ERROR]: Please Input one file"
	help
	exit 1
fi

newname=$(basename "$1" .tex)

pdflatex $newname.tex
bibtex $newname
pdflatex $newname.tex
pdflatex $newname.tex
#mv the result to the result file
mv $newname.pdf ../results/
evince ../results/$newname.pdf &



# Cleanup
rm *.aux
rm *.log
rm *.bbl
rm *.blg

