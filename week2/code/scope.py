#!/usr/bin/env python3
"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: scope.py
Des: Exemplify use of global and local variables
Usage: python3 scope.py (in terminal)
Date: Oct, 2021
"""

#1
_a_global = 10 # a global variable

if _a_global >= 5:
    _b_global = _a_global + 5 # also a global variable

print("Before calling a_function, outside the function, the value of _a_global is", _a_global)
print("Before calling a_function, outside the function, the value of _b_global is", _b_global)

def a_function():
    """
    Test 1 of global and local variable
    """
    _a_global = 4 # a local variable
    
    if _a_global >= 4:
        _b_global = _a_global + 5 # also a local variable
    
    _a_local = 3
    
    print("Inside the function, the value of _a_global is ", _a_global)
    print("Inside the function, the value of _b_global is ", _b_global)
    print("Inside the function, the value of _a_local is ", _a_local)
    
    return None

a_function()

print("After calling a_function, outside the function, the value of _a_global is ", _a_global)
print("After calling a_function, outside the function, the value of _b_global is ", _b_global)
#print("After calling a_function, outside the function, the value of _a_local is ", _a_local)

#2
_a_global = 10

def a_function():
    """
    Test 2 of global and local variable
    """
    _a_local = 4
    
    print("Inside the function, the value _a_local is ", _a_local)
    print("Inside the function, the value of _a_global is ", _a_global)
    
    return None

a_function()

print("Outside the function, the value of _a_global is", _a_global)

#3
_a_global = 10

print("Before calling a_function, outside the function, the value of _a_global is", _a_global)

def a_function():
    """
    Test 3 of global keywords
    """
    global _a_global
    _a_global = 5
    _a_local = 4
    
    print("Inside the function, the value of _a_global is ", _a_global)
    print("Inside the function, the value _a_local is ", _a_local)
    
    return None

a_function()

print("After calling a_function, outside the function, the value of _a_global now is", _a_global)

#4
def a_function():
    """
    Test 4 of global and local variable. global keyword inside the inner function _a_function2 resulted in changing the value of _a_global in the main workspace / namespace to 20, but within the scope of _a_function, its value remained 10!
    """
    _a_global = 10

    def _a_function2():
        """
        Global declaration 
        """
        global _a_global
        _a_global = 20
    
    print("Before calling a_function, value of _a_global is ", _a_global)

    _a_function2()
    
    print("After calling _a_function2, value of _a_global is ", _a_global)
    
    return None

a_function()

print("The value of a_global in main workspace / namespace is ", _a_global)

#5
_a_global = 10

def a_function():
    """
    Test 5 of global keywords
    """
    def _a_function2():
        """
        Test 5 of global keywords. The reason is that the local and global variables were stored in different areas. if you are in the local workspace, local variable would be used in priority. 
        """
        global _a_global
        _a_global = 20
    
    print("Before calling a_function, value of _a_global is ", _a_global)

    _a_function2()
    
    print("After calling _a_function2, value of _a_global is ", _a_global)

a_function()

print("The value of a_global in main workspace / namespace is ", _a_global)