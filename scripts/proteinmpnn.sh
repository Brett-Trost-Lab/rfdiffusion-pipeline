#!/bin/bash

set -e

repo_dir=/hpf/tools/alma8/dl_binder_design/v1.0.1/

echo Loading module...
module load dl_binder_design/v1.0.1

echo Running script...

run_name=$1
output_dir=$2
seqs_per_struct=$3

echo RUN_NAME $run_name
echo OUTPUT_DIR $output_dir

$repo_dir/base_dir/mpnn_fr/dl_interface_design.py \
-pdbdir $output_dir/rfdiffusion/ \
-outpdbdir $output_dir/proteinmpnn/ \
-relax_cycles 0 \
-seqs_per_struct $seqs_per_struct \
-checkpoint_name ${output_dir}/${run_name}.check.point \
-temperature 0.0001 # as specified in Watson et al. supplementary methods

echo Done.

