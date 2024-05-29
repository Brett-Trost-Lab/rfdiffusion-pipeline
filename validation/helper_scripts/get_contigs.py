"""
Extract contigs from a cleaned PDB for RFdiffusion binder design.

e.g. A PDB with two chains (chain A with residues 1-50, chain B with residues 25-75,
should return 'A1-50/0 B25-75/0 '. The /0 specified a chain break.)

Note that this passes the entire target protein to RFdiffusion, with no truncation.
Also, this currently cannot handle PDBs with sequence gaps (e.g. A1-25/28-50).

argv[1]: protein pdb path
"""

import sys
import pandas as pd

pdb_path = sys.argv[1]

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
    df = pdb_to_dataframe(pdb_path)
    chains = df['chain_identifier'].unique().tolist()
    
    contig = ''

    for chain in chains:
        df_chain = df[df['chain_identifier'] == chain]
        start_residue = df_chain.iloc[1,6]
        end_residue = df_chain.iloc[-1,6]
        contig = contig + chain + str(start_residue) + '-' + str(end_residue) + '/0 '

    print(contig)

if __name__ == "__main__":
    main()
