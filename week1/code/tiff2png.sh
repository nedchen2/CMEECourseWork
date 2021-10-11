#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   tiff2png.sh
# Description: 
#   convert the tiff file to png in a given directory
# Usage:
#   bash tiff2png.sh <Directory> 
# Argument
#    1 -> directory of *.tif
# Date: Oct 2021

help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}

if [[ $# != 1 ]] || [[ "$1" == "-h" ]]; then
    echo "[ERROR]: Directory not provided"
	help
	exit 1
elif [[ ! -s $1 ]] ; then
    echo "[ERROR]: Please check if your directory exist"
    exit 1
fi

dir="$1"
echo "We are now working at $dir"
cd $dir
for f in *.tif; 
    do  
        echo "Converting $f"; 
        convert "$f"  "$(basename "$f" .tif).png"; 
        echo "Done!"
    done
