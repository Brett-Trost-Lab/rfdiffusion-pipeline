#!/bin/bash

# Runs the validation pipeline from RFDiffusion -> ProteinMPNN -> AlphaFold2.

set -euo pipefail

convert_seconds() {
    printf '%02dh:%02dm:%02ds\n' $((${1}/3600)) $((${1}%3600/60)) $((${1}%60))
}

# Measure computation time
SECONDS=0
total_seconds=0

module load python/3.11.3

script_dir=$1/scripts/
run_name=$2
pdb_path=$3
hotspots=$4
min_length=$5
max_length=$6
num_structs=$7
seq_per_struct=$8
output_dir="$9/${run_name}/"

echo SCRIPT_DIR $script_dir
echo RUN_NAME $run_name
echo PDB_PATH $pdb_path
echo HOTSPOTS $hotspots
echo MIN_LENGTH $min_length
echo MAX_LENGTH $max_length
echo NUM_STRUCTS $num_structs
echo SEQ_PER_STRUCT $seq_per_struct
echo OUTPUT_DIR $output_dir

echo
echo STEP 0: Data Preparation

echo
echo Using hotspots $hotspots

echo
echo Get Contig

contig=$(python $script_dir/get_contigs.py "$pdb_path")
echo Contig $contig

echo
echo Data prep time elapsed: $(convert_seconds $SECONDS)
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo
echo STEP 1: RFDiffusion

bash $script_dir/rfdiffusion.sh "$run_name" "$output_dir" "$pdb_path" "$contig" "$hotspots" "$min_length" "$max_length" "$num_structs"

echo
echo RFDiffusion time elapsed: $(convert_seconds $SECONDS)
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo
echo STEP 2: ProteinMPNN

bash $script_dir/proteinmpnn.sh "$run_name" "$output_dir" "$seq_per_struct" "$output_dir/rfdiffusion/"

echo
echo ProteinMPNN time elapsed: $(convert_seconds $SECONDS)
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo
echo STEP 3: AlphaFold2

bash $script_dir/af2.sh "$run_name" "$output_dir" "$output_dir/proteinmpnn/"

# filter output scores
echo Filtering output scores...
python $script_dir/filter_output.py ${output_dir}/${run_name}.out.sc

echo
echo AF2 time elapsed: $(convert_seconds $SECONDS)
total_seconds=$((total_seconds+SECONDS))
echo Total time elapsed: $(convert_seconds $total_seconds)

echo
echo Done pipeline.

