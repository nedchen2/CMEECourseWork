#include <stdio.h> 
#include <stdbool.h>

int main (void) {
    int x ;

    // in python,we have some metadata for looping
    // C do not
    //While loop

    x = 0;
    while (x < 10){
        x = x + 2; //equals to x += 2
        x++; // equals to x= x + 1 // minus x--
    }

    //Do-while 
    x = 0;
    do {
        ++x;
    } while(x < 10);

    //For 
    for ( x= 0 ; x < 10; ++x ){
            printf("%i\n", i);
    }
    // or
    int i;
    for (i = 0; i < 10; ) {
        printf("%i\n", i);
        ++i;
    }

    // break and continue
    int i = 0;

    while () {
    if (i == 0) {
        break; // terminates the loop when meeting conditions
    }
    ++i;
}

for (i = 0; i < 10; ++i) {
	
    if (i % 2) {   	
        printf("%i is an odd number\n", i);
        continue; // skip the statement below
    } else {
        printf("%i is an even number\n", i);
    }
    
    
}

    //Goto   not necessarily
    // is similar to while in assembly code

}