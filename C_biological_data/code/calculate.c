#include <stdio.h> 
int main (void) // the tap is not meaningful for C,same as R
     /* starting point of the exectuable part */
    {
    int a;
    int b;
    int c;

    a = 1 + 2;
    b = 7;
    c = a + b;

    printf("The value of c is: %i\n",c);

    c = b/a;

    printf("The value of c is: %i\n",c); // the result is truncated


    float d ;
   // output the float 
    float e ; // set the number as float

    e = b ;

    d = e / a ;

    printf("The value of d is: %f\n",d); // the result is floated

    d = (float)b/a;

    printf("The value of d is: %f\n",d); // the result is floated

    return 0;
    }
