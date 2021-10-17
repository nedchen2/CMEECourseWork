# **CMEE Coursework Repository**

## Table of Contents

- [**CMEE Coursework Repository**](#cmee-coursework-repository)
  - [Table of Contents](#table-of-contents)
  - [**Brief Description**](#brief-description)
  - [**Languages**](#languages)
  - [**Dependencies**](#dependencies)
    - [**WEEK1**](#week1)
  - [**Installation**](#installation)
  - [**Project structure and Usage**](#project-structure-and-usage)
  - [The Repository would be updated weekly](#the-repository-would-be-updated-weekly)
    - [**WEEK1**](#week1-1)
      - [**(1) Repo Structure introduction**](#1-repo-structure-introduction)
      - [**(2) Scripts List**](#2-scripts-list)
        - [1. Unix chapter](#1-unix-chapter)
        - [2. Shell scripts chapter](#2-shell-scripts-chapter)
        - [3. Latex chapter](#3-latex-chapter)
  - [**Author and Contact**](#author-and-contact)

## **Brief Description**
1. Ideally, a quantitative biologist should be multilingual, knowing:

>A modern, easy-to-write, interpreted (or semi-compiled) language that is “reasonably” fast, like `Python`

>Mathematical/statistical software with programming and graphing capabilities, like `R`

>A compiled (or semi-compiled) ‘procedural’ language, like `C`

2. These works are based on the Notebook and Data from https://github.com/mhasoba/TheMulQuaBio.git.

3. As the course going on, i will add more to the repository

## **Languages**
```
Shell,Python,R,C
```

## **Dependencies**

### **WEEK1**

Most of the scripts in the current repository can be ran in bash shell directly. One of the scripts `tiff2png.sh` needs the imagemagick. 

Installation: `sudo apt install imagemagick` (Run in the terminal)


## **Installation**
```
git clone https://github.com/nedchen2/CMEECourseWork.git
```

## **Project structure and Usage**

---
The Repository would be updated weekly
---
### **WEEK1**

#### **(1) Repo Structure introduction**

Each week’s directory contain directories called `code`, `data`, `results`, and `sandbox` 


#### **(2) Scripts List**

##### 1. Unix chapter

| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| UnixPrac1.txt |fasta practice using Unix| None |

##### 2. Shell scripts chapter

```use "-h" to see the help document```

| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| boilerplate.sh   |simple boilerplate for shell scripts| None |
| MyExampleScript.sh     | Hello user (test the variable)| None |
| variables.sh  |Practice for reading the variable| None |
| tiff2png.sh   |convert the tiff file to png in a given directory| 1 -> directory of *.tif , 2 -> Output directory (Necessary) |
| CountLines.sh    |count lines number| 1 -> A File |
| csvtospace.sh    |shell script that takes a comma separated file and converts it to a space separated values file| 1 -> Files with a comma separated values, 2 -> Output directory (optional)|
| tabtocsv.sh    |substitute the tabs in the files with commas| 1 -> Files with a tab separated values , 2 -> Output directory (optional)|
| ConcatenateTwoFiles.sh    | Merge two Files together by row | 1 -> files1 to be merged, 2 -> files2 to be merged, 3 -> Merged file |

##### 3. Latex chapter

```use "-h" to see the help document```

| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| CompileLaTeX.sh   |render the .tex file to .pdf| 1 -> LaTex file (.tex), 2 -> Output directory (optional) |
| FirstBiblio.bib    | Referencing and bibliography file for FirstExample.tex| None |
| FirstExample.tex   | FirstExample of LaTex| None |

## **Author and Contact**
Congjia Chen

Congjia.Chen21@imperial.ac.uk