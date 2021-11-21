""" 
Language:python3
Author: congjia chen (congjia.chen21@imperial.ac.uk)
Des: use oa.walk to process the dir and files
Dep: subprocess
"""

# Use the subprocess.os module to get a list of files and directories 
# in your ubuntu home directory 

# Hint: look in subprocess.os and/or subprocess.os.path and/or 
# subprocess.os.walk for helpful functions

import subprocess

#################################
#~Get a list of files and 
#~directories in your home/ that start with an uppercase 'C'

# Type your code here:

# Get the user's home directory.
home = subprocess.os.path.expanduser("~")

# Create a list to store the results.
FilesDirsStartingWithC = []

# Use a for loop to walk through the home directory.
for dir, subdir, files in subprocess.os.walk(home):
    for f in files:
        if f.startswith("C"):
            FilesDirsStartingWithC.append(f)
    for d in subdir:
        if d.startswith("C"):
            FilesDirsStartingWithC.append(d)
print (FilesDirsStartingWithC)


#################################
# Get files and directories in your home/ that start with either an 
# upper or lower case 'C'

# Type your code here:

# Create a list to store the results.
FilesDirsStartingWithCc = []

# Use a for loop to walk through the home directory.
for dir, subdir, files in subprocess.os.walk(home):
    for f in files:
        if f.startswith("C") or f.startswith("c"):
            FilesDirsStartingWithCc.append(f)
    for d in subdir:
        if d.startswith("C") or d.startswith("c"):
            FilesDirsStartingWithCc.append(d)
print (FilesDirsStartingWithCc)
    
#################################
# Get only directories in your home/ that start with either an upper or 
#~lower case 'C' 

# Type your code here:

# Create a list to store the results.
DirsStartingWithC = []

# Use a for loop to walk through the home directory.
for dir, subdir, files in subprocess.os.walk(home):
    for d in subdir:
        if d.startswith("C") or d.startswith("c"):
            DirsStartingWithC.append(d)
print (DirsStartingWithC)
    
    