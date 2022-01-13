#include <stdio.h>
#include <string.h>
#include <ctype.h>


// change the base to bits in order to illustrate the state,and is a bit more handy to invest the polymorphism.
int base_to_bits(char c){
    if (toupper(c) == 'A'){
        return 1;//0001
    }else if (toupper(c) == 'C') {
        return 1 << 1; //0010
    }else if (toupper(c) == 'T') {
        return 1 << 2;//0100
    }else if (toupper(c) == 'G') {
        return 1 << 3;//1000
    }else if (c == '?'){ //polymorphism
        return ~0; //1111
    }
    //printf ("Value %c is not a DNA base",c) ;
    

}

int main(void){
 char sp1_seq1[] = "ACCCGT";
 char sp1_seq2[] = "ACCCCT";
 char sp2_seq1[] = "ATTGCT";
 char sp3_seq1[] = "ACGCTT"; 

 // WANT TO GET THE (UNCORRECTED) GENETIC DISTANCE BETWEEN EACH SPECIES

 // Could loop over all pairwise comparisons
 int i;
 int seqlen = strlen(sp1_seq1);

 // naive method to calculate the genetic distance
 int dist_spp12 = 0;
 for (i = 0; i < seqlen; ++i){
     if (sp1_seq1[i] != sp2_seq1[i]){
         ++dist_spp12;
     }
 }
   // following we can deal with polymorphism
  int sp1_seq[seqlen];
  int sp2_seq[seqlen];
  int sp3_seq[seqlen];

  memset(sp1_seq,0,seqlen * sizeof(int));
  memset(sp2_seq,0,seqlen * sizeof(int));
  memset(sp3_seq,0,seqlen * sizeof(int));

  // Convert sp1
  for (i = 0;i < seqlen; ++i){
      sp1_seq[i] = base_to_bits(sp1_seq1[i]);
      sp1_seq[i] = sp1_seq[i] | base_to_bits(sp1_seq2[i]); // deal with polymorphism
      //sp1_seq[i] |= base_to_bits(sp1_seq2[i]);
  }

  // Convert sp2
  for (i = 0;i < seqlen; ++i){
      sp2_seq[i] |= base_to_bits(sp2_seq1[i]);
  }

  // Convert sp3
  for (i = 0;i < seqlen; ++i){
      sp3_seq[i] |= base_to_bits(sp3_seq1[i]);
  }

   // Do meaning full pairwise comparisons
   // sp1 vs sp2
    int dist = 0;
    for (i = 0; i < seqlen; ++i){
        if (!(sp1_seq[i] & sp2_seq[i])){
            ++dist;
        }
    }
    printf("Distance between sp1 and sp2: %i\n",dist);

    dist = 0;
    for (i = 0; i < seqlen; ++i){
        if (!(sp1_seq[i] & sp3_seq[i])){
            ++dist;
        }
    }
    printf("Distance between sp1 and sp3: %i\n",dist);

    dist = 0;
    for (i = 0; i < seqlen; ++i){
        if (!(sp2_seq[i] & sp3_seq[i])){
            ++dist;
        }
    }
    printf("Distance between sp2 and sp3: %i\n",dist);
  return 0;
}