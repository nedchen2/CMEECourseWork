#!/usr/bin/env python3

"""
Auther: Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: align_seqs.py
Des: Calculate the match score between two seqs. Print and save the best score along with best alignment to binary file
Usage: python3 align_seqs.py (in terminal)
Dep: csv,sys,pickle
Date: Oct, 2021
Input: "../data/align_seq_data.csv"
Output: "../results/Best_score.pickle"
"""


__appname__ = '[align_seqs.py]'
__author__ = 'Congjia Chen (congjia.chen21@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import csv
import pickle

def read_seq_csv():

    """
    Returns:
        Two seq names seq1 and seq2

    Des:
        read the seq csv which is located in ../data/align_seq_data.csv
    
    """
    with open('../data/align_seq_data.csv', 'r') as f:
        csvread = csv.reader(f)
        seqlist=[]
        for row in csvread:
            seqlist.append(row[1])
        seq1 = seqlist[0]
        seq2 = seqlist[1]  
    return seq1,seq2 

# Assign the longer sequence s1, and the shorter to s2
# l1 is length of the longest, l2 that of the shortest
def identify_the_seq(seq1,seq2):

    """
    Returns:
        Two seq named seq1 and seq2 and their length l1,l2

    Des:
        swap the two seq lengths for later calculation
    
    """
    l1 = len(seq1)
    l2 = len(seq2)
    if l1 >= l2:
        s1 = seq1
        s2 = seq2
    else:
        s1 = seq2
        s2 = seq1
        l1, l2 = l2, l1 
    return s1, s2, l1, l2# swap the two lengths

# A function that computes a score by returning the number of matches starting
# from arbitrary startpoint (chosen by user)
def calculate_score(s1, s2, l1, l2, startpoint):
    
    """
    Args:
        s1 : seq1
        s2 : seq2
        l1 : length of seq1
        l2 : length of seq2
        startpoint: startpoint of alignment

    Returns:
        The score of alignment starting with different start point 
        and the match

    Des:
        calculate the score for the match of the two sequence and return the matching situation
    
    """
    matched = "" # to hold string displaying alignements
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*" # add * if match
                score = score + 1
            else:
                matched = matched + "-" # add - if not match

    # some formatted output
    #print("." * startpoint + matched)           
    #print("." * startpoint + s2)
    #print(s1)
    #print(score) 
    #print(" ")

    return [score,matched]

def higher_score_finder(s1, s2, l1, l2):

    """
    Args:
        s1 : seq1
        s2 : seq2
        l1 : length of seq1
        l2 : length of seq2

    Returns:
        The dictionary that stores the best align and best score

    Des:
        find the best match (highest score) for the two sequences
    
    
    """
    my_best_align = None
    my_best_score = -1
    dict_for_seq = {}
    for i in range(l1): # select i as a start point from sequence l1
        z = calculate_score(s1, s2, l1, l2, i)[0]
        if z > my_best_score:
            my_best_align = "." * i + str(s2) # use "." to indicate the start point
            my_best_score = z 
            matched = "." * i + str(calculate_score(s1, s2, l1, l2, i)[1])
    print(matched)
    print(my_best_align)
    print(s1)
    print("Best score:", my_best_score)
    result = (my_best_align, s1, my_best_score)
    dict_for_seq["Best_score"] = my_best_score
    dict_for_seq["my_best_align"] = my_best_align
    #dict_for_seq["Target_for_align"] = s1

    return dict_for_seq

def pickle_read(my_dictionary):

    """
    Args: 
        my_dictionary : dictionary result that stores the alignment result.

    Des:
        pickle to save the dictionary and print it
    
    """
    with open('../results/Best_score.pickle', 'wb') as f:
        pickle.dump(my_dictionary, f)
        print ("=====================storing the result=====================")
        print ("The result has been stored in the ../results/Best_score.pickle")
    with open('../results/Best_score.pickle', 'rb') as f:
        another = pickle.load(f)
        print ("=====================checking the result=====================")
        print ("The result will be printed")
        print (another)

def main(argv):

    """ 
    Main process running the program.
    """ 
    seq1,seq2 = read_seq_csv()
    s1, s2, l1, l2 = identify_the_seq(seq1,seq2)
    pickle_read(higher_score_finder(s1, s2, l1, l2))
    return 0

if (__name__ == "__main__"):

    print ("We are now running:",sys.argv[0],"\n")
    status = main(sys.argv)
    sys.exit(status)
