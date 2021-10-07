#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   tabtocsv.sh
# Description: 
#   substitute the tabs in the files with commas
# Usage:
#   bash tabtocsv.sh <File with a tab separated values  > 
# Arguments: 
#   1 -> Files with a tab separated values 
# Date: Oct 2021
# -h        Show this message.

help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}

if [[ $# == 0 ]] || [[ "$1" == "-h" ]]; then
	help
	exit 1
fi

echo "Creating a comma delimited version of $1 ..."
Pathnew=`echo "$1" | sed "s/.txt/.csv/g"`
touch $Pathnew
cat $1 | tr -s "\t" "," >> $Pathnew
echo "Done!"

exit