#!/usr/bin/env python3
# Filename: lc1.py
# Average UK Rainfall (mm) for 1910 by month
# http://www.metoffice.gov.uk/climate/uk/datasets

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: lc2.py
Des: Practice for list comprehension2
Usage: python3 lc2.py (in terminal)
Date: Oct, 2021
"""

rainfall = (('JAN',111.4),
            ('FEB',126.1),
            ('MAR', 49.9),
            ('APR', 95.3),
            ('MAY', 71.8),
            ('JUN', 70.2),
            ('JUL', 97.1),
            ('AUG',140.2),
            ('SEP', 27.0),
            ('OCT', 89.4),
            ('NOV',128.4),
            ('DEC',142.2),
           )

# (1) Use a list comprehension to create a list of month,rainfall tuples where
# the amount of rain was greater than 100 mm.
 
# (2) Use a list comprehension to create a list of just month names where the
# amount of rain was less than 50 mm. 

# (3) Now do (1) and (2) using conventional loops (you can choose to do 
# this before 1 and 2 !). 

# A good example output is:
#
# Step #1:
# Months and rainfall values when the amount of rain was greater than 100mm:
# [('JAN', 111.4), ('FEB', 126.1), ('AUG', 140.2), ('NOV', 128.4), ('DEC', 142.2)]
# ... etc.

# Answer:
# Step #1:
# Months and rainfall values when the amount of rain was greater than 100mm:
# Method1:list comprehensions
print(" Months and rainfall values when the amount of rain was greater than 100mm:")
list1=[n for n in rainfall if n[1] > 100]
print (list1)

# Method2:For loop
for_loop_result1 = []
for n in rainfall:
    if n[1] > 100:
        for_loop_result1.append(n)
    
print(for_loop_result1)

# Step #2:
# to create a list of just month names where the amount of rain was less than 50 mm. 
# Method1:list comprehensions
print (" a list of just month names where the amount of rain was less than 50 mm") 
list2=[n[0] for n in rainfall if n[1] < 50]
print (list2)

# Method2:For loop
for_loop_result2 = []
for n in rainfall:
    if n[1] < 50:
        for_loop_result2.append(n[0])
    
print(for_loop_result2)
