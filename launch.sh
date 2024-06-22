#!/bin/bash

# Launches a series of PDBs for RFdiffusion design and validation.

### REQUIRED ARGUMENTS
# $1. path/to/protein-binder-design/
# $2. 'input.txt'

set -e

script_dir=$(dirname $(realpath "$0"))
echo SCRIPT_DIR $script_dir

# remove carriage return characters
tmpfile=$(mktemp)
sed 's/\r//g' < $1 > $tmpfile

# add new line to end of file
echo "" >> $tmpfile

echo input.txt:
cat $tmpfile

echo Launching...

{
    read  # skip header
    while read -r run_name path_to_pdb clean hotspots min_length max_length num_structs seq_per_struct mem temp time rfdiffusion_model output_dir || # iterate through rows
    do
	echo
        echo RUN_NAME $run_name 
        echo PDB $path_to_pdb
	echo CLEAN $clean
        echo HOTSPOTS $hotspots 
        echo MIN_LENGTH $min_length
        echo MAX_LENGTH $max_length
        echo NUM_STRUCTS $num_structs
        echo SEQ_PER_STRUCT $seq_per_struct 
        echo MEM $mem 
        echo TEMP $temp
        echo TIME $time 
        echo RFDIFFUSION_MODEL $rfdiffusion_model
        echo OUTPUT_DIR $output_dir
    
        sbatch --partition=special_features --reservation=test_new_tcag_gpu --output slurm-$run_name-%j.out --gpus 1 --mem $mem --tmp $temp --time $time $script_dir/scripts/pipeline.sh $script_dir $run_name $path_to_pdb $clean $hotspots $min_length $max_length $num_structs $seq_per_struct $rfdiffusion_model $output_dir
    done
} < $tmpfile

echo
echo Done launching.
