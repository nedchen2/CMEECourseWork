#!/usr/bin/env python3
#############################
# FILE OUTPUT
#############################
# Save the elements of a list to a file

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: basic_io2.py
Des: Examplify output file by write method
Usage: python3 basic_io2.py (in terminal)
Date: Oct, 2021
Output: "../sandbox/testout.txt"
"""

list_to_save = range(100)

f = open('../sandbox/testout.txt','w')
for i in list_to_save:
    f.write(str(i) + '\n') ## Add a new line at the end

f.close()