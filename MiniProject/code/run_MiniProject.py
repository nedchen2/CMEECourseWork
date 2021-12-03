"""
Auther: Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: run_pipeline.py
Des: Work flow control for miniproject
Usage: python3 run_pipeline.py
Dep: subprocess,glob
Date: Dec, 2021
"""

import subprocess
import glob

#run the data_preparation and model fitting part
scripts = glob.glob("[ab]*.R")
scripts.sort()

for i in range(0,len(scripts),1):
    command = "Rscript " + scripts[i]
    subprocess.run(command,shell=True,check=True)

# run the model selection and Linear Model plot
# PLOT THE BEST LINEAR MODEL based on adjusted R 

command =  "Rscript " + "c0_Best_Linear_Model_Plot.R" + " R2"
subprocess.run(command,shell=True,check=True)

#run the model selection and Linear and Nonlinear plot all with different criteria
scripts2 = glob.glob("c1*.R")[0]

criteria = [" AIC_C", " AIC", " BIC"]

for i in range(0,len(criteria),1):
    command = "Rscript " + scripts2 + criteria[i]
    subprocess.run(command,shell=True,check=True)

#run the statistics of best models
scripts3 = glob.glob("d0*.R")[0]

command =  "Rscript " + scripts3
subprocess.run(command,shell=True,check=True)

#run the latex compile 
command =  "bash CompileLaTeX.sh " + "Miniproject.tex " + "../writeup"
subprocess.run(command,shell=True,check=True)
 
    




#assess the model performance and output a report

command =  "Rscript " + "d0_S"   # In this script we will compare the result of different models to have a general id that which is the best