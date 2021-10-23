#!/usr/bin/env python3
# FOR loops in Python

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: loops.py
Des: Examplify loops in python
Usage: python3 loops.py (in terminal)
Date: Oct, 2021
"""
#Print 0,1,2,3,4
for i in range(5):
    print(i)

#Print every elements in my_list
my_list = [0, 2, "geronimo!", 3.0, True, False]
for k in my_list:
    print(k)

#Calculate the sum of numbers in summands
total = 0
summands = [0, 1, 11, 111, 1111]
for s in summands:
    total = total + s
    print(total)

# WHILE loops  in Python
z = 0
while z < 100:
    z = z + 1
    print(z)