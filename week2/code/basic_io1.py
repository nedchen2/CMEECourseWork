#!/usr/bin/env python3
#############################
# FILE INPUT
#############################
# Open a file for reading

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: basic_io1.py
Des: Examplify input file by with open method
Usage: python3 basic_io1.py (in terminal)
Date: Oct, 2021
Input: "../sandbox/test.txt"
"""

with open('../sandbox/test.txt', 'r') as f:
    # use "implicit" for loop:
    # if the object is a file, python will cycle over lines
    for line in f:
        print(line)

# Once you drop out of the with, the file is automatically closed

# Same example, skip blank lines
with open('../sandbox/test.txt', 'r') as f:
    for line in f:
        if len(line.strip()) > 0:
            print(line)