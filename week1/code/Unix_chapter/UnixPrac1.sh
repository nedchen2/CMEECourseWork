#Prepare
#cd to the working directory
cd ~/Documents/CMEECourseWork/week1/code
#I put some of the fasta fill in ~/Documents/CMEECourseWork/week1/data/fasta
#ls to see the content of it 


../ dot dot slash ,
& anpercent,
; semicolon,
: colon,
- dash,
- hyphen.

ls ../data/fasta/
#head to see the content of it
head -10 ../data/fasta/E.coli.fasta
#solutions would be positively marked if the command line is short/ you have less character

#1
#Count how many lines there are in each file

#### if we do not need the dir, we can use the < , like wc -l < $i to just output the numerical value

for i in ../data/fasta/*.fasta; do wc -l $i ;done

or

wc -l $(find ../data/fasta/ -name "*.fasta")

or

wc -l ../data/fasta/*.fasta

#2
#Print everything starting from the second line for the E. coli genome
sed "1d" ../data/fasta/E.coli.fasta 

or

grep -v ">" ../data/fasta/E.coli.fasta
 
or 

tail -n +2 ../data/fasta/E.coli.fasta

#3
#Count the sequence length of this genome
grep -v ">" ../data/fasta/E.coli.fasta | wc -m

#4
#Count the matches of a particular sequence, “ATGC” in the genome of E. coli (hint: Start by removing the first line and removing newline characters)
#grep -o could just output the part it matches
grep -v ">" ../data/fasta/E.coli.fasta | sed "s/\n//g"|grep -o "ATGC"| wc -l

or

grep -v ">" ../data/fasta/E.coli.fasta | sed "s/\n//g"|grep -o "ATGC"| uniq -c

#5
#Compute the AT/GC ratio. That is, the (A+T)/(G+C) ratio. 
#This is a summary measure of base composition of double-stranded DNA. DNA from different organisms and lineages has different ratios of the A-to-T and G-to-C base pairs.
#For example DNA from organisms that live in hot springs have a higher GC content, which takes advantage of the increased thermal stability of the GC base pair (google “Chargaff’s rule”)

#For every single result
for i in {"A","G","T","C"}; do echo "Calculating $i";
result=`grep -v ">" ../data/fasta/E.coli.fasta | sed "s/\n//g"| grep -o $i | wc -l`;
echo "the count of $i is: $result";
done
#For the AT/GC
AT_Sum=`grep -v ">" ../data/fasta/E.coli.fasta | sed "s/\n//g"| grep -E -o "A|T"  | wc -l`
echo "AT Base Number: $AT_Sum"
GC_Sum=`grep -v ">" ../data/fasta/E.coli.fasta | sed "s/\n//g"| grep -E -o "G|C"  | wc -l`
echo "GC Base Number: $GC_Sum"
AT_GC_R=`awk 'BEGIN{printf "%.2f%%",'$AT_Sum'/'$GC_Sum'*100}'`
echo "(AT/GC) result is $AT_GC_R"
#GC content
GC_content_R=$(printf "%d%%" $((GC_Sum*100/(GC_Sum+AT_Sum))))
echo "GC content result is $GC_content_R"
#Float result
GC_content_R=`awk 'BEGIN{printf "%.2f%%",'$GC_Sum'/('$GC_Sum'+'$AT_Sum')*100}'`
echo "GC content result is $GC_content_R"

AT_Sum=`grep -v ">" ../data/fasta/E.coli.fasta | sed "s/\n//g"| grep -E -o "A|T"  | wc -l`;GC_Sum=`grep -v ">" ../data/fasta/E.coli.fasta | sed "s/\n//g"| grep -E -o "G|C"  | wc -l`;AT_GC_R=`awk 'BEGIN{printf "%.2f%%",'$AT_Sum'/'$GC_Sum'*100}'`;echo "(AT/GC) result is $AT_GC_R"



