"""

Author: Congjia Chen

Dep: Numpy

Note: Using Numpy and list comprehension to shorten the time

Description: Profiling the script

"""
import numpy as np

def my_squares(iters):
    """[test for profiling]

    Args:
        iters ([int]): [the number for iteration]

    Returns:
        [list]: [the square results of ranges of iters]
    """    
    out = [i ** 2 for i in range(iters)] #list comprehension much faster
    return out

def my_squares_numpy(iters):
    """[test for profiling]

    Args:
        iters ([int]): [the number for iteration]

    Returns:
        [list]: [the square results of ranges of iters]
    """    

    out = np.arange(iters)
    out = out ** 2                # much faster with numpy preallocation
    return out 

def my_squares_numpy2(iters):
    """[test for profiling]

    Args:
        iters ([int]): [the number for iteration]

    Returns:
        [list]: [the square results of ranges of iters]
    """    
    OUT = range(iters)
    out = np.array(OUT)
    out = out ** 2                #faster than the list comprehension but slower than the np.arange
    return out 

def my_join(iters, string):
    """[add the string args with number in range(iters)]

    Args:
        iters ([numbers]): [number for interations]
        string ([string]): [the start of the result string]

    Returns:
        [string]: [the string args with number in range(iters)]
    """    
    out = ''
    for i in range(iters):
        out += ", " + string    #remove the sub function .join
    return out

def run_my_funcs(x,y):
    """[Main function to run the other two function]

    Args:
        x ([numbers]): [number for interations]
        y ([strings]): [the start of the result string]

    Returns:
        [boolean]: [for the script to end]
    """    
    print(x,y)
    my_squares(x)
    my_join(x,y)
    my_squares_numpy(x) #test the use of numpy to profile the script
    my_squares_numpy2(x)
    return 0

run_my_funcs(10000000,"My string")