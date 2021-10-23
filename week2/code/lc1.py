#!/usr/bin/env python3
# Filename: lc1.py

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: lc1.py
Des: Practice for list comprehension1
Usage: python3 lc1.py (in terminal)
Date: Oct, 2021
"""

birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
         )

# A nice example out out is:
# Step #1:
# Latin names:
# ['Passerculus sandwichensis', 'Delichon urbica', 'Junco phaeonotus', 'Junco hyemalis', 'Tachycineata bicolor']
# ... etc.
 

#(1) Write three separate list comprehensions that create three different
# lists containing the latin names, common names and mean body masses for
# each species in birds, respectively. 

# Method1:list comprehensions
print ("Step #1")
list1=[a[0] for a in birds]
print ("Latin names:","\n",list1)
list2=[a[1] for a in birds]
print ("Comman names:","\n",list2)
list3=[a[2] for a in birds]
print ("mean body masses:","\n",list3)

#(2) Now do the same using conventional loops (you can choose to do this 
# before 1 !).

# Method2:For loop
print ("Step #2")
for_loop_result1 = []
for a in birds:
    for_loop_result1.append(a[0])
print("Latin names:","\n",for_loop_result1)

for_loop_result2 = []
for a in birds:
    for_loop_result2.append(a[1])
print("Comman names:","\n",for_loop_result2)

for_loop_result3 = []
for a in birds:
    for_loop_result3.append(a[2])
    
print("mean body masses:","\n",for_loop_result3)