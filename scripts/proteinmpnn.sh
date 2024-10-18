#!/bin/bash

### REQUIRED POSITIONAL ARGUMENTS
run_name=$1
input_dir=$(realpath $2)
seqs_per_struct=$3
output_dir=$(realpath $4)
##############################

set -euo pipefail

DL_BINDER_DESIGN_DIR=/hpf/tools/alma8/dl_binder_design/v1.0.1/base_dir/

echo Loading module...
module load dl_binder_design/v1.0.1

## TEMPORARY FIX, WAITING FOR NEW MODULE ##
pip install numpy==1.26.4
pip install numba==0.58.1
###########################################

echo RUN_NAME $run_name
echo OUTPUT_DIR $output_dir
echo SEQS_PER_STRUCT $seqs_per_struct
echo INPUT_DIR $input_dir

echo
echo Running script...

$DL_BINDER_DESIGN_DIR/mpnn_fr/dl_interface_design.py \
    -pdbdir $input_dir \
    -outpdbdir $output_dir/proteinmpnn/ \
    -relax_cycles 0 \
    -seqs_per_struct $seqs_per_struct \
    -checkpoint_name ${output_dir}/${run_name}.check.point \
    -temperature 0.0001 # as specified in Watson et al. supplementary methods

echo Done.

