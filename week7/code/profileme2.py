"""
Description:

# other options for profiling

run -p -s cumtime profileme2.py

-s allows sorting the report by a particular column,
-l limits the number of lines displayed or filters the results by function name, 
and -T saves the report in a text file


# run profiling outside the ipython with cProfile

`python3 -m cProfile -o profires myscript.py`
Here the results are stored in a file called profires, which can be read using the pstats module.

# Or USE IDLE to profile

"""
import numpy as np

def my_squares(iters):
    """[summary]

    Args:
        iters ([type]): [description]

    Returns:
        [type]: [description]
    """    
    out = [i ** 2 for i in range(iters)] #list comprehension much faster
    return out

def my_squares_numpy(iters):
    """[summary]

    Args:
        iters ([type]): [description]

    Returns:
        [type]: [description]
    """    

    out = np.arange(iters)
    out = out ** 2                # much faster with numpy preallocation
    return out 

def my_squares_numpy2(iters):
    """[summary]

    Args:
        iters ([type]): [description]

    Returns:
        [type]: [description]
    """    
    OUT = range(iters)
    out = np.array(OUT)
    out = out ** 2                #faster than the list comprehension but slower than the np.arange
    return out 

def my_join(iters, string):
    """[summary]

    Args:
        iters ([type]): [description]
        string ([type]): [description]

    Returns:
        [type]: [description]
    """    
    out = ''
    for i in range(iters):
        out += ", " + string    #remove the sub function .join
    return out

def run_my_funcs(x,y):
    """[summary]

    Args:
        x ([type]): [description]
        y ([type]): [description]

    Returns:
        [type]: [description]
    """    
    print(x,y)
    my_squares(x)
    my_join(x,y)
    my_squares_numpy(x)
    my_squares_numpy2(x)
    return 0

run_my_funcs(10000000,"My string")