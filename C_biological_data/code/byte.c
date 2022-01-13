#include <stdio.h>
#include <string.h>

int main(void){ // write a program 
    int i;
    char chars[256]; // array store 256 bytes
    unsigned long longs[2];//declare a array of long unsigned int with two
    longs[0] = 0UL; //set the first element to 0 (every single butes,totally 8 for long int)
    longs[1] = ~0UL; // set the first element to 1 (every single bytes, totally 8 for long init)

    memcpy(chars, longs, sizeof(unsigned long) * 2);//we copy the address to the function
    // sizeof(unsigned long) --- tuolekuzifangpi, we only have 16 bytes in "long" varaible
    // third parameter : how many bytes you want to copy
    // second parameter : copy the content in the second to the first address
    // first parameter : destination of copy 
    // Return : copy several bytes from long to the chars

    i = 0;
    while (chars[i] == 0){ // see which byte do not equal to 0, that is the length of one long int bytes 
    ++i;
}

printf("THe value of i: %i\n",i);
printf("tHE SIZE OF UNSIGNED LONG:%lu\n",sizeof(unsigned long));
printf("tHE SIZE OF long:%lu\n",sizeof(long));
printf("tHE SIZE OF UNSIGNED short:%lu\n",sizeof(unsigned short));
printf("tHE SIZE OF short:%lu\n",sizeof(short));
printf("tHE SIZE OF int:%lu\n",sizeof(int));
printf("tHE SIZE OF unsigned int:%lu\n",sizeof(unsigned int));
printf("tHE SIZE OF char:%lu\n",sizeof(char));


    return 0;
}

