#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   tiff2png.sh
# Description: 
#   convert the tiff file to png in a given directory
# Usage:
#   bash tiff2png.sh <Directory or single file> <Output directory>
# Argument
#    1 -> directory of *.tif, 2 -> Output directory (Necessary)
# Date: Oct 2021
# -h show this message

help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}

if [[ $# = 0 ]] || [[ "$1" == "-h" ]]; then #if-h or no input arguments, print out the help document
	help
	exit 1
elif [[ ! -s $1 ]] ; then
    echo "[ERROR]: Please check if your file directory exist"
    exit 1
elif [[ ! -s $2 ]] ; then
    echo "[ERROR]: Please check if your output directory exist"
    exit 1
elif [[ -f $1 ]] ; then  #if the user input a single file, just convert the single file to a directory
    echo "You are providing a single file. $1 will be converted into png"
    echo "Converting $1"
    convert "$1"  "$2/$(basename "$1" .tif).png"
    echo "Done!"
    exit 1
fi

# if user provide a directory, we will iterate the tif file to png
dir="$1"
outputdir="$2"
echo "We are now working at $dir"
echo "We will output the png file to the $outputdir"
#cd $dir
for f in $dir/*.tif; 
    do  
        echo "Converting $f"; 
        convert "$f"  "$outputdir/$(basename "$f" .tif).png"; 
        echo "Done!"
    done


