#!/bin/bash

#Author: Group3
#Script: run_get_TreeHeight.sh
#Des: Runs get_TreeHeight.r and get_TreeHeight.py on trees.csv from bash
#Usage: bash run_get_TreeHeight.sh  (in terminal)
#Dep: 

# Run get_TreeHieght R script on trees.csv
Rscript get_TreeHeight.R ../data/trees.csv 

# Run get_TreeHieght Python script on trees.csv
python3 get_TreeHeight.py ../data/trees.csv 