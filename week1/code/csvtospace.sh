#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   csvtospace.sh
# Description: 
#   shell script that takes a comma separated file and converts it to a space separated values file.
# Usage:
#   bash csvtospace.sh <csv File with a comma separated values  > <Output directory(optional)>
# Arguments: 
#   1 -> csv Files with a comma separated values, 2 -> Output directory (optional)
# Date: Oct 2021
# -h        Show this message.

help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}

if [[ $# = 0 ]] || [[ "$1" == "-h" ]] || [[ $# > 2 ]] ; then
	help
	exit 1
elif [[ ! -s $1 ]] ; then
    echo "[ERROR]: Please check if your file exist"
    exit 1
elif [[ $# = 1 ]] ; then
    echo "Creating a space delimited version of $1 ... in original directory"
    #extract the path
    CURRENT_DIR=$(dirname $(readlink -f "$1"))
    echo  "$CURRENT_DIR"
    Pathnew=$CURRENT_DIR/$(basename "$1" .csv).txt
    cat $1 | tr -s "," " " > $Pathnew
    echo "Done!"
    exit
elif [[ ! -s $2 ]] ; then
    echo "[ERROR]: Please check if your directory exist"
    exit 1
else
    echo "Creating a space delimited version of $1 ... in $2 directory"
    Pathnew=$2/$(basename "$1" .csv).txt
    echo "$Pathnew"
    cat $1 | tr -s "," " " > $Pathnew
    echo "Done!"
    exit
fi

