import os
import argparse
import string
from pathlib import Path

"""
Integrate binders from ProteinMPNN outputs into a separate target protein PDB.

argv[1]: path to ProteinMPNN output directory
argv[2]: chain of binder (if using pipeline, will be A)
argv[3]: path to target PDB file
argv[4]: output directory
"""

def extract_chain(pdb_file, chain_id):
    """Extracts a specific chain from a PDB file."""
    with open(pdb_file, 'r') as file:
        lines = file.readlines()
    
    chain_lines = [line for line in lines if line.startswith("ATOM") and line[21] == chain_id]
    
    if not chain_lines:
        raise ValueError("Chain {} not found in {}".format(chain_id, pdb_file))
    
    return chain_lines

def renumber_residues(atom_lines, start_residue_number):
    """Renumber the residues in the given ATOM lines starting from start_residue_number."""
    new_lines = []
    current_residue_number = None
    new_residue_number = start_residue_number

    for line in atom_lines:
        residue_number = int(line[22:26].strip())
        if residue_number != current_residue_number:
            current_residue_number = residue_number
            new_residue_number += 1
        new_line = line[:22] + str(new_residue_number).rjust(4) + line[26:]
        new_lines.append(new_line)
    
    return new_lines, new_residue_number

def combine_structures(target_pdb, binder_chain_lines, output_pdb):
    """Combines the target protein with the binder chain and writes to a new PDB file."""
    with open(target_pdb, 'r') as file:
        target_lines = file.readlines()
    
    renamed_target_lines = []
    for line in target_lines:
        if line.startswith("ATOM"):
            renamed_target_lines.append(line[:21] + 'B' + line[22:])
    
    # Ensure binder chain is always 'A'
    binder_chain_lines = [line[:21] + 'A' + line[22:] for line in binder_chain_lines]
    
    # Renumber residues
    renumbered_binder_lines, last_residue_number = renumber_residues(binder_chain_lines, 0)
    renumbered_target_lines, _ = renumber_residues(renamed_target_lines, last_residue_number)
    
    combined_lines = renumbered_binder_lines + renumbered_target_lines
    
    with open(output_pdb, 'w') as file:
        file.writelines(combined_lines)

def process_folder(folder_path, binder_chain, target_pdb, output_folder):
    """Processes a folder of RFDiffusion/protein-mpnn outputs and integrates binders into the target protein."""
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    for file_name in os.listdir(folder_path):
        if file_name.endswith('.pdb'):
            pdb_path = os.path.join(folder_path, file_name)
            try:
                binder_chain_lines = extract_chain(pdb_path, binder_chain)
                output_pdb = os.path.join(output_folder, "{}_on_{}.pdb".format(os.path.splitext(file_name)[0], Path(target_pdb).stem))
                combine_structures(target_pdb, binder_chain_lines, output_pdb)
                print("Processed {}, output saved to {}".format(file_name, output_pdb))
            except ValueError as e:
                print("Error processing {}: {}".format(file_name, e))

def main():
    parser = argparse.ArgumentParser(description="Integrate binders from RFDiffusion/protein-mpnn outputs into a target protein PDB.")
    parser.add_argument("input_folder", help="Path to the folder containing RFDiffusion/protein-mpnn output PDB files")
    parser.add_argument("binder_chain", help="Chain of the binder in the PDB files")
    parser.add_argument("target_pdb", help="Path to the target protein PDB file")
    parser.add_argument("output_folder", help="Path to the folder where the combined PDB files will be saved")
    
    args = parser.parse_args()
    
    process_folder(args.input_folder, args.binder_chain, args.target_pdb, args.output_folder)
    print('Done.')

if __name__ == "__main__":
    main()


