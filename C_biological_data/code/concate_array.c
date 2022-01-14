#include <stdio.h>

void print_intarray(int integers[], int nelems) //init a function for print the items in the array
{
    int i;
    for (i = 0; i < nelems; ++i) {
        printf("%i ", integers[i]);
    }
    printf("\n");
}

int main(void){
    
    const int arraymax = 10;
    

    int array1[] = {1,2,3,4,5,6};
    int array2[] = {7,8,9,10};
    int array3[arraymax];
    int length;
    int length2;
    int i;

    length = sizeof(array1)/sizeof(array1[0]);

    print_intarray(array1, arraymax);


    for (i = 0; i < length; ++i) {
        array3[i] = array1[i]  ;  
    }

    length2 = sizeof(array2)/sizeof(array2[0]);

    for (i = 0 ; i < length2; ++i) {
        array3[i + length ] = array2[i];
    }

    print_intarray(array3, arraymax);

}

