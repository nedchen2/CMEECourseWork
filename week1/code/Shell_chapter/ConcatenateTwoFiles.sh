#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   ConcatenateTwoFiles.sh
# Description: 
#   Merge Two Files together by row
# Usage:
#   bash ConcatenateTwoFiles.sh <File 1> <File 2> <File 3 (merged one)>    
# Arguments: 
#   1 -> files1 to merge, 2 -> files2 to merge, 3 -> Merged file 
# Date: Oct 2021
# -h        Show this message.

help() {
	awk -F'# ' '/^# / { print $2 }' "$0"
}
Filecheck(){
    echo 'Pls check if your file1&2 exist'
}

if [[ $# < 3 ]] || [[ "$1" == "-h" ]]; then
    echo "WARNING: Input Three files separated by space(s),a b would be the files to merge,and the c would be the merged vision"
	help
	exit 1
elif [[ ! -s $1 ]] || [[ ! -s $2 ]] ; then
    Filecheck
    exit 1
fi

#Method 1
cat $1 > $3
cat $2 >> $3
echo "Merged File is"
cat $3



#Method 1
#echo 'Enter Three files separated by space(s),a,b would be the files to merge,and the c would be the merged vision '
#read a b c
#echo 'you entered' $a 'and' $b '. Their merged file is: ' $c ' '
#echo "Merged File is"
#cat $c
#



