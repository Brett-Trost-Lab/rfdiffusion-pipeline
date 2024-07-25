import argparse
from Bio.PDB import PDBParser
import numpy as np
import os

# List of hydrophobic residues
HYDROPHOBIC_RESIDUES = ['GLY', 'ALA', 'VAL', 'LEU', 'ILE', 'PRO', 'PHE', 'MET', 'TRP']


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

def format_residue(residue, distance):
    chain_id = residue.get_parent().id
    resnum = residue.id[1]
    hydro = "True" if (residue.resname in HYDROPHOBIC_RESIDUES) else "False"
    return "{}\t{}\t{}\t{}\t{}".format(chain_id, resnum, distance, residue.resname, hydro)

def get_top_closest_pairs(pdb_file1, pdb_file2, top_n, output_dir):
    parser = PDBParser(QUIET=True)
    structure1 = parser.get_structure('protein1', pdb_file1)
    structure2 = parser.get_structure('protein2', pdb_file2)
    
    print("Parsed Structures\n")
    cb_atoms_1 = get_beta_carbons(structure1)
    cb_atoms_2 = get_beta_carbons(structure2)
    
    distances = calculate_distances(cb_atoms_1, cb_atoms_2)
    distances.sort(key=lambda x: x[0])
    
    # find the protein name for naming convention
    # Extract the filename from the path
    filename = os.path.basename(pdb_file1)

    # Split the filename and get the protein name
    protein_name = filename.split('_')[0]

    seen_residues = set()
    
    with open((output_dir + "/" + protein_name + "_hotspots.txt"), 'w') as out_file:
        print("Writing output to file: " + out_file.name)
        out_file.write("chain_identifier\tresidue_sequence_number\tdistance\tresidue_name\thydrophobic\n")  # Writing column headers
        count = 0
        for distance, res1, res2 in distances:
            if count >= top_n:
                break
            if res1.id[1] not in seen_residues:
                res1_info = format_residue(res1, distance)
                out_file.write(res1_info + '\n')
                seen_residues.add(res1.id[1])
                count += 1

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Select top closest Cβ atom pairs between two proteins.')
    parser.add_argument('pdb_file1', type=str, help='Input PDB file for the first protein')
    parser.add_argument('pdb_file2', type=str, help='Input PDB file for the second protein')
    parser.add_argument('top_n', type=int, help='Number of top closest pairs to retrieve')
    parser.add_argument('output_dir', type=str, help='Output file for residue information')
    
    print("Starting Program\n")
    args = parser.parse_args()
    get_top_closest_pairs(args.pdb_file1, args.pdb_file2, args.top_n, args.output_dir)
