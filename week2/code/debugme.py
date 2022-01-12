#!/usr/bin/env python3
# Filename: debugme.py

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: debugme.py
Des: Practice for debugging
Usage: python3 debugme.py (in terminal)
Date: Oct, 2021
"""

def buggyfunc(x):
    """
    Args:
        x : A iteger
    Returns:
        the result of x divided by y
    """
    y = x
    for i in range(x):
        try: 
            y = y-1
            z = x/y
        except ZeroDivisionError:
            print(f"The result of dividing a number by zero is undefined")
        except:
            print(f"This didn't work; x = {x}; y = {y}")
        else:
            print(f"OK; x = {x}; y = {y}, z = {z};")
    return z

buggyfunc(20)
