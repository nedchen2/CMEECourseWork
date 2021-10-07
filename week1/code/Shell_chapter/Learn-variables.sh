#!/bin/sh

echo "File Name: $0"
echo "First Parameter : $1"
echo "Second Parameter : $2"
echo "Quoted Values: $@"
echo "Quoted Values: $*"
echo "Total Number of Parameters : $#"
echo  "$?" # As a rule, most commands return an exit status of 0 if they were successful, and 1 if they were unsuccessful.