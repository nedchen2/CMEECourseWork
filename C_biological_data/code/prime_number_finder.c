#include <stdio.h>

#define LIMIT 100

int main()
	{
	    int prime = 1; // the numbers INITIALIZED to test
	    int divisor = 2; // the divisor number
	    int is_prime = 0; // the counter of number of primes
	    int n_prime = 0; // a conditional integer (if 0 it's not a prime, if 1 it's a prime)

	    while (prime < LIMIT)
	    {
	        is_prime = 0; // Set the condition to 0 (is prime)

	        for(divisor = 2; divisor <= prime/2; ++divisor) // check the values between 2 and the prime number
            //why /2? The reason is that except for the 1 and the number itself, the maximum ideal divisor would be the half of the divisor
	        {
	            if(prime % divisor == 0 ) // if the prime could be divided by other divisor
	            {
	                is_prime = 1;  // Set the condition to 1 (is not a prime)
                    
	                break;
	            }
	        }

            if (is_prime == 0){ // if the prime equals to 0, then add  the number to n_prime
                ++n_prime;//
                printf("Prime number %i th is %i\n", n_prime, prime);
            }

             ++prime;// increment number counter
	    }

	    return 0;
	}