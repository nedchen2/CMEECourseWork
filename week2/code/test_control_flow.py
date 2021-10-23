#!/usr/bin/env python3
"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: test_control_flow.py
Des: Some functions exemplifying the use of control statements
Usage: python3 test_control_flow.py (in terminal)
Dependencies: sys, doctest
Date: Oct, 2021
"""
#docstrings are considered part of the running code (normal comments are
#stripped). Hence, you can access your docstrings at run time.

__author__ = 'Congjia Chen (congjia.chen21@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import doctest # Import the doctest module

def even_or_odd(x=0):
    """
    Args:
        x : A integer
    
    Returns: 
        whether a number x is even or odd.
    
    Raises:
        None
      
    >>> even_or_odd(10)
    '10 is Even!'
    
    >>> even_or_odd(5)
    '5 is Odd!'
    
    whenever a float is provided, then the closest integer is used:    
    >>> even_or_odd(3.2)
    '3 is Odd!'
    
    in case of negative numbers, the positive is taken:    
    >>> even_or_odd(-2)
    '-2 is Even!'
    
    """
    #Define function to be tested
    if x % 2 == 0:
        return "%d is Even!" % x
    return "%d is Odd!" % x

def main(argv): 
    """
    Returns: 
        The test result of function above from the terminal
    """
    print(even_or_odd(22))
    print(even_or_odd(33))
    return 0

if (__name__ == "__main__"):
    status = main(sys.argv)

doctest.testmod()   # To run with embedded tests

# use "run -m doctest -v your_function_to_test.py"  if you do not want to write doctest.testmod()