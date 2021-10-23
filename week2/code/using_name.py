#!/usr/bin/env python3
# Filename: using_name.py

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: using_name.py
Description: The program is used to test the use of python __name__ 
Usage: python3 using_name.py (in terminal)
Date: Oct, 2021
"""

if __name__ == '__main__':
    print('This program is being run by itself')
else:
    print('I am being imported from another module')

print("This module's name is: " + __name__)