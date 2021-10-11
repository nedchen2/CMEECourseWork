#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   CountLines.sh
# Description: 
#   count lines number
# Usage:
#   bash CountLines.sh <A File > 
# Arguments: 
#   1 -> A File
# Date: Oct 2021
# -h        Show this message.

help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}

if [[ $# != 1 ]] || [[ "$1" == "-h" ]]; then
	help
	exit 1
elif [[ ! -s $1 ]] ; then
    echo "[ERROR]: Please check if your file exist"
    exit 1
fi

NumLines=`wc -l < $1` 
echo "The file $1 has $NumLines lines"
echo