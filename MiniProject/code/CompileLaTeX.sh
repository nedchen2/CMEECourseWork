#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   CompileLaTex.sh
# Description: 
#   render the .tex file to .pdf
# Usage:
#   bash CompileLaTex.sh < File.tex > <Output directory(optional)>
# Arguments: 
#   1 -> LaTex file, 2 -> Output directory(optional) default [../results]
# Date: Oct 2021
# -h        Show this message.

#function to print out the help document
help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}

if [[ $# = 0 ]] || [[ "$1" == "-h" ]] || [[ $# > 2 ]] ; then  #if -h or no arguments input, print out the help document
	help
	exit 1
elif [[ ! -s $1 ]] ; then 
    echo "[ERROR]: Please check if your file exist"
    exit 1
elif [[ $# = 1 ]] ; then #if no output directory provided, it will use the directory which are the same as the input
	newname=$(basename "$1" .tex)
	pdflatex $newname.tex
	bibtex $newname
	pdflatex $newname.tex
	pdflatex $newname.tex
	#mv the result to the result file
	echo
	echo "[WARNING] You have not defined the output directory. File will be output in results"
	mv $newname.pdf ../results/
	evince ../results/$newname.pdf &
    #Cleanup
	rm *.aux
	rm *.log
	rm *.bbl
	rm *.blg
    exit
elif [[ ! -s $2 ]] ; then
    echo "[ERROR]: Please check if your directory exist"
    exit 1
else    #if output directory is provided, it will be used as output directory,
	newname=$(basename "$1" .tex)
	pdflatex $newname.tex
	bibtex $newname
	pdflatex $newname.tex
	pdflatex $newname.tex
	#mv the result to the result file
	echo 
	echo "File will be output in $2"
	mv $newname.pdf $2
	evince $2/$newname.pdf &
    #Cleanup
	rm *.aux
	rm *.log
	rm *.bbl
	rm *.blg
    exit
fi


