from Bio.Blast import NCBIWWW
import pandas as pd
from Bio.Blast import NCBIXML
from sqlalchemy import column

df = pd.read_table("../results/3.Taxonomy_ana/Unassigned_blastn-result.tsv")

Top10 = df.loc[0:10,:]

fasta_string = Top10.loc[:,"Sequence"]

E_VALUE_THRESH = 0.04

for i in range(0,len(fasta_string)):
    result_handle = NCBIWWW.qblast("blastn", "nt", fasta_string[i],megablast= "TRUE",entrez_query = "all [filter] NOT(environmental samples[organism] OR metagenomes[orgn])", hitlist_size=1)
    blast_record = NCBIXML.read(result_handle)
    for alignment in blast_record.alignments:
        for hsp in alignment.hsps:
            if hsp.expect < E_VALUE_THRESH:
                Top10.loc[i,"title"] = alignment.title
                Top10.loc[i,"length"] = alignment.length
                Top10.loc[i,"evalue"] = hsp.expect
                Top10.loc[i,"MimicPercIdentity"] = hsp.identities/hsp.align_length
                print ('****Alignment****')
                print ('sequence:', alignment.title)
                print ('length:', alignment.length)
                print ('e value:', hsp.expect)
                print ('MimicPercIdentity', hsp.identities/hsp.align_length)
                print (hsp.query[0:75] + '...')
                print (hsp.match[0:75] + '...')
                print (hsp.sbjct[0:75] + '...')

Top10.to_csv("../results/blast/top10_unassigned_blast_result.tsv",sep = "\t")



