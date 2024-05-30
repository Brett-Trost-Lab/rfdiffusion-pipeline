import argparse
from Bio.PDB import PDBParser
import numpy as np

def get_beta_carbons(structure):
    beta_carbons = []
    for model in structure:
        for chain in model:
            for residue in chain:
                if 'CB' in residue:
                    beta_carbons.append(residue['CB'])
                elif 'CA' in residue and residue.get_resname() == 'GLY':  # Glycine has no CB
                    beta_carbons.append(residue['CA'])
    return beta_carbons

def calculate_distances(cb_atoms_1, cb_atoms_2):
    distances = []
    for atom1 in cb_atoms_1:
        for atom2 in cb_atoms_2:
            distance = np.linalg.norm(atom1.coord - atom2.coord)
            distances.append((distance, atom1.get_parent(), atom2.get_parent()))
    return distances

def get_top_closest_pairs(pdb_file1, pdb_file2, top_n):
    parser = PDBParser(QUIET=True)
    structure1 = parser.get_structure('protein1', pdb_file1)
    structure2 = parser.get_structure('protein2', pdb_file2)
    
    cb_atoms_1 = get_beta_carbons(structure1)
    cb_atoms_2 = get_beta_carbons(structure2)
    
    distances = calculate_distances(cb_atoms_1, cb_atoms_2)
    distances.sort(key=lambda x: x[0])
    
    return distances[:top_n]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Select top closest Cβ atom pairs between two proteins.')
    parser.add_argument('pdb_file1', type=str, help='Input PDB file for the first protein')
    parser.add_argument('pdb_file2', type=str, help='Input PDB file for the second protein')
    parser.add_argument('top_n', type=int, help='Number of top closest pairs to retrieve')
    
    args = parser.parse_args()
    top_pairs = get_top_closest_pairs(args.pdb_file1, args.pdb_file2, args.top_n)
    
    for distance, res1, res2 in top_pairs:
        print("Distance: {:.2f} Å, Residue1: {}, Residue2: {}".format(distance, res1, res2))