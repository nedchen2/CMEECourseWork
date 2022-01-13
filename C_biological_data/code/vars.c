#include <stdio.h> 
int main (void) // the tap is not meaningful for C,same as R
     /* starting point of the exectuable part */
    {
        int x; // declare before we use,give us enough memory to store of integer

        x = 10; // 10 is a constant literal

        float y = 0.2;

        printf("The value of x is: %i\n",x);
        printf("The value of x is: %i\n The value of y is  %f\n ",x,y);
        // Integral
        // 0000 : 0
        // 0001 : 1
        // 0010 : 2
        char c;// 1-byte
        int i;//normally 32-bit
        long int li;
        long long int lli;

        //floating point -- much slower than integer
        float f;
        double d;
        long double ld;

        // Basic aritmetic operators
        // +,-,*,%

        x = 1.9;
        // x expressed 1 in the terminal. truncation not a round


        return x;  // Everything went OK. Return 0 to the OS.
    }

    // the value is 0