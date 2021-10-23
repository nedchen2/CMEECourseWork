#!/usr/bin/env python3
# Filename: dictionary.py

"""
Auther:Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: dictionary.py
Des: Practice for dictionary comprehension
Usage: python3 dictionary.py (in terminal)
Date: Oct, 2021
"""

taxa = [ ('Myotis lucifugus','Chiroptera'),
         ('Gerbillus henleyi','Rodentia',),
         ('Peromyscus crinitus', 'Rodentia'),
         ('Mus domesticus', 'Rodentia'),
         ('Cleithrionomys rutilus', 'Rodentia'),
         ('Microgale dobsoni', 'Afrosoricida'),
         ('Microgale talazaci', 'Afrosoricida'),
         ('Lyacon pictus', 'Carnivora'),
         ('Arctocephalus gazella', 'Carnivora'),
         ('Canis lupus', 'Carnivora'),
        ]

# Write a short python script to populate a dictionary called taxa_dic 
# derived from  taxa so that it maps order names to sets of taxa.
# 
# An example output is:
#  
# 'Chiroptera' : set(['Myotis lucifugus']) ... etc.
#  OR,
# 'Chiroptera': {'Myotis lucifugus'} ... etc

# Answer
# Method1: For loop with empty sets
# list1=taxa
# taxa_dic={y:set() for (x,y) in taxa}
# for i,v in  enumerate(list1):
#        for j,k in enumerate(list1[i+1:],i+1):
#                if v[1] == k[1]:
#                        taxa_dic[v[1]].add(str(v[0]))
#                        taxa_dic[v[1]].add(str(k[0]))
#                else:
#                        taxa_dic[v[1]].add(str(v[0]))
# print (taxa_dic)

# defaultdict
# Method2: with other import function
# from collections import defaultdict
# new = defaultdict(set)
# for (value,key) in taxa:
#        new[key].add(value)

# dictionary comprehension:
# Method3: setdefault
# taxa_dic={}
# {taxa_dic.setdefault(key,set()).add(value) for value,key in taxa}

# dictionary
# Method4: setdefault
# setdefault method could be used to 
taxa_dic={}
for value,key in taxa:
        taxa_dic.setdefault(key,set()).add(value) # return special dictionary value which could be manipulated
print (taxa_dic)


