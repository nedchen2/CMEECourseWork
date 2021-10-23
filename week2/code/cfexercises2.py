#!/usr/bin/env python3

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: cfexercise2.py
Des: Some functions exemplifying the use of conditionals
Usage: python3 cfexercise2.py (in terminal)
Date: Oct, 2021
"""

########################
def hello_1(x):
    """
    
    Print "hello" when the number (from 0 to x) % 3 == 0   

    """
    for j in range(x):
        if j % 3 == 0:
            print('hello')
    print(' ')

hello_1(12)

########################
def hello_2(x):
    """
    
    Print "hello" when the number (from 0 to x) % 5 == 3 or % 4 == 3

    """
    for j in range(x):
        if j % 5 == 3:
            print('hello')
        elif j % 4 == 3:
            print('hello')
    print(' ')

hello_2(12)

########################
def hello_3(x, y):
    """
    
    Print "hello" everytime when iterate from x to y  

    """
    
    for i in range(x, y):
        print('hello')
    print(' ')

hello_3(3, 17)

########################
def hello_4(x):
    """
    Args:
        x : is the start point

    Output:
        while x is not 15, print "hello" until x = 15, every loop increment y by 3.

    """
    while x != 15:
        print('hello')
        x = x + 3
    print(' ')

hello_4(0)

########################
def hello_5(x):
    """

    x is the start point
    while x is samller than 100, 
    when the x equals to 31, print 7 times "hello"
    when the x equals to 18, print 1 time "hello"
    every loop increment x by 1

    """
    while x < 100:
        if x == 31:
            for k in range(7):
                print('hello')
        elif x == 18:
            print('hello')
        x = x + 1
    print(' ')

hello_5(12)

# WHILE loop with BREAK
def hello_6(x, y):
    """
    Args:
        x: True or False
        y: integer which is smaller than 6

    Output
        While loop with Break, while x is True, print "hello", every loop increment y by 1 , stop when y = 6.
    """
    while x: # while x is True
        print("hello! " + str(y))
        y += 1 # increment y by 1 
        if y == 6:
            break
    print(' ')

hello_6 (True, 0)