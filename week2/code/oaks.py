#!/usr/bin/env python3
## Finds just those taxa that are oak trees from a list of species
"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: oaks.py
Des: Test of list comprehensions
Usage: python3 oaks.py (in terminal)
Date: Oct, 2021
"""

taxa = [ 'Quercus robur',
         'Fraxinus excelsior',
         'Pinus sylvestris',
         'Quercus cerris',
         'Quercus petraea',
       ]

def is_an_oak(name):
    """
    Return 
        the lower version of the species name which start with "quercus"
    """
    return name.lower().startswith('quercus ') ##return T or F

##Using for loops
oaks_loops = set()
for species in taxa:
    if is_an_oak(species):
        oaks_loops.add(species)
print(oaks_loops)

##Using list comprehensions   
oaks_lc = set([species for species in taxa if is_an_oak(species)])
print(oaks_lc)

##Get names in UPPER CASE using for loops
oaks_loops = set()
for species in taxa:
    if is_an_oak(species):
        oaks_loops.add(species.upper())
print(oaks_loops)

##Get names in UPPER CASE using list comprehensions
oaks_lc = set([species.upper() for species in taxa if is_an_oak(species)])
print(oaks_lc)