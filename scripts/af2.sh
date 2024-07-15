#!/bin/bash

set -euo pipefail

repo_dir=/hpf/tools/alma8/dl_binder_design/v1.0.1

echo Loading module...
module load dl_binder_design/v1.0.1

echo Activating conda...
eval "$(conda shell.bash hook)"
conda activate $repo_dir/af2_binder_design

run_name=$1
output_dir=$2
input_dir=$3

echo RUN_NAME $run_name
echo OUTPUT_DIR $output_dir
echo INPUT_DIR $input_dir

mkdir -p $output_dir

echo
echo Running script...

$repo_dir/base_dir/af2_initial_guess/predict.py \
-pdbdir $input_dir \
-outpdbdir $output_dir/af2/ \
-checkpoint_name ${output_dir}/${run_name}.check.point \
-scorefilename ${output_dir}/${run_name}.out.sc \
-recycle 3

echo
echo Done.
