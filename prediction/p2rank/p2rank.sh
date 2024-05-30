#!/bin/bash

set -e

input_dir=$HOME/protein-binder-design/cleaning/clean_pdbs/
output_dir=$HOME/protein-binder-design/prediction/p2rank/outputs

echo Loading module...

module load p2rank/2.4.1

pdb_name=4lg9 # can make this not hardcoded

echo
echo Running script...
prank predict -f $input_dir/${pdb_name}_cleaned.pdb -o $output_dir/$pdb_name

echo
echo Done.
