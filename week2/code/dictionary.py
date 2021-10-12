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
# Method1: For loop
dict1={}
for a in taxa:
    if a[1] in dict1: 
        dict1[a[1]]=taxaset.add(a[0])

print (dict1)
# Method2: Dict Comprehensions
dict2={}
{y:x for (x,y) in taxa if y in }

s = [set(i) for i in taxa if i]
s[0]
def intersection_set(taxa):
        for i,v in  enumerate(taxa):
                #print ("First Loop")
                #print (i,v)
                #print (type(v))
                for j,k in enumerate(taxa[i+1:],i+1):
                        #print ("Second Loop")
                        #print (j,k)
                        if v[1] == k[1]:
                              print (v,k)
                              #v=set(v)
                              #print (v.union(taxa.pop(j)))
                              return intersection_set(taxa) 
        return taxa

print (intersection_set(taxa))

for i,v in  enumerate(s):
                #print ("First Loop")
                #print (i,v)
                #print (type(v))
        for j,k in enumerate(s[i+1:],i+1):
                        #print ("Second Loop")
                        #print (j,k)
                if v & k:
                        s(i) = v.union(s.pop(j-1))
                        print (v,k)
                        print (s)
                              #v=set(v)
                              #print (v.union(taxa.pop(j)))
