# **CMEECourseWork** - Week2

## Table of Contents

- [**CMEECourseWork** - Week2](#cmeecoursework---week2)
  - [Table of Contents](#table-of-contents)
  - [**Brief Description**-***Week2 review of the CMEECourseWork***](#brief-description-week2-review-of-the-cmeecoursework)
  - [**Languages**](#languages)
  - [**Installation**](#installation)
  - [**Dependencies**](#dependencies)
  - [**Project structure and Usage**](#project-structure-and-usage)
    - [**(1) Repo Structure introduction**](#1-repo-structure-introduction)
    - [**(2) Scripts List**](#2-scripts-list)
  - [**Author and Contact**](#author-and-contact)

## **Brief Description**-***Week2 review of the CMEECourseWork***

1. Basic python data structure, function and list comprehension.
2. Use ipdb and doctest to debug the code.
3. Control flow tools
4. These works are based on the Notebook and Data from https://github.com/mhasoba/TheMulQuaBio.git.

## **Languages**
```
Python
```
## **Installation**
```
git clone https://github.com/nedchen2/CMEECourseWork.git
```

## **Dependencies** 

Most of the scripts in the current repository can be ran in terminal directly. Some of the scripts needs `sys`, `pickle`, `csv` module

Installation: `pip install *`(Run in the terminal)

## **Project structure and Usage**

### **(1) Repo Structure introduction**

Each week’s directory contain directories called `code`, `data`, `results`, and `sandbox` 

### **(2) Scripts List**
>Some simple example scripts would not be included here

```Examplify scripts```

| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| basic_*.py  |Examplify the input and output of python| None |

```Pratical scripts```
| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| lc1.py    |Practice for list comprehension1| None |
| lc2.py   |Practice for list comprehension 2| None |
| tuple.py    | Use comprehension to print latin name, common name, and mass from a tuple | None |
| dictionary.py    | Practice for dictionary comprehension | None |
| cfexercises1.py    | recursive function to do some of the caculation | None |
| align_seqs.py    | Calculate the match score between two seqs. Print and save the best score along with best alignment to binary file | None|

```Group practices scripts```
| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| align_seqs_fasta.py    | Calculate the match score between two seqs from to seqerate fasta files. Print and save the best score and the last best alignment of it| 1 -> A fasta file (default:407228412.fasta), 2 -> A fasta file (default:407228326.fasta)|
| align_seqs_better.py   | Calculate the match score between two seqs. Print and save all the possible alignment with the highest match score of it| 1 -> A fasta file (default:407228412.fasta), 2 -> A fasta file (default:407228326.fasta)|
| oaks_debugme.py    | Only when the first column of the input file strictly equals to "quercus", the rows would be saved into JustOaksData.csv | None |


## **Author and Contact**

**Congjia Chen**

Congjia.Chen21@imperial.ac.uk

