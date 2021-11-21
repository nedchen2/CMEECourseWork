"""
Language: Python3
Author: Congjia chen (congjia.chen21@imperial.ac.uk)
Dep: timeit,profileme,profileme2
Date: Nov,2021
Des: Profiling the script
"""

##############################################################################
# loops vs. list comprehensions: which is faster?
##############################################################################

iters = 1000000

import timeit

from profileme import my_squares as my_squares_loops

from profileme2 import my_squares as my_squares_lc

##########################q####################################################
# loops vs. the join method for strings: which is faster?
##############################################################################

mystring = "my string"

from profileme import my_join as my_join_join

from profileme2 import my_join as my_join

# magic code should not be ran in the script. Shoud be ran in ipython 
#%timeit my_squares_loops(iters)
#%timeit my_squares_lc(iters)
#%timeit (my_join_join(iters, mystring))
#%timeit (my_join(iters, mystring))

##########################q####################################################
# Using time module to calculate the time manually
##############################################################################

import time
start = time.time()
my_squares_loops(iters)
print("my_squares_loops takes %f s to run." % (time.time() - start))

start = time.time()
my_squares_lc(iters)
print("my_squares_lc takes %f s to run." % (time.time() - start))