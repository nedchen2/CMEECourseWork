#!/usr/bin/env python3

"""recursive function to do some of the caculation"""
#docstrings are considered part of the running code (normal comments are
#stripped). Hence, you can access your docstrings at run time.
__author__ = 'Congjia Chen (congjia.chen21@imperial.ac.uk)'
__version__ = '0.0.1'

import sys

def foo_1(x):

    """return the number caculated by 0.5 power."""
    return x ** 0.5 #return the number caculated by power.

# 
def foo_2(x, y): 

    """return the biggest number between the x and Y from (x,y)"""
    if x > y:
        return x 
    return y

def foo_3(x, y, z): #sort

    """sort the number in (x,y,z), from small to big"""
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

    """Calculate the factorial of x in for loop"""
    result = 1
    for i in range(1, x + 1):
        result = result * i
    return result

def foo_5(x): 

    """ a recursive function that calculates the factorial of x """
    if x == 1:
        return 1
    return x * foo_5(x - 1)
# a recursive function that calculates the factorial of x

     
def foo_6(x): # Calculate the factorial of x in a different way
    
    """ Calculate the factorial of x in while loop """
    facto = 1
    while x >= 1:
        facto = facto * x
        x = x - 1
    return facto

def main(argv):

    """ Main entry point of the program. Some test of the function. If we run it as a main, we will have this function running""" #add docstring to the function
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
        if sys.argv[1].isdigit():
            print ("You have enter a Number. We wil test the Function (foo_5) by this arguments")
            #status = main(sys.argv) 
            print (foo_5(int(sys.argv[1])))
            status = 0
            sys.exit(status)
        else:
            print ("Sorry only the number are valid here")
            status = 0
            sys.exit(status)
    else:
        print ("No other arguments provided")
        status = main(sys.argv)
        sys.exit(status)


