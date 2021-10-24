#!/usr/bin/env python3

"""
Auther: Congjia Chen (congjia.chen21@imperial.ac.uk)
Script: align_seqs_fasta.py
Des: Calculate the match score between two seqs from to seqerate fasta files. Print and save the best score and best alignment of it
Usage: python3 align_seqs_fasta.py seq1.fasta seq2.fasta (in terminal)
Dep: sys,pickle
Date: Oct, 2021
Output: "../results/Best_score_fasta.pickle"
"""


__appname__ = '[align_seqs_fasta.py]'
__author__ = 'Congjia Chen (congjia.chen21@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
#import csv
import pickle
                
def convert_fasta2dict(fasta_path):

    """
    Args:
        fasta_path : the path of the fasta file
    Returns:
        dictionary that stores the sequence information originated from input fasta file
    Des:
        convert fasta file to dictionary
    
    """
    dict_fas = {}
    with open(fasta_path, 'r') as f:
        for line in f:
            if line.startswith('>'):
                line = line.strip("\n")
                line = line.split(" ",1)
                name = str(line[0])
                dict_fas[name] = ''
            else:
                dict_fas[name] += line.replace("\n","") 
    return dict_fas

# Assign the longer sequence s1, and the shorter to s2
# l1 is length of the longest, l2 that of the shortest
def identify_the_seq(seq1,seq2):

    """
    Args:
        seq1: A sequence
        seq2: A sequence
    Returns:
        s1 : longer sequnce in seq1 and seq2
        s2 : shorter sequnce in seq1 and seq2
        l1 : length of s1
        l2 : length of s2
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
        s1 : longer sequnce in seq1 and seq2
        s2 : shorter sequnce in seq1 and seq2
        l1 : length of s1
        l2 : length of s2
        startpoint : the startpoint in s1 to do alignment
    Returns:
        The score of given start point
    Des:
        calculate the score for the match of the two sequence 
    
    """
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

def higher_score_finder(s1, s2, l1, l2):

    """
    Args:
        s1 : longer sequnce in seq1 and seq2
        s2 : shorter sequnce in seq1 and seq2
        l1 : length of s1
        l2 : length of s2
    
    Returns:
        The dictionary which contains the best score along with the best alignment
    
    Des:
        find the best score of the given fasta file
    
    """
    my_best_align = None
    my_best_score = -1
    dict_for_seq = {}
    for i in range(l1): # Note that you just take the last alignment with the highest score
        z = calculate_score(s1, s2, l1, l2, i)
        if z > my_best_score:
            my_best_align = "." * i + s2 # think about what this is doing!
            my_best_score = z 
    #print(my_best_align)
    #print(s1)
    print("Best score:", my_best_score)
    result = (my_best_align, s1, my_best_score)
    dict_for_seq["Best_score"] = my_best_score
    dict_for_seq["my_best_align"] = my_best_align
    #dict_for_seq["Target_for_align"] = s1

    return dict_for_seq

def pickle_read(my_dictionary):

    """
    Args:
        my_dictionary : a dictionary which stores the best score along with the best alignment

    Output:
        ../results/Best_score_fasta.pickle

    Des:
        pickle to save the dictionary and print it
    
    """
    with open('../results/Best_score_fasta.pickle', 'wb') as f:
        pickle.dump(my_dictionary, f)
        print ("=====================storing the result====================")
        print ("The result has been stored in the ../results/Best_score_fasta.pickle")
    with open('../results/Best_score_fasta.pickle', 'rb') as f:
        another = pickle.load(f)
        print ("=====================checking the result=====================")
        print ("The output result will be printed")
        print (another)


def main(argv):

    """ Main entry point of the program """ 
    #add docstring to the function
    #have the arguments from the terminal  
    #seq2 = "ATCGCCGGATTACGGG"
    #seq1 = "CAATTCGGAT"
    if len(sys.argv) == 3:
        try:
            dict_seq1 = [ value for key,value in convert_fasta2dict(sys.argv[1]).items()] # get the sequence from the dictionary
            dict_seq2 = [ value for key,value in convert_fasta2dict(sys.argv[2]).items()]
        except (UnboundLocalError):
            print ("Unknown Error")    
        except (FileNotFoundError):
            print ("Your files provided here are not accessible")
            sys.exit(0)
    else:
        print ("We will use the default path here\n 407228412.fasta \n 407228326.fasta")
        path1 = "../data/fasta/407228412.fasta"
        path2 = "../data/fasta/407228326.fasta"
        dict_seq1 = [ value for key,value in convert_fasta2dict(path1).items()]
        dict_seq2 = [ value for key,value in convert_fasta2dict(path2).items()]

    #print (len(dict_seq1[0]))
    #print (dict_seq2)
    s1, s2, l1, l2 = identify_the_seq(dict_seq1[0],dict_seq2[0])
    pickle_read(higher_score_finder(s1, s2, l1, l2))
    return 0

if (__name__ == "__main__"):
    print ("We are now running:",sys.argv[0],"\n")
    status = main(sys.argv)
    sys.exit(status)
