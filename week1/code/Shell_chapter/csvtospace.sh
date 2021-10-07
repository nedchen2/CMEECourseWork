#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   csvtospace.sh
# Description: 
#   shell script that takes a comma separated file and converts it to a space separated values file.
# Usage:
#   bash csvtospace.sh <File with a comma separated values  > 
# Arguments: 
#   1 -> Files with a comma separated values 
# Date: Oct 2021
# -h        Show this message.

help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}

if [[ $# == 0 ]] || [[ "$1" == "-h" ]]; then
	help
	exit 1
fi

echo "Creating a space delimited version of $1 ... in original directory"
#extract the path
Pathnew=`echo "$1" | sed "s/.txt/.csv/g"`
touch $Pathnew
cat $1 | tr -s "," " " >> $Pathnew
echo "Done!"
exit