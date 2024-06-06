#!/bin/bash

set -e

repo_dir=/hpf/tools/alma8/dl_binder_design/v1.0.1/

echo Loading module...
module load dl_binder_design/v1.0.1

echo Running script...

$repo_dir/base_dir/mpnn_fr/dl_interface_design.py \
-pdbdir $OUTPUT_DIR/rfdiffusion/ \
-outpdbdir $OUTPUT_DIR/proteinmpnn/ \
-relax_cycles 0 \
-seqs_per_struct $1 \
-checkpoint_name ${OUTPUT_DIR}/${RUN_NAME}.check.point \
-temperature 0.0001 # as specified in Watson et al. supplementary methods

echo Done.

