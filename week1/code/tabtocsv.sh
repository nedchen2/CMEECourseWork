#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   tabtocsv.sh
# Description: 
#   substitute the tabs in the files with commas
# Usage:
#   bash tabtocsv.sh <File with a tab separated values (.txt extension) > <Output directory(optional)>
# Arguments: 
#   1 -> Files with a tab separated values , 2 -> Output directory (optional)
# Date: Oct 2021
# -h        Show this message.

if [[ $# = 0 ]] || [[ "$1" == "-h" ]] || [[ $# > 2 ]] ; then
	help
	exit 1
elif [[ ! -s $1 ]] ; then
    echo "[ERROR]: Please check if your file exist"
    exit 1
elif [[ $# = 1 ]] ; then
    echo "Creating a space delimited version of $1 ... in original directory"
    #extract the path
    Pathnew=$(dirname "$1")/$(basename "$1" .txt).csv
    cat $1 | tr -s "\t" "," > $Pathnew
    echo "Done!"
    exit
elif [[ ! -s $2 ]] ; then
    echo "[ERROR]: Please check if your directory exist"
    exit 1
else
    echo "Creating a space delimited version of $1 ... in $2 directory"
    Pathnew=$2/$(basename "$1" .txt).csv
    echo "$Pathnew"
    cat $1 | tr -s "\t" "," > $Pathnew
    echo "Done!"
    exit
fi
