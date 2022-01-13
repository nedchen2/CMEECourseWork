#!/bin/sh
## A shell script for compiling and running my programs

## Program name input
program=$1

## Compiling the program
gcc ${program} -o ${program}.out

## Running the program
./${program}.out