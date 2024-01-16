#!/usr/bin/env python3
import argparse
import pandas as pd 
#import numpy as np

#list_hits = []

def arg_parser():
    parser = argparse.ArgumentParser(description='Count the number of hits for each query')
    parser.add_argument('-i', '--input', help='Input file', required=True)
    parser.add_argument('-o', '--output', help='Output file', required=True)
    args = parser.parse_args()
    return args

#def get_counts(in_file):
#    with open(in_file, 'r') as f:
##        for line in f:
 #           row = line.strip()
 #           list_hits.append(row.split('\t')[2])
#    values, counts = np.unique(list_hits, return_counts=True)
#    return values, counts

#def counts_to_dict(values, counts):
#    result_dict = dict(zip(values, zip(counts, [1]*len(counts))))
#    return result_dict

#def save_dict(out_file, result_dict):
#    with open(out_file, 'w') as out:
#        df = pd.DataFrame.from_dict(result_dict, orient='index', columns=['hits', 'counts'])
#        df.to_csv(out, sep='\t')

def main():
    args = arg_parser()
    df = pd.read_csv(args.input, sep='\t', header=None, names=['q', 'qh', 't', 'th'])
    df = df.groupby(['t']).agg({'q': ['count']}).reset_index()
    df.columns = ['hits', 'counts']
    df.to_csv(args.output, sep='\t', index=False)

if __name__ == '__main__':
    main()