#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: 
#   variables.sh
# Description: 
#   Practice for reading the variable
# Usage:
#   bash variables.sh
# Arguments: 
#   None
# Date: Oct 2021

# Shows the use of variables
MyVar='some string'
echo 'the current value of the variable is' $MyVar
echo 'Please enter a new string'
read MyVar
echo 'the current value of the variable is' $MyVar

## Reading multiple values
echo 'Enter two numbers separated by space(s)'
read a b
if [[ -n $a ]] && [[ -n $b ]]; then ##see if the variable is number
    echo 'you entered' $a 'and' $b '. Their sum is:'
    mysum=`expr $a + $b`
    echo $mysum
else
    echo "pls enter two numbers"
fi

