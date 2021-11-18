"""
In ipython %run -p can be used to profile the speed of script
"""

def my_squares(iters):
    """[test for profiling]

    Args:
        iters ([type]): [the number for iteration]

    Returns:
        [list]: [the square results of ranges of iters]
    """    
    out = []
    for i in range(iters):
        out.append(i ** 2)
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
        out += string.join(", ")   #subfunction.join taking a lot of time
    return out

def run_my_funcs(x,y):
    """[Main function to run the other two function]

    Args:
        x ([numbers]): [number for interations]
        y ([strings]): [the start of the result string]

    Returns:
        [bolean]: [for the script to end]
    """    

    print(x,y)
    my_squares(x)
    my_join(x,y)
    return 0

run_my_funcs(10000000,"My string")