####Teaching Script####

#####Quick recap on vectors and matrices#####
c(1,2,3,4,5)
1:5
c(1,2,3,"hat",5)
c(TRUE,FALSE,TRUE,FALSE)
c(T,F,T,F)
c("TRUE","F","T","F")
class() #use this to see what class your object (in this case vector) is, also see ?typeof

c(1,10,100,1000,10000)[1] 
c(1,10,100,1000,10000)[c(1,2,3)] #I can supply a vector of positions to index a vector
c(1,10,100,1000,10000)[1:3]
c(1,10,100,1000,10000)[10] #outside of range
c(1,10,100,1000,10000)[c(T,F,T,F,F)] #Notice I can supply a logical vector to subset my other vector (takes TRUE positions) THIS IS EXTREMELY USEFUL
c(1,10,100,1000,10000)[c(T,F)] #If I supply a logical vector whose length is too short, R expands it out (T,F -> T,F,T,F,T,F etc.)

rbind(c(1,2),c(3,4))
cbind(cbind(c(1,2),c(100,10)),c(3,4))
matrix(1:4, nrow = 2,ncol = 7)
matrix(1:4, nrow = 2,byrow = T)
matrix(ncol = 2,nrow=2)

matrix(1:4, nrow = 2)[1,] #notice this is now a vector
matrix(1:4, nrow = 2)[,1] 
matrix(1:4, nrow = 2)[1,2]

length(1:5)
sum(1:5)
sum(c(T,F,T))
c(1:5,1,2,"hat")
unique(c(1:5,1,2,"hat","hat"))
table(c(1:5,1,2))
which(c(1,5,10)==5)

sum(length(c(1,2)))

###Loops and Variables####
x = 2
5*x
x = 5 
5*x 
x = c(1:10)
x = matrix(1:4, nrow = 2)
#see how we can assign values to variables, and these can be overwritten

#Loops take advantage of this by taking a variable and changing its value continually, e.g.
for(i in c(1,10,100,1000)){ #the sequence of values the variable "i" will take
  print(5*i) #this for loop excecutes the code between the curly brackets for every value of i
}
for(i in c(1,10,100,1000)){
  print(5) #notice the loop still works in the same way, but because "i" does not feature 
  #in the code between the brackets it wilil do the same each time
}
for(i in 1:10){
  for(j in 10:20){ # I can next loops, and I can call the looping variable whatever I want
    #print(i*j)
    print(c(i,j))
  }
}

for(i in seq(1,10,2)){ #this is one way of iterating through odd numbers
  print(c(i,i+1))
}

#In in programming we often need loops to repeatedly excecute code on different things, for instance, we can use a loop
#to excecute a command every element of a vector
x = c(1,10,1000,999,990)
length(x)
for(i in 1:length(x)){
  print(c(i,x[i]))
  x[i] = 2*x[i] #
}

#We can also use a loop to navigate through through a vector - remember a loop just takes in a sequence (i.e. a vector of elements)
#and excecutes code for every value of that sequence where the variable ("i") takes the form of a particular item in the sequence
x
for(i in x){
  print(c(i,5*i))
  #print(x[i])
}

#HOWEVER, in R many operations are naturally "vectorised" which has a lot of important consequences for how we program, for example
#functions are automatically applied to every element in a vector (i.e. the above loop is redundant - but the same loop is actually being compiled
#in C by your computer you just can't see it!)
x
2*x #everything gets doubled
x*(1:length(x)) #calculations are done position by position

#We can use loops to characterise data structures - we do this (or an equivelant) a lot in the practical
holding_vector = numeric(length = 10) #pre-append a numeric vector (I could also do character)
for(i in 1:10){
  holding_vector[i] = 100-i #fill it position by position
}
holding_vector

####Quick recap on equalities#####
1>2
1<2
1==1
1!=2 
#these all produce TRUE or FALSE (logical vectors of length 1)
1:10<5 #see its vectorised
1:10 == 11:2

c(1,10,100,1000,10000)[c(1,10,100,1000,10000)==1] #we can also use this so subset R objects - you'll see this in action soon
x = c(1,10,100,1000,10000)
x[x==999] = 1
x[is.na(x)==F]
c(T,F,T,F)==F

1==1 & 2==1 #we can do multiple conditions 
1==1 | 1==2 | 1==3
((1==1 | 1==2) & (1==5 | 1==2)) | (1==1) #we can make increasingly complicated conditions (again, very very useful - especially for while loops)
