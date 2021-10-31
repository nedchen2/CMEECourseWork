#!/bin/bash
# Author: Congjia.Chen21@imperial.ac.uk
# Script: run_get_TreeHeight.sh
# Desc: Example to run get_TreeHeight.R
# Arguments: none
# Date: Oct 2021

Rscript get_TreeHeight.R ../data/trees.csv
python3 get_TreeHeight.py ../data/trees.csv
