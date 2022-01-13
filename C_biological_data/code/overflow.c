#include <stdio.h> 

int main(void){
    signed short int i = 1;
//signed(decrease the integer range) and unsigned / short and long
//when doing large scale, the number could overflow in certain type of data
//
    do {
        i++;
        printf("%i\n",i);
    } while (i > 0);
    return 0;
// whats the difference between signed and unsigned?  
}