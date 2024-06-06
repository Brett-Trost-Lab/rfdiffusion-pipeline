#!/bin/bash

set -e

repo_dir=/hpf/tools/alma8/dl_binder_design/v1.0.1

echo Loading module...
module load dl_binder_design/v1.0.1

echo Activating conda...
eval "$(conda shell.bash hook)"
conda activate $repo_dir/af2_binder_design

run_name=$1
output_dir=$2

echo RUN_NAME $1
echo OUTPUT_DIR $2

echo Running script...
$repo_dir/base_dir/af2_initial_guess/predict.py \
-pdbdir $output_dir/proteinmpnn/ \
-outpdbdir $output_dir/af2/ \
-checkpoint_name ${output_dir}/${run_name}.check.point \
-scorefilename ${output_dir}/${run_name}.out.sc

echo Done.
