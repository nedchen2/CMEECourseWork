# **CMEECourseWork** - Week1

## Table of Contents

- [**CMEECourseWork** - Week1](#cmeecoursework---week1)
  - [Table of Contents](#table-of-contents)
  - [**Brief Description**-***Week1 review of the CMEECourseWork***](#brief-description-week1-review-of-the-cmeecoursework)
  - [**Languages**](#languages)
  - [**Installation**](#installation)
  - [**Dependencies**](#dependencies)
  - [**Project structure and Usage**](#project-structure-and-usage)
    - [**(1) Repo Structure introduction**](#1-repo-structure-introduction)
    - [**(2) Scripts List**](#2-scripts-list)
      - [1. Unix chapter](#1-unix-chapter)
      - [2. Shell scripts chapter](#2-shell-scripts-chapter)
      - [3. Latex chapter](#3-latex-chapter)
  - [**Author and Contact**](#author-and-contact)

## **Brief Description**-***Week1 review of the CMEECourseWork***

1. Unix and shell scripting,and solve some of the real questions from Unix and shell scripting project
2. LaTex to do some of the scientific writing.
3. These works are based on the Notebook and Data from https://github.com/mhasoba/TheMulQuaBio.git.

## **Languages**
```
Shell,Latex
```
## **Installation**
```
git clone https://github.com/nedchen2/CMEECourseWork.git
```

## **Dependencies** 

Most of the scripts in the current repository can be ran in bash shell directly. One of the scripts `tiff2png.sh` needs the imagemagick. 

Installation: `sudo apt install imagemagick` (Run in the terminal)

## **Project structure and Usage**

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

```Test script```

| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| variables.sh  |Practice for reading the variable| None |

```Functional script```
```use "-h" to see the help document```
```Compatible for no matter directory input or single file input```
| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| tiff2png.sh   |convert the tiff file to png in a given directory| 1 -> directory of *.tif or single tif file , 2 -> Output directory (Necessary) |
| CountLines.sh    |count lines number| 1 -> A File or a directory|

```Compatible for single file input only```
| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| csvtospace.sh    |shell script that takes a comma separated file and converts it to a space separated values file| 1 -> Files with a comma separated values, 2 -> Output directory (optional)|
| tabtocsv.sh    |substitute the tabs in the files with commas| 1 -> Files with a tab separated values, 2 -> Output directory (optional)|
| ConcatenateTwoFiles.sh    | Merge two Files together by row | 1 -> Files1 to be merged, 2 -> files2 to be merged, 3 -> Merged file |

#### 3. Latex chapter

```use "-h" to see the help document```

| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| CompileLaTeX.sh   |render the .tex file to .pdf| 1 -> LaTex file (.tex), 2 -> Output directory (optional) |
| FirstBiblio.bib    | Referencing and bibliography file for FirstExample.tex| None |
| FirstExample.tex   | FirstExample of LaTex| None |

## **Author and Contact**

**Congjia Chen**

Congjia.Chen21@imperial.ac.uk

