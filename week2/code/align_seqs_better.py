#!/usr/bin/env python3

"""Calculate the match score between two seqs. Print the best score of it"""

__appname__ = '[align_seqs_fasta.py]'
__author__ = 'Congjia Chen (congjia.chen21@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import csv
import pickle

def convert_fasta2dict(fasta_path):

    """
    
    convert fasta file to dictionary
    
    """
    dict_fas = {}
    with open(fasta_path, 'r') as f:
        for line in f:
            if line.startswith('>'):
                line = line.strip("\n")
                line = line.split(" ", 1)
                name = str(line[0])
                dict_fas[name] = ''
            else:
                dict_fas[name] += line.replace("\n", "")
    return dict_fas

# Assign the longer sequence s1, and the shorter to s2
# l1 is length of the longest, l2 that of the shortest


def identify_the_seq(seq1, seq2):

    """

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
    return s1, s2, l1, l2  # swap the two lengths

# A function that computes a score by returning the number of matches starting
# from arbitrary startpoint (chosen by user)


def calculate_score(s1, s2, l1, l2, startpoint):

    """

    calculate the score for the match of the two sequence 
    
    """

    matched = ""  # to hold string displaying alignements
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]:  # if the bases match
                matched = matched + "*"
                score = score + 1
            else:
                matched = matched + "-"

    # some formatted output
    #print("." * startpoint + matched)
    #print("." * startpoint + s2)
    # print(s1)
    # print(score)
    #print(" ")

    return score

# Test the function with some example starting points:
# calculate_score(s1, s2, l1, l2, 0)
# calculate_score(s1, s2, l1, l2, 1)
# calculate_score(s1, s2, l1, l2, 5)

# now try to find the best match (highest score) for the two sequences


def higher_score_finder(s1, s2, l1, l2):

    """
    
    find the best match (highest score) for the two sequences
    
    """
    #my_best_align = None
    my_best_score = -1

    for i in range(l1):  # Note that you just take the last alignment with the highest score
        z = calculate_score(s1, s2, l1, l2, i)
        if z > my_best_score:
            # my_best_align = "." * i + s2 # think about what this is doing!
            my_best_score = z
    # print(my_best_align)
    # print(s1)
    # print("Best score:", my_best_score)
    return my_best_score


def seq_finder(s1, s2, l1, l2, my_best_score):

    """
    
    create the seq dictionary by the two sequences and the best score
    
    """
    dict_for_seq = {}
    for count,i in enumerate(range(l1)):
        z = calculate_score(s1, s2, l1, l2, i)
        if z == my_best_score:
            my_best_align = "." * i + s2  # think about what this is doing!
            #print(my_best_align)
            #print(s1)
            print("Best score:", my_best_score)
            result = (my_best_align, s1, my_best_score)
            dict_for_seq[count] = result
    return dict_for_seq

def pickle_read(my_dictionary):

    """
    
    pickle to save the dictionary and print it
    
    """
    with open('../results/Best_score_better.pickle', 'wb') as f:
        pickle.dump(my_dictionary, f)
        print ("The file has been stored in the ../results/Best_score_better.pickle")
    with open('../results/Best_score_better.pickle', 'rb') as f:
        another = pickle.load(f)
        print ("The file will be printed")
        print (another)

def main(argv):
    
    """ 
    
    Main entry point of the program. Some test of the function. If we run it as a main, we will have this function running
    
    """
    #seq2 = "ATCGCCGGATTACGGG"
    #seq1 = "CAATTCGGAT"
    if len(sys.argv) == 3:
        try:
            dict_seq1 = [value for key,
                         value in convert_fasta2dict(sys.argv[1]).items()]
            dict_seq2 = [value for key,
                         value in convert_fasta2dict(sys.argv[2]).items()]
        except (UnboundLocalError):
            print("Unknown Error")
        except (FileNotFoundError):
            print("Your files provided here is not accessible")
            sys.exit(0)
    else:
        print("We will use the default path here\n 407228412.fasta \n 407228326.fasta")
        path1 = "../data/fasta/407228412.fasta"
        path2 = "../data/fasta/407228326.fasta"
        dict_seq1 = [value for key, value in convert_fasta2dict(path1).items()]
        dict_seq2 = [value for key, value in convert_fasta2dict(path2).items()]

    #print (len(dict_seq1[0]))
    #print (dict_seq2)
    s1, s2, l1, l2 = identify_the_seq(dict_seq1[0], dict_seq2[0])
    my_best_score = higher_score_finder(s1, s2, l1, l2)
    dict_for_seq = seq_finder(s1, s2, l1, l2, my_best_score)
    pickle_read(dict_for_seq)
    return 0


if (__name__ == "__main__"):
    print("We are now running:", sys.argv[0], "\n")
    status = main(sys.argv)
    sys.exit(status)
