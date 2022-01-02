# **CMEECourseWork** - Miniproject

## Table of Contents

- [**CMEECourseWork** - Miniproject](#cmeecoursework---miniproject)
  - [Table of Contents](#table-of-contents)
  - [**Brief Description**-***Miniproject review of the CMEECourseWork***](#brief-description-miniproject-review-of-the-cmeecoursework)
  - [**Languages**](#languages)
  - [**Installation**](#installation)
  - [**Dependencies**](#dependencies)
  - [**Project structure and Usage**](#project-structure-and-usage)
    - [**(1) Repo Structure introduction**](#1-repo-structure-introduction)
    - [**(2) Scripts List**](#2-scripts-list)
  - [**Author and Contact**](#author-and-contact)

## **Brief Description**-***Miniproject review of the CMEECourseWork***

1. Using R and Python to do data wrangling and visualization and work flow control. 
2. LaTex to do some of the scientific writing.
3. These works are based on the Notebook and Data from https://github.com/mhasoba/TheMulQuaBio.git.

## **Languages**
```
Shell,Latex,R,python
```
## **Installation**
```
git clone https://github.com/nedchen2/CMEECourseWork.git
```

## **Dependencies** 

R：

`ggthemes`:For good-looking of plots

`tidyverse`:For Data wrangling and visualization

`ggpubr`:For put several plot together 

`minpack.lm` : For NLLS model fitting

Installation: install.packages("*")

Python ： 

`subprocess`: For work flow control

Installation: pip install subprocess

Latex:

`graphicx`:For adding the figure

`lineno`:For adding the line number

## **Project structure and Usage**

### **(1) Repo Structure introduction**

Each week’s directory contain directories called `code`, `data`, `results`, and `sandbox` 

`code`: directory to put the scripts (`e.g. *.sh`)

`Data`: directory to put some of the input file (`e.g. *.fasta`)

`results` : directory for output

`writeup` ； directory for PDF report

### **(2) Scripts List**

```use "-h" to see the help document```

| Script Name |Description | Arguments |
| ------ | ------ | ------ |
|a_Data_prepare.R   |Preprocess the data|None |
|b_`model_name`.R  |Modeling of different models| None |
|c0_best_linear_model_Plot.R  | Output the plot and table of best selected linear model for each experiment ID |1 <- CRITERIA (AIC,BIC,R2) | 
|c1_LS_NLLS_model.R  |Output the plot and table of best selected linear and non-linear model for each experiment ID |1 <- CRITERIA (AIC,BIC,AIC_C) | 
|d0_StatisticsOfbest_model.R  |Output the plot and table for report |None | 
|run_pipeline.py  |workflow control |work flow control| 
|Compile_LaTeX.sh |compile latex |1 <- <file .tex> <outputdir>  | 
|Miniproject.tex | latex file  |None | 

## **Author and Contact**

**Congjia Chen**

Congjia.Chen21@imperial.ac.uk

