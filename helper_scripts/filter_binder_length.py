"""
Given a directory of PDB complexes, get the length of the binders (chain A).
Move binders outside of the given range to a different directory.

argv[1]: input PDB dir
argv[2]: output dir
argv[3]: minimum binder length
argv[4]: maximum binder length
"""

import os
import sys
import shutil

input_dir = sys.argv[1]
output_dir = sys.argv[2]
min_length = int(sys.argv[3])
max_length = int(sys.argv[4])

def extract_chain_length(pdb_file, chain_id='A'):
    with open(pdb_file, 'r') as file:
        lines = file.readlines()
    
    chain_lines = [line for line in lines if line.startswith("ATOM") and line[21] == chain_id]
    
    if not chain_lines:
        raise ValueError("Chain {} not found in {}".format(chain_id, pdb_file))
   
    residues = set(line[22:26].strip() for line in chain_lines)
    return len(residues)

def main():
    for file_name in os.listdir(input_dir):
        if file_name.endswith('.pdb'):
            pdb_path = os.path.join(input_dir, file_name)
            try:
                binder_length = extract_chain_length(pdb_path, 'A')
                print(f"{file_name}\t{binder_length}")

                if binder_length < min_length or binder_length > max_length:
                    print(f"Exceeds range, moving to {output_dir}\n")
                    shutil.move(pdb_path, output_dir)

            except ValueError as e:
                print("Error processing {}: {}".format(file_name, e))

if __name__ == "__main__":
    main()
