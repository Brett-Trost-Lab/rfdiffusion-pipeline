#!/bin/bash

### REQUIRED POSITIONAL ARGUMENTS
run_name=$1
input_dir=$(realpath $2)
output_dir=$(realpath $3)
#############################

set -eo pipefail

DL_BINDER_DESIGN_DIR=/hpf/tools/alma8/dl_binder_design/v1.0.1/base_dir/

# get path to pipeline directory
if [ -n "${SLURM_JOB_ID:-}" ]; then  # job
    batch_job=$(scontrol show job ${SLURM_JOB_ID} | grep BatchFlag | awk -F "BatchFlag=" '{print $2}' | awk '{print $1}')
    if [ "${batch_job}" = "1" ]; then  # batch job
        script_path=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
    else  # interactive shell
        script_path=$(realpath "$0")
    fi
else
    script_path=$(realpath "$0")
fi

pipeline_dir=$(realpath "$(dirname ${script_path})/../")

echo PIPELINE_DIR $pipeline_dir
echo RUN_NAME $run_name
echo INPUT_DIR $input_dir
echo OUTPUT_DIR $output_dir

echo Loading module...
module load dl_binder_design/v1.0.1

## TEMPORARY FIX, WAITING FOR NEW MODULE ##
pip install numpy==1.26.4
pip install numba==0.58.1
###########################################

echo Activating conda...
eval "$(conda shell.bash hook)"
conda activate $DL_BINDER_DESIGN_DIR/../af2_binder_design

mkdir -p $output_dir

echo
echo Running script...

$DL_BINDER_DESIGN_DIR/af2_initial_guess/predict.py \
    -pdbdir $input_dir \
    -outpdbdir $output_dir/af2/ \
    -checkpoint_name ${output_dir}/${run_name}.check.point \
    -scorefilename ${output_dir}/${run_name}.out.sc

conda deactivate
module unload dl_binder_design/v1.0.1

echo
echo Filtering output scores...
module load python/3.11.3
python $pipeline_dir/scripts/filter_output.py ${output_dir}/${run_name}.out.sc

echo
echo Done.
