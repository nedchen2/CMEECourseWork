# **CMEECourseWork** - Week3

## Table of Contents

- [**CMEECourseWork** - Week3](#cmeecoursework---week3)
  - [Table of Contents](#table-of-contents)
  - [**Brief Description**-***Week3 review of the CMEECourseWork***](#brief-description-week3-review-of-the-cmeecoursework)
  - [**Languages**](#languages)
  - [**Installation**](#installation)
  - [**Dependencies**](#dependencies)
  - [**Project structure and Usage**](#project-structure-and-usage)
    - [**(1) Repo Structure introduction**](#1-repo-structure-introduction)
    - [**(2) Scripts List**](#2-scripts-list)
  - [**Author and Contact**](#author-and-contact)

## **Brief Description**-***Week3 review of the CMEECourseWork***

1. Basic R data structure, function , Vectorization and control flow tools.
2. R debugging
3. Data wrangling and visualization based on tidyverse (super useful)
4. These works are based on the Notebook and Data from https://github.com/mhasoba/TheMulQuaBio.git.

## **Languages**
```
R(99%),Latex,python
```
## **Installation**
```
git clone https://github.com/nedchen2/CMEECourseWork.git
```

## **Dependencies** 

Most of the scripts in the current repository can be ran in baseR. Some of the scripts needs `tidyverse`,`reshape2` package

Installation: `install.packages("*")`

## **Project structure and Usage**

### **(1) Repo Structure introduction**

Each week’s directory contain directories called `code`, `data`, `results`, and `sandbox` 

### **(2) Scripts List**
> 1.Some simple example scripts would not be included here
> 2.`tidyverse` is extremly useful to do data wrangling and data visualization.Most of the complex wrangling tasks here were done by `tidyverse`.

```Pratical scripts```
| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| TreeHeight.R |calculates heights of trees given distance of each tree from its base and angle to its top, using  the trigonometric formula | None |
| Vectorize2.R  | Illustrate R Vectorization 2 | None |
| Florida_warming.R   | Is Florida getting warmer? (use cor()) | None |
| DataWrangTidy.R    | Wrangling the Pound Hill Dataset by tidyverse | None |
| PP_Dists.R    | Body mass distribution subplots by feeding interaction type | None|
| PP_Regress.R  | Subgroup linear regression: a try on tidyverse| None |
| GPDD_Data.R   | visualize a map and a data including the distribution of several animals | None |

```Group practices scripts```
| Script Name |Description | Arguments |
| ------ | ------ | ------ |
| get_TreeHeight.R    | Calculate the treeheight according to the degrees and distances by R | 1 -> file with degrees and distances|
| get_TreeHeight.py  | Calculate the treeheight according to the degrees and distances by python| 1 -> file with degrees and distances|
| run_get_TreeHeight.sh | run get_TreeHeight.R and get_TreeHeight.py| None |
| TAutoCorr.R |Autocorrelation to solve "is florida getting warmer"| None |
| PP_Regress_loc.R | Subgroup linear regression of three different group | None |

## **Author and Contact**

**Congjia Chen**

Congjia.Chen21@imperial.ac.uk

