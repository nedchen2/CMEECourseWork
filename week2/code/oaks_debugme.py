import csv
import sys
import doctest
from itertools import islice

#Define function
def is_an_oak(name):
    
    """ 
    Returns True if name is starts with 'quercus' 
    
    >>> is_an_oak("quercus")
    True
    
    >>> is_an_oak("Quercus")
    True

    >>> is_an_oak("Quer")
    False

    >>> is_an_oak("Ned")
    False

    >>> is_an_oak('Fagus sylvatica')
    False
    
    >>> is_an_oak("Quercuss")
    False

    """
    return name.lower().startswith('quercus') & name.lower().endswith('quercus')


def main(argv): 

    """
    
    the main function to output the oaks to JustOaksData.csv
    
    """
    f = open('../data/TestOaksData.csv','r')
    g = open('../data/JustOaksData.csv','w')
    taxa = csv.reader(f)
    csvwrite = csv.writer(g)
    oaks = set()
    #count = 0
    #method1
    #for row in islice(taxa,1,None):
    #    print(row)
    #    print ("The genus is: ") 
    #    print(row[0] + '\n')
        #import ipdb; ipdb.set_trace()
    #    if is_an_oak(row[0]):
    #        print('FOUND AN OAK!\n')
    #        csvwrite.writerow([row[0], row[1]]) 
    
    #method2
    csvwrite.writerow(["Genus", " species"])
    for i,row in enumerate(taxa):
        if i > 0:
            print(row)
            print ("The genus is: ") 
            print(row[0] + '\n')
            if is_an_oak(row[0]):
                print('FOUND AN OAK!\n')
                csvwrite.writerow([row[0], row[1]]) 

    return 0
    
if (__name__ == "__main__"):
    status = main(sys.argv)

doctest.testmod()