"""
Given a directory of PDB complexes and the out.txt file, create a FASTA file with all chain As.

argv[1]: pdb_folder
argv[2]: out.txt file
"""

import os
import sys
import pandas as pd
from Bio import PDB
from Bio.SeqIO import write
from Bio.SeqRecord import SeqRecord

pdb_folder = sys.argv[1]
out_txt = sys.argv[2]

pdb_parser = PDB.PDBParser()

AMINO_ACID_MAP = {
    'ALA': 'A', 'ARG': 'R', 'ASN': 'N', 'ASP': 'D', 'CYS': 'C',
    'GLN': 'Q', 'GLU': 'E', 'GLY': 'G', 'HIS': 'H', 'ILE': 'I',
    'LEU': 'L', 'LYS': 'K', 'MET': 'M', 'PHE': 'F', 'PRO': 'P',
    'SER': 'S', 'THR': 'T', 'TRP': 'W', 'TYR': 'Y', 'VAL': 'V',
}

def extract_sequence(pdb_file):
   
    structure = pdb_parser.get_structure(pdb_file, pdb_file)
    model = structure[0]
    
    for chain in model:
        if chain.id == 'A':
            sequence = ''
            for residue in chain.get_residues():
                if PDB.is_aa(residue, standard=True):
                    sequence += AMINO_ACID_MAP[residue.resname]
            return sequence

def main():
    
    df = pd.read_csv(out_txt, sep='\s+')
    pdb_files = df['description'].tolist()
    scores = df['pae_interaction'].tolist()

    output_fasta = 'output.fasta'
    with open(output_fasta, 'w') as fasta_out:
        for i, pdb_file in enumerate(pdb_files):

            pdb_path = os.path.join(pdb_folder, pdb_file + '.pdb')
            if os.path.isfile(pdb_path):
                print(f'Processing {pdb_file}')

                sequence = extract_sequence(pdb_path)
                record = SeqRecord(sequence, id=f'{pdb_file},pae={scores[i]}', description='')
                write(record, fasta_out, "fasta")

    print(f'FASTA sequences saved to {output_fasta}')

if __name__ == "__main__":
    main()
