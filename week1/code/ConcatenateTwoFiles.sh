#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   ConcatenateTwoFiles.sh
# Description: 
#   Merge Two Files together by row.
# Usage:
#   bash ConcatenateTwoFiles.sh <File 1> <File 2> <File 3 (merged one)>    
# Arguments: 
#   1 -> files1 to be merged, 2 -> files2 to be merged, 3 -> Merged file 
# Date: Oct 2021
# -h        Show this message.

#function to print out the help document
help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}

if [[ $# != 3 ]] || [[ "$1" == "-h" ]]; then # if-h or no input arguments, print out the help document
    echo "[ERROR]: Input Three files,1 2 would be the files to be merged,and the 3 would be the merged version"
	help
	exit 1
elif [[ ! -s $1 ]] || [[ ! -s $2 ]] ; then
    echo "[ERROR]: Please check if your file1 or 2 exist"
    exit 1
fi

#Method 1
cat $1 > $3
cat $2 >> $3
echo "Merged File is"
cat $3



