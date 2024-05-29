#!/bin/bash

# Place desired input PDBs into INPUT_DIR.

set -e

work_dir=$HOME
input_dir=$work_dir/protein-binder-design/validation/inputs/

module load python/3.11.3

# Launch a separate job for each PDB

for pdb in $input_dir/*.pdb; do

contig=$(python ./helper_scripts/get_contigs.py $pdb)

echo Launching $pdb
echo Contig $contig

# sample hotspots here
# if hotspots not found, skip this pdb

sbatch ./helper_scripts/pipeline.sh $pdb $contig

done

echo Done launching.
