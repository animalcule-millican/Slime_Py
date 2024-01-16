#!/usr/bin/env python3
import sys
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

input_file = sys.argv[1]
output_file = sys.argv[2]

data_dict = {}
with open(input_file, "r") as f, open(output_file, "a") as o:
    for line in f:
        row = line.strip().split("\t")
        head = row[1]
        seq = row[2]
        data_dict[row[0]] = {"header": head, "seq": seq}
    for key in data_dict.keys():
        name = data_dict[key]["header"]
        seq = data_dict[key]["seq"]
        record = SeqRecord(Seq(seq), id=name, description="")
        SeqIO.write(record, o, "fasta")

    
