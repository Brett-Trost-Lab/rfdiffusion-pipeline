#!/bin/bash

set -e

repo_dir=/hpf/tools/alma8/dl_binder_design/v1.0.1

echo Loading module...
module load dl_binder_design/v1.0.1

echo Activating conda...
eval "$(conda shell.bash hook)"
conda activate $repo_dir/af2_binder_design

echo Running script...
$repo_dir/base_dir/af2_initial_guess/predict.py \
-pdbdir $OUTPUT_DIR/proteinmpnn/ \
-outpdbdir $OUTPUT_DIR/af2/ \
-checkpoint_name ${OUTPUT_DIR}/${PDB_NAME}.check.point \
-scorefilename ${OUTPUT_DIR}/${PDB_NAME}.out.sc

echo Done.
