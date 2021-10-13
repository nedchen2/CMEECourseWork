#!/usr/bin/env python3

"""Calculate the match score between two seqs. Print the best score of it"""

__appname__ = '[align_seqs.py]'
__author__ = 'Congjia Chen (congjia.chen21@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import csv

def read_seq_csv():

    """read the seq csv which is located in ../data/align_seq_data.csv"""
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

    """swap the two seq lengths for later calculation"""
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
    
    """calculate the score for the match of the two sequence """
    matched = "" # to hold string displaying alignements
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*"
                score = score + 1
            else:
                matched = matched + "-"

    # some formatted output
    #print("." * startpoint + matched)           
    #print("." * startpoint + s2)
    #print(s1)
    #print(score) 
    #print(" ")

    return score

# Test the function with some example starting points:
# calculate_score(s1, s2, l1, l2, 0)
# calculate_score(s1, s2, l1, l2, 1)
# calculate_score(s1, s2, l1, l2, 5)

# now try to find the best match (highest score) for the two sequences

def higher_score_finder(s1, s2, l1, l2):

    """find the best match (highest score) for the two sequences"""
    my_best_align = None
    my_best_score = -1

    for i in range(l1): # Note that you just take the last alignment with the highest score
        z = calculate_score(s1, s2, l1, l2, i)
        if z > my_best_score:
            my_best_align = "." * i + s2 # think about what this is doing!
            my_best_score = z 
    print(my_best_align)
    print(s1)
    print("Best score:", my_best_score)

def main(argv):

    """ Main entry point of the program. Some test of the function. If we run it as a main, we will have this function running""" 
    #add docstring to the function
    #have the arguments from the terminal  
    #seq2 = "ATCGCCGGATTACGGG"
    #seq1 = "CAATTCGGAT"
    seq1,seq2 = read_seq_csv()
    s1, s2, l1, l2 = identify_the_seq(seq1,seq2)
    higher_score_finder(s1, s2, l1, l2)
    return 0

if (__name__ == "__main__"):

    print ("We are now running:",sys.argv[0],"\n")
    status = main(sys.argv)
    sys.exit(status)
