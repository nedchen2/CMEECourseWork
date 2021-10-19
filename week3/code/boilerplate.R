MyFunction <- function(Arg1, Arg2){
      # Statements involving Arg1, Arg2:
    print(paste("Argument", as.character(Arg1), "is a", class(Arg1))) # print Arg1's type
    print(paste("Argument", as.character(Arg2), "is a", class(Arg2))) # print Arg2's type

    return (c(Arg1, Arg2))
}

MyFunction(1,2) 
MyFunction("Riki","Tiki") 