#!/usr/bin/env python3
"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: sysargv.py
Des: Exemplify use of sys and argv
Usage: python3 sysargv.py (in terminal)
Dependencies: sys
Date: Oct, 2021
"""

import sys
print("This is the name of the script: ", sys.argv[0])
print("Number of arguments in the system: ", len(sys.argv))
print("The arguments are: " , str(sys.argv))