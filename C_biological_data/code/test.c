#include <stdio.h> 
int main (void) // the tap is not meaningful for C,same as R
     /* starting point of the exectuable part */
    {
        unsigned long x = sizeof(long);
        printf ("the size of long is %lu\n",x) ;
        unsigned float y = sizeof(float);
        printf ("the size of float is %u\n",y) ;

//float is chunked up to  convert to the array like 1|the number of power|number| to store  
//float number compare will not be exact. We could compare it in range.
//unsafe language in different way.

        }