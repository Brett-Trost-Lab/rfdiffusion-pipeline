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

def main():
    """
    Workflow:
    1. get the pdbs into dataframes
    2. calculate the centroid of the ligand as an (x, y, z) coordinate
    3. pick out hydrophobic residues closest to this point
    4. save and output them in some way. A file would be most useful
    """

    prot_pdb = pdb_to_dataframe(prot_path)
    lig_pdb = pdb_to_dataframe(ligand_path)

    centroid_x = lig_pdb['x_coordinate'].mean()
    centroid_y = lig_pdb['y_coordinate'].mean()
    centroid_z = lig_pdb['z_coordinate'].mean()

    centroid = (centroid_x, centroid_y, centroid_z)

     # Calculate centroid of each residue
    residue_centroids = prot_pdb.groupby('residue_sequence_number').agg({
        'x_coordinate': 'mean',
        'y_coordinate': 'mean',
        'z_coordinate': 'mean'
    }).reset_index()

    # Calculate distance from each residue centroid to the ligand centroid
    residue_centroids['distance_to_centroid'] = residue_centroids.apply(
        lambda row: distance(row['x_coordinate'], row['y_coordinate'], row['z_coordinate'], centroid[0], centroid[1], centroid[2]),
        axis=1
    )

    # Filter hydrophobic residues
    hydrophobic_residues = residue_centroids[prot_pdb['residue_name'].isin(['ALA', 'VAL', 'ILE', 'LEU', 'MET', 'PHE', 'PRO', 'TRP'])]

    N = 6  # Number of closest hydrophobic residues to pick

    # Sort by distance and pick the closest N residues
    # closest_residues = hydrophobic_residues.nsmallest(N, 'distance_to_centroid')

    # filter by a certain distance threshold
    d_max = 11
    hydrophobic_residues = hydrophobic_residues[hydrophobic_residues["distance_to_centroid"] <= d_max]

    # sample 6 randomly
    random_residues = hydrophobic_residues.sample(n=N)

    output_file = output_path + "/selected_residues.txt"
    random_residues.to_csv(output_file, index=False, sep='\t')

if __name__ == "__main__":
    main()
