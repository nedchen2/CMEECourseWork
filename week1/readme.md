# **CMEECourseWork** - Week1

## Table of Contents

- [**CMEECourseWork** - Week1](#cmeecoursework---week1)
  - [Table of Contents](#table-of-contents)
  - [**Brief Description**-***Week1 review of the CMEECourseWork***](#brief-description-week1-review-of-the-cmeecoursework)
  - [**Author and Contact**](#author-and-contact)
  - [**A.Languages**](#alanguages)
  - [**B.Dependencies and Installation**](#bdependencies-and-installation)
  - [**C.Project structure and Usage**](#cproject-structure-and-usage)
    - [**(1) Repo Structure introduction**](#1-repo-structure-introduction)
    - [**(2) Scripts List**](#2-scripts-list)
      - [1. Unix chapter](#1-unix-chapter)
      - [2. Shell scripts chapter](#2-shell-scripts-chapter)
      - [3. Latex chapter](#3-latex-chapter)

## **Brief Description**-***Week1 review of the CMEECourseWork***

1.Learn Unix and shell scripting,and solve some of the real questions

2.use Git for version control.

3.use Latex to do scientific writing.


## **Author and Contact**

**Congjia Chen**

Congjia.Chen21@imperial.ac.uk

## **A.Languages**

Shell

## **B.Dependencies and Installation** 

Most of the scripts in the current repository can be ran in bash shell directly. One of the scripts `tiff2png.sh` needs the imagemagick. 

Installation: `sudo apt install imagemagick` (Run in the terminal)

## **C.Project structure and Usage**

### **(1) Repo Structure introduction**

Each week’s directory contain directories called `code`, `data`, `results`, and `sandbox` 

`code`: directory to put the scripts (`e.g. *.sh`)

`Data`: directory to put some of the input file (`e.g. *.fasta`)

`results` : directory for output

### **(2) Scripts List**

#### 1. Unix chapter

| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| UnixPrac1.txt |fasta practice using Unix| None |

#### 2. Shell scripts chapter

| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| boilerplate.sh   |simple boilerplate for shell scripts| None |
| MyExampleScript.sh     | Hello user (test the variable)| None |
| variables.sh  |Practice for reading the variable| None |
| tiff2png.sh   |convert the tiff file to png in a given directory| 1 > directory of *.tif  |
| CountLines.sh    |count lines number| 1 -> A File |
| csvtospace.sh    |shell script that takes a comma separated file and converts it to a space separated values file| 1 -> Files with a comma separated values, 2 -> Output directory (optional)|
| tabtocsv.sh    |substitute the tabs in the files with commas| 1 -> Files with a tab separated values , 2 -> Output directory (optional)|
| ConcatenateTwoFiles.sh    | Merge two Files together by row | 1 -> files1 to be merged, 2 -> files2 to be merged, 3 -> Merged file |

#### 3. Latex chapter

| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| CompileLaTeX.sh   |render the .tex file to .pdf| 1 -> LaTex file (.tex) |
| FirstBiblio.bib    | Referencing and bibliography file for FirstExample.tex| None |
| FirstExample.tex   | FirstExample of LaTex| None |

