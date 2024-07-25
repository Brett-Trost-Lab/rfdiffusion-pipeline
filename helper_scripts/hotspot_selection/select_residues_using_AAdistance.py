"""
Aim of this script is to pick out 3-6 closest hydrophobic residues within a ligand binding site

LBS is approximated by the centroid of its atoms

Possible modifications involve imposing a distance requirment amongst selected residues

argv[1]: protein pdb path
argv[2]: ligand pdb path
argv[3]: output path
"""
from datetime import datetime
from numpy import char
import numpy as np
import pandas as pd
import os, re, sys, time
import sys
import typing

prot_path = sys.argv[1]
ligand_path = sys.argv[2]
output_path = sys.argv[3]

# steps to create this program:
# 1. get the pdbs into dataframes
# 2. calculate the centroid of the ligand as an (x, y, z) coordinate
# 3. pick out hydrophobic residues closest to this point
# 4. save and output them in some way. A file would be most useful

HYDROPHOBIC_RESIDUES = ['GLY', 'ALA', 'VAL', 'LEU', 'ILE', 'PRO', 'PHE', 'MET', 'TRP']

def distance(x1, y1, z1, x2, y2, z2):
    return np.sqrt((x2 - x1)**2 + (y2 - y1)**2 + (z2 - z1)**2)

def pdb_to_dataframe(pdb_file_path):
    # Define the column names
    columns = ["record_name", "atom_serial_number", "atom_name", "alternate_location", "residue_name", 
            "chain_identifier", "residue_sequence_number", "x_coordinate", "y_coordinate", 
            "z_coordinate", "occupancy", "b_factor", "element_symbol"]

    data = []

    # Read the PDB file and parse the relevant lines
    with open(pdb_file_path, 'r') as file:
        for line in file:
            if (line.startswith("ATOM") or line.startswith("HETATM")):
                record = {
                    "record_name": line[0:6].strip(),
                    "atom_serial_number": int(line[6:11].strip()),
                    "atom_name": line[12:16].strip(),
                    "alternate_location": line[16].strip(),
                    "residue_name": line[17:20].strip(),
                    "chain_identifier": line[21].strip(),
                    "residue_sequence_number": int(line[22:26].strip()),
                    "x_coordinate": float(line[30:38].strip()),
                    "y_coordinate": float(line[38:46].strip()),
                    "z_coordinate": float(line[46:54].strip()),
                    "occupancy": float(line[54:60].strip()),
                    "b_factor": float(line[60:66].strip()),
                    "element_symbol": line[76:78].strip()
                }
                data.append(record)

    # Create a DataFrame
    df = pd.DataFrame(data, columns=columns)
    return df

def min_distance_to_ligand(row, lig_pdb):
    return lig_pdb.apply(lambda lig_row: distance(row['x_coordinate'], row['y_coordinate'], row['z_coordinate'], 
                                                  lig_row['x_coordinate'], lig_row['y_coordinate'], lig_row['z_coordinate']), axis=1).min()

def main():
    """
    Workflow:
    1. get the pdbs into dataframes
    3. pick out hydrophobic residues only
    4. find minumum distance from residue centroids to single atom on ligand
    5. pick randomly amongst best residues
    """

    prot_pdb = pdb_to_dataframe(prot_path)
    lig_pdb = pdb_to_dataframe(ligand_path)
    print("Parsed Structures")

    # Find all residue centers
    residue_centroids = prot_pdb.groupby(['chain_identifier', 'residue_sequence_number', 'residue_name']).agg({
        'x_coordinate': 'mean',
        'y_coordinate': 'mean',
        'z_coordinate': 'mean'
    }).reset_index()

    # Calculate minimum distance from each residue centroid to any atom in the ligand
    residue_centroids['min_distance_to_ligand'] = residue_centroids.apply(min_distance_to_ligand, lig_pdb=lig_pdb, axis=1)

    # Filter by a certain distance threshold
    d_max = 11
    close_hydrophobic_residues = residue_centroids[residue_centroids['min_distance_to_ligand'] <= d_max]

    # Randomly sample 6 residues
    # N = 6
    # if len(close_hydrophobic_residues) < N:
    #     N = len(close_hydrophobic_residues)  # Adjust N if there are less than 6 residues

    # close_hydrophobic_residues = close_hydrophobic_residues.sample(n=N)


    close_hydrophobic_residues.sort_values(by=['min_distance_to_ligand'], inplace=True)

    close_hydrophobic_residues['is_hydrophobic'] = close_hydrophobic_residues['residue_name'].isin(HYDROPHOBIC_RESIDUES)
    close_hydrophobic_residues = close_hydrophobic_residues.drop(columns=['x_coordinate', 'y_coordinate', 'z_coordinate'])

    # find the protein name for naming convention
    # Extract the filename from the path
    filename = os.path.basename(prot_path)

    # Split the filename and get the protein name
    protein_name = filename.split('_')[0]

    # Save the selected residues to a text file
    output_file = output_path + "/" + protein_name + "_hotspots.txt"
    print("Writing output to file: "+ output_file)
    close_hydrophobic_residues.to_csv(output_file, index=False, sep='\t')




if __name__ == "__main__":
    print("Starting Program\n")
    main()
