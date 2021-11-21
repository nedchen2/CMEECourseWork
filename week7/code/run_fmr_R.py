"""
Language: Python3
Author: Congjia chen (congjia.chen21@imperial.ac.uk)
Dep: subprocess
Date: Nov,2021
"""

import subprocess
p = subprocess.Popen("Rscript fmr.R", shell=True).wait()

if p == 0:
    print ("Congratulation! Succeed!")
else:
    print ("Error! Please check the script")