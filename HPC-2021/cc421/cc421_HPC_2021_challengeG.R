# CMEE 2021 HPC excercises R code challenge G pro forma

rm(list=ls()) # nothing written elsewhere should be needed to make this work

# please edit these data to show your information.

name <- "congjia chen"
preferred_name <- "Ned"
email <- "congjia.chen21@imperial.ac.uk"
username <- "cc421"

# don't worry about comments for this challenge - the number of characters used will be counted starting from here

f <- function(p=c(0,0),d=pi/2,l=1, s=1)  {
  if (l >= 0.01){
    e = p + c(l*cos(d), l*sin(d))
    segments(p[1],p[2],e[1],e[2])  
    f(e, d , l*0.87, -s) 
    f(e, d + s*pi/4 , l*0.38, s) 
  }
}

plot(NULL, NULL,xlim = c(-2.5,2.5),ylim = c(0, 8), xlab = "", ylab = "", axes=F)

f()


