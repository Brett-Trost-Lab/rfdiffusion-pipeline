"""
Given a target protein and a known protein ligand, prints all residues on the target that are within X beta-Carbon Angstrom of the ligand. We recommend X=8.

'Two residues are considered in contact if the distance between their beta-carbon atoms (alpha-carbon for the glycine amino acid) is less than 8A.' --https://doi.org/10.1093/bioinformatics/btab355

argv[1]: target PDB
argv[2]: ligand PDB (must be a protein)
argv[3]: X (max beta-Carbon distance to ligand, in Angstroms)
"""

import os
import sys
import numpy as np
from Bio.PDB import PDBParser

target_pdb = sys.argv[1]
ligand_pdb = sys.argv[2]
MAX_DISTANCE = int(sys.argv[3])  # angstroms

HYDROPHOBIC_RESIDUES = ['ALA', 'VAL', 'LEU', 'ILE', 'PHE', 'MET', 'TRP']

def get_beta_carbons(structure):
    """
    Returns the beta carbons in the structure (alpha carbon if no beta carbon).
    """
    beta_carbons = []
    
    for model in structure:
        for chain in model:
            for residue in chain:
                if 'CB' in residue:
                    beta_carbons.append(residue['CB'])
                elif 'CA' in residue:
                    beta_carbons.append(residue['CA'])

    return beta_carbons

def calculate_distances(target_atoms, ligand_atoms):
    """
    Calculate the distance between the target and ligand beta-carbon atoms.
    Return only residue pairs that are within MAX_DISTANCE of each other.
    """
    target_coords = np.array([atom.coord for atom in target_atoms])
    ligand_coords = np.array([atom.coord for atom in ligand_atoms])

    distances = np.linalg.norm(target_coords[:, np.newaxis] - ligand_coords, axis=2)

    result = []
    for i, target_atom in enumerate(target_atoms):
        for j, ligand_atom in enumerate(ligand_atoms):
            if distances[i, j] < MAX_DISTANCE:
                result.append((distances[i, j], target_atom.get_parent(), ligand_atom.get_parent()))

    return result

def print_residue(residue, distance):
    chain = residue.get_parent().id
    resnum = residue.id[1]
    hydrophobic = "True" if (residue.resname in HYDROPHOBIC_RESIDUES) else "False"
    print(f"{chain}\t{resnum}\t{distance}\t{residue.resname}\t{hydrophobic}")

def main():
    parser = PDBParser(QUIET=True)
    target_structure = parser.get_structure('target', target_pdb)
    ligand_structure = parser.get_structure('ligand', ligand_pdb)
    
    target_atoms = get_beta_carbons(target_structure)
    ligand_atoms = get_beta_carbons(ligand_structure)
    
    distances = calculate_distances(target_atoms, ligand_atoms)
    
    seen_residues = set()
    filtered_distances = []

    for distance, target_residue, ligand_residue in sorted(distances, key=lambda x: x[0]):
        if target_residue not in seen_residues:
            filtered_distances.append((distance, target_residue, ligand_residue))
            seen_residues.add(target_residue)

    interface_residues = []
    indices = []

    print("chain\tresidue_number\tdistance\tresidue_name\thydrophobic")

    for distance, residue, _ in filtered_distances:
        print_residue(residue, distance)

if __name__ == "__main__":
    main()
