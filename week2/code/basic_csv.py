#!/usr/bin/env python3
#############################
# CSV INPUT AND CSV PROCESS
#############################
# Open a file for reading and process it with csv module

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: basic_csv.py
Des: Open a file for reading and process it with csv module
Usage: python3 basic_csv.py (in terminal)
Dep: csv
Date: Oct, 2021
Input: "./data/testcsv.csv"
Output: '../data/bodymass.csv'
"""

import csv
# Read a file containing:
# 'Species','Infraorder','Family','Distribution','Body mass male (Kg)'
with open('../data/testcsv.csv','r') as f:
    csvread = csv.reader(f) #reader can read the csv.seperated by comma
    temp = []
    for row in csvread:
        temp.append(tuple(row))
        print(row)
        print("The species is", row[0])

# write a file containing only species name and Body mass
with open('../data/testcsv.csv','r') as f:
    with open('../data/bodymass.csv','w') as g:
        csvread = csv.reader(f)
        csvwrite = csv.writer(g)
        for row in csvread:
            print(row)
            csvwrite.writerow([row[0], row[4]])