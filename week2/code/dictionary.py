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
# Method1: For loop with enumerate and not empty sets
list1=taxa
dict2={y:{str(x)} for (x,y) in taxa}
for i,v in  enumerate(list1):
        for j,k in enumerate(list1[i+1:],i+1):
                #"meiju"
                #print (v,k)
                if v[1] == k[1]:
                        #print (dict2)
                        #dict2[v[1]]=set()
                        dict2[v[1]].add(str(v[0]))
                        dict2[v[1]].add(str(k[0]))
                        #print (dict2)

print (dict2)

# Answer
# Method2: For loop with empty sets
dict2={y:set() for (x,y) in taxa}
for i,v in  enumerate(list1):
        for j,k in enumerate(list1[i+1:],i+1):
                #"meiju"
                #print (v,k)
                if v[1] == k[1]:
                        #print (dict2)
                        #dict2[v[1]]=set()
                        dict2[v[1]].add(str(v[0]))
                        dict2[v[1]].add(str(k[0]))
                        #print (dict2)
                else:
                        dict2[v[1]].add(str(v[0]))

print (dict2)