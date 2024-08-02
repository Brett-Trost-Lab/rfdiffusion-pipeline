"""
Given a directory of PDB complexes, isolate the binders (chain A).

argv[1]: input PDB dir
argv[2]: output dir
"""

import os
import sys

input_dir = sys.argv[1]
output_dir = sys.argv[2]

def extract_chain(pdb_file, chain_id='A'):
    """Extracts a specific chain from a PDB file."""
    with open(pdb_file, 'r') as file:
        lines = file.readlines()
    
    chain_lines = [line for line in lines if line.startswith("ATOM") and line[21] == chain_id]
    
    if not chain_lines:
        raise ValueError("Chain {} not found in {}".format(chain_id, pdb_file))
    
    return chain_lines

def main():
    """Processes a folder of PDB complexes and isolates binders from their targets."""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for file_name in os.listdir(input_dir):
        if file_name.endswith('.pdb'):
            pdb_path = os.path.join(input_dir, file_name)
            try:
                binder_chain_lines = extract_chain(pdb_path, 'A')
                output_pdb = os.path.join(output_dir, "{}_binder.pdb".format(os.path.splitext(file_name)[0]))
                with open(output_pdb, 'w') as file:
                    file.writelines(binder_chain_lines)
                print("Processed {}, output saved to {}".format(file_name, output_pdb))
            except ValueError as e:
                print("Error processing {}: {}".format(file_name, e))


if __name__ == "__main__":
    main()
