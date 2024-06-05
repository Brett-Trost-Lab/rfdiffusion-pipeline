#!/bin/bash

# Runs the validation pipeline from RFDiffusion -> ProteinMPNN -> AlphaFold2.

set -e

convert_seconds() {
    printf '%02dh:%02dm:%02ds\n' $((${1}/3600)) $((${1}%3600/60)) $((${1}%60))
}

# Measure computation time
SECONDS=0
total_seconds=0

module load python/3.11.3

script_dir=$1/scripts/
name=$2
pdb_path=$3
clean=$4
hotspots=$5
min_length=$6
max_length=$7
num_structs=$8
seq_per_struct=$9
rfdiffusion_model=${10}
output_dir="${11}/${name}/"

echo SCRIPT_DIR $script_dir
echo NAME $name
echo PDB_PATH $pdb_path
echo CLEAN $clean
echo HOTSPOTS $hotspots
echo MIN_LENGTH $min_length
echo MAX_LENGTH $max_length
echo NUM_STRUCTS $num_structs
echo SEQ_PER_STRUCT $seq_per_struct
echo RFDIFFUSION_MODEL $rfdiffusion_model
echo OUTPUT_DIR $output_dir

export PDB_NAME=$name
export OUTPUT_DIR=$output_dir

echo
echo STEP 0: Data Preparation

echo
echo Clean PDB

if [ "$clean" = "yes" ] || [ "clean" = "Yes" ]; then
    # clean pdb
    temp_dir=$(mktemp -d)
    cp $pdb_path $temp_dir

    cleaner_output=$(python $script_dir/pdb_cleaner.py $temp_dir $OUTPUT_DIR/pdb/ true)
    echo "$cleaner_output"

    pdb_path=$(echo "$cleaner_output" | tail -1)
    ligand_path=$(echo "$cleaner_output" | tail -2 | head -1)
    
    echo    
    echo New pdb path: $pdb_path
    echo Ligand path: $ligand_path
else
    echo No PDB cleaning done.
fi

echo
echo Get Hotspots

# TODO: implement 'predict' and 'use_ligand'
echo $hotspots

echo
echo Get Contig

contig=$(python $script_dir/get_contigs.py "$pdb_path")
echo Contig $contig

echo
echo Data prep time elapsed: $(convert_seconds $SECONDS) seconds
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo
echo STEP 1: RFDiffusion

bash $script_dir/rfdiffusion.sh "$pdb_path" "$contig" "$hotspots" "$min_length" "$max_length" "$num_structs" "$rfdiffusion_model"

echo
echo RFDiffusion time elapsed: $(convert_seconds $SECONDS) seconds
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo
echo STEP 2: ProteinMPNN

bash $script_dir/proteinmpnn.sh "$seq_per_struct"

echo
echo ProteinMPNN time elapsed: $(convert_seconds $SECONDS) seconds
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo
echo STEP 3: AlphaFold2

bash $script_dir/af2.sh

# filter output scores
echo Filtering output scores...
python $script_dir/filter_output.py $OUTPUT_DIR/${PDB_NAME}.out.sc

echo
echo AF2 time elapsed: $(convert_seconds $SECONDS) seconds
total_seconds=$((total_seconds+SECONDS))
echo Total time elapsed: $(convert_seconds $total_seconds) seconds

echo
echo Done pipeline.

