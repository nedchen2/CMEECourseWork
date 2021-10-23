#!/usr/bin/env python3

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: control_flow.py
Des: Some functions exemplifying the use of control statements
Usage: python3 control_flow.py (in terminal)
Dep: sys
Date: Oct, 2021
"""

__author__ = 'Congjia Chen (congjia.chen21@imperial.ac.uk)'
__version__ = '0.0.1'

import sys

def even_or_odd(x=0): # if not specified, x should take value 0.

    """
    Args:
        x : A integer

    Return:
        Find whether a number x is even or odd.

    """
    if x % 2 == 0: #The conditional if
        return "%d is Even!" % x
    return "%d is Odd!" % x

def largest_divisor_five(x=120):
    """
    Args:
        x : A integer

    Returns:
        Find which is the largest divisor of x among 2,3,4,5.
    
    """
    largest = 0
    if x % 5 == 0:
        largest = 5
    elif x % 4 == 0: #means "else, if"
        largest = 4
    elif x % 3 == 0:
        largest = 3
    elif x % 2 == 0:
        largest = 2
    else: # When all other (if, elif) conditions are not met
        return "No divisor found for %d!" % x # Each function can return a value or a variable.
    return "The largest divisor of %d is %d" % (x, largest)

def is_prime(x=70):
    """
    Args:
        x : A integer
    
    Returns:
        Find whether an integer is prime.
    
    """
    for i in range(2, x): #  "range" returns a sequence of integers
        if x % i == 0:
          print("%d is not a prime: %d is a divisor" % (x, i)) 
          return False
    print("%d is a prime!" % x)
    return True 

def find_all_primes(x=22):
    """
    Args:
        x : A integer
    
    Return:
        Find all the primes up to x
    
    """
    allprimes = []
    for i in range(2, x + 1):
      if is_prime(i):
        allprimes.append(i)
    print("There are %d primes between 2 and %d" % (len(allprimes), x))
    return allprimes
      
def main(argv):
    """ 
    
    Main entry point of the program 
    
    """ #add docstring to the function
    print(even_or_odd(22))
    print(even_or_odd(33))
    print(largest_divisor_five(120))
    print(largest_divisor_five(121))
    print(is_prime(60))
    print(is_prime(59))
    print(find_all_primes(100))
    return 0

if (__name__ == "__main__"):
    status = main(sys.argv)
    sys.exit(status)
