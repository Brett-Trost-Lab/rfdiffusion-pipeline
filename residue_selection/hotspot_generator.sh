#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <folder>"
    exit 1
fi

# Set the folder variable
folder=$1
output_folder=$2

# Check if the provided argument is a directory
if [ ! -d "$folder" ]; then
    echo "Error: $folder is not a directory"
    exit 1
fi

if [ ! -d "$output_folder" ]; then
    echo "Error: $output_folder is not a directory"
    exit 1
fi

# Iterate through all cleaned PDB files in the folder
for cleaned_pdb in "$folder"/*_cleaned.pdb; then
    # Extract the protein name by removing the "_cleaned.pdb" suffix
    protein_name=$(basename "$cleaned_pdb" _cleaned.pdb)

    # Construct the corresponding ligand file name
    ligand_pdb="$folder/${protein_name}_ligands.pdb"

    # Check if the ligand file exists
    if [ -f "$ligand_pdb" ]; then
        echo "Processing $protein_name: $cleaned_pdb and $ligand_pdb"

        # Call the select_residues_using_AAdistance.py script
        python select_residues_using_AAdistance.py "${folder}/$cleaned_pdb" "$ligand_pdb" "$output_folder"
    else
        echo "Warning: Ligand file for $protein_name not found"
    fi
done

echo "Hotspot generation completed."