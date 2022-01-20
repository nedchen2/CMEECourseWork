#!/usr/bin/env python3

"""
Author: Group3
Script: get_TreeHeight.py
Des: Calculate the treeheight according to the degrees and distances
Usage: python3 get_TreeHeight.py file
Dep: pandas,math,sys,os
Date: Oct, 2021
"""

__appname__ = '[get_TreeHeight.py]'
__author__ = 'Group3'
__version__ = '0.0.1'

import pandas as pd #data ana
import math #use math formula
import sys #interact with the system
import os #deal with the directory and file

def TreeHeight(degrees, distance):

    """
    Args:
        degrees: 
        distance: 
    Returns:
        Height
    Des:
        calculate the Height by degrees and distance provided
    
    """
    radians = degrees * math.pi / 180 #
    #radians = math.radians(degrees)
    tans = radians.apply(lambda x: math.tan(x))
    height = distance * tans
    return height

def main(argv):

    """ 
    Main process running the program.
    """ 
    if len(sys.argv) == 2:
        try:
            MyData = pd.read_csv(sys.argv[1]) 
            infilename = os.path.basename(sys.argv[1]).split(sep=".")[0]
        except (FileNotFoundError):
            print ("Your files provided here are not accessible")
            sys.exit(0)
    else:
        print ("We will use the default path here\n ")
        path1 = "../data/trees.csv"
        infilename = os.path.basename(path1).split(sep=".")[0]
        MyData = pd.read_csv(path1)

    outputfile = "../results/"+infilename+"_treeheights.csv"

    MyData["Tree.Height.m"] = TreeHeight(MyData["Angle.degrees"],MyData["Distance.m"])
    MyData.to_csv(outputfile,index=False)    
    return 0

if (__name__ == "__main__"):
    print ("We are now running:",sys.argv[0],"\n")
    status = main(sys.argv)
    sys.exit(status)



