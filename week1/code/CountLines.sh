#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   CountLines.sh
# Description: 
#   count lines number
# Usage:
#   bash CountLines.sh <A File or directory> 
# Arguments: 
#   1 -> A File or directory
# Date: Oct 2021
# -h        Show this message.

#function to print out the help document
help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}

if [[ $# != 1 ]] || [[ "$1" == "-h" ]]; then #if-h or no input arguments, print out the help document
	help
	exit 1
elif [[ ! -s $1 ]] ; then
    echo "[ERROR]: Please check if your file exist"
    exit 1
elif [[ -d $1 ]]; then
	echo "You have provided a directory here. We will count all files with extensions"
	wc -l $1/*.*
	exit 1
fi

NumLines=`wc -l < $1` 
echo "The file $1 has $NumLines lines"
echo