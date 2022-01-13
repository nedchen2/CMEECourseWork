#include <stdio.h> 
#include <stdbool.h>
#include <string.h>

/* starting point of the exectuable part 
int main (void) {
    int a,b,c,d;
    a = 2;
    b = 32;
    if (!a == 0){
        printf("%i\n",!a);
    }

    char message[]="The quick fox\n"    //strchr

    char s = "q"
    if (!strchr(message,s)){
        printf("")
    }

    return a;
}
*/
int main ()
{
   const char str[] = "http://www.runoob.com"; //set the str object we would like to check
   const char ch = '.';// set the char to check object
   char *ret; //set the char remained

   ret = strchr(str, ch);

   printf("|%c| string behind is - |%s|\n", ch, ret);
   
   return(0);
}