#!/usr/bin/env python3

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: cfexercise1.py
Des: recursive function to do some of the caculation
Usage: python3 cfexercise1.py (in terminal)
Dep: sys
Date: Oct, 2021
"""

#docstrings are considered part of the running code (normal comments are
#stripped). Hence, you can access your docstrings at run time.
__author__ = 'Congjia Chen (congjia.chen21@imperial.ac.uk)'
__version__ = '0.0.1'

import sys

def foo_1(x):

    """
    Args:
        x : A integer
    Returns:
        return the number caculated by 0.5 power.
            
    """
    return x ** 0.5 #return the number caculated by power.

# 
def foo_2(x, y): 

    """
    Args:
        x: A integer
        y: A integer
    Returns: 
        the biggest number between the x and Y from (x,y)
    """
    if x > y:
        return x 
    return y

def foo_3(x, y, z): #sort

    """
    Args:
        x: A integer
        y: A integer
        z: A integer

    Returns:
        Sort the number in (x,y,z), ascending
    
    
    """
    if x > y:
        tmp = y
        y = x
        x = tmp
    if y > z:
        tmp = z
        z = y
        y = tmp
    return [x, y, z]

def foo_4(x):

    """
    Args:
        x : A integer

    Returns:
        Calculate the factorial of x in for loop
    
    """
    result = 1
    for i in range(1, x + 1):
        result = result * i
    return result

def foo_5(x): 

    """ 
    Args:
        x : A integer

    Returns:
        a recursive function that calculates the factorial of x 
    
    """
    if x == 1:
        return 1
    return x * foo_5(x - 1)
# a recursive function that calculates the factorial of x

     
def foo_6(x): # Calculate the factorial of x in a different way
    
    """ 
    Args:
        x : A integer
    Returns:
        Calculate the factorial of x in while loop 
    """
    facto = 1
    while x >= 1:
        facto = facto * x
        x = x - 1
    return facto

def main(argv):

    """ 

    Some test of the function. 
    
    """ #add docstring to the function
    print(foo_1(4))
    print(foo_2(4,5))
    print(foo_3(4,7,5))
    print(foo_4(4))
    print(foo_5(4))
    print(foo_6(4))
    #have the arguments from the terminal  

    return 0

if (__name__ == "__main__"):
    print ("We are now running:",sys.argv[0])
    if len(sys.argv) > 1:
        print ("There are more than one arguments here")
        print ("If you want to test a single function, please import the cfexercise1!")
        status = 0
        sys.exit(status)
    else:
        print ("No other arguments provided")
        status = main(sys.argv)
        sys.exit(status)


