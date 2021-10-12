#!/usr/bin/env python3
#############################
# STORING OBJECTS
#############################
# To save an object (even complex) for later use
my_dictionary = {"a key": 10, "another key": 11}

import pickle

f = open('../sandbox/testp.p','wb') ## note the b: accept binary files
pickle.dump(my_dictionary, f) #write the dictionary into the binary file
f.close()

## Load the data again
f = open('../sandbox/testp.p','rb')
another_dictionary = pickle.load(f) #read the binary file and convert it into human-readable
f.close()

print(another_dictionary)