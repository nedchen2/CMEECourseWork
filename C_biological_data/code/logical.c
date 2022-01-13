#include <stdio.h> 
#include <stdbool.h>

int main (void) {
    _Bool x = false; // for true or false from stdio.h
    bool y = true; // def: 1 from stdbool.h

    if (x){ // the bracket could be eliminated
        printf("x is true\n");
    } else {
        printf("x is false\n");
    } // similar to R

    int i = 9 // ""=="" comparision operators "!"
    if (i) {printf("i is true\n")}

    // Binary logical operators:
    // var && var : AND
    // VAR || VAR : OR

    //ternary conditional: x ? y : z (ifelse (x,y returns false, then give out z))

    return 0;
}




