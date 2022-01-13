#include <stdio.h> 
     /* A standard library of C . 
     printf is one of the method in it */
int main (void) // the tap is not meaningful for C,same as R
     /* starting point of the exectuable part */
    {
        char c = "a";
        char b = "A";

        printf("The value of c:%c\n",c);
        printf("The value of c as an int: %i\n",c);
        printf("The value of character represented as an integer: %i\n",c);
// some of the data is overflow therefore could be lost
        return 0;
    }