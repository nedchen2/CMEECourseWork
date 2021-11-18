"""
Regex Prac
"""

import re

my_string = "a given string"
match = re.search(r"\s", my_string) #always have r preceding the regex
print(match)
print(match.group())

match = re.search(r'\d', my_string) #find any number 
print(match)

MyStr = 'an example'
match = re.search(r'\w*\s', MyStr) #find any character that precede a whitespace
if match:                      
    print('found a match:', match.group()) 
else:
    print('did not find a match')    

match = re.search(r'2', "it takes 2 to tango")
print(match.group())

match = re.search(r'\d', "it takes 2 to tango")
print(match.group())

match = re.search(r'\d.*' , "it takes 2   to tango") #find all the character that behind the number
print(match.group())

match = re.search(r'\s\w{1,3}\s', 'once upon a time') #start with a space,followed with 1-3 character end with a space 
print(match.group())

match = re.search(r'\s\w*$', 'once upon a time') #start with a space,followed with 0-inf character, end with no more character
print(match.group())

print(
    re.search(r'\w*\s\d.*\d', 'take 2 grams of H2O').group() #random character, space, number, random character,number 
)

print(re.search(r'^\w*.*\s', 'once upon a time').group())  #random character until the last space

print(re.search(r'^\w*.*?\s', 'once upon a time').group()) #use ? to match only the first pattern (non-greedy) 

print(re.search(r'<.+>', 'This is a <EM>first</EM> test').group()) #print all

print(re.search(r'<.+?>', 'This is a <EM>first</EM> test').group()) #print only the first tag

print(re.search(r'\d*\.?\d*','1432.75+60.22i').group()) #number precede the +

print(re.search(r'[AGTC]+', 'the sequence ATTCGT').group()) #print only the seq

print(re.search(r'\s+[A-Z]\w+\s*\w+', "The bird-shit frog's name is Theloderma asper.").group()) # start with space.Captial letter,random character,space,end with number