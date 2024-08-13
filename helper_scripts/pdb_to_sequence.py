"""
Given a directory of PDB complexes, get the sequences of the binders.
Include the binder length and the pae_interaction score.

argv[1]: PDB dir
argv[2]: out.txt file
"""

import os
import sys
from pathlib import Path
import pandas as pd

input_dir = os.path.abspath(sys.argv[1])
out_txt = os.path.abspath(sys.argv[2])

AMINO_ACID_MAP = {
        'ALA': 'A', 'ARG': 'R', 'ASN': 'N', 'ASP': 'D', 'CYS': 'C',
        'GLN': 'Q', 'GLU': 'E', 'GLY': 'G', 'HIS': 'H', 'ILE': 'I',
        'LEU': 'L', 'LYS': 'K', 'MET': 'M', 'PHE': 'F', 'PRO': 'P',
        'SER': 'S', 'THR': 'T', 'TRP': 'W', 'TYR': 'Y', 'VAL': 'V',
}

def extract_sequence(pdb_file, chain_id='A'):
    with open(pdb_file, 'r') as file:
        lines = file.readlines()

    chain_lines = [line for line in lines if line.startswith("ATOM") and line[21] == chain_id]

    if not chain_lines:
        raise ValueError("Chain {} not found in {}".format(chain_id, pdb_file))

    sequence = []
    prev_res = None

    for line in chain_lines:
        res_number = line[22:26].strip()
        res_name = line[17:20].strip()

        if res_number != prev_res:
            aa = AMINO_ACID_MAP[res_name]
            sequence.append(aa)
            prev_res = res_number

    return ''.join(sequence)

def main():

    df = pd.read_csv(out_txt, sep='\t')
    df['pdb_file'] = input_dir + '/' + df['description'] + '.pdb'
    df['sequence'] = df['pdb_file'].apply(lambda x: extract_sequence(x))
    df['length'] = df['sequence'].apply(lambda x: len(x))

    output_file = 'sequences.txt'
    df[['sequence', 'length', 'pae_interaction']].to_csv(output_file, sep='\t', index=None)

if __name__ == "__main__":
    main()

