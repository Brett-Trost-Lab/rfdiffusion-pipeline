#!/bin/bash

### REQUIRED POSITIONAL ARGUMENTS
run_name=$1
path_to_pdb=$(realpath $2)
hotspots=$3
min_length=$4
max_length=$5
num_structs=$6
output_dir=$(realpath $7)
##############################

set -eo pipefail

RFDIFFUSION_DIR=/hpf/tools/alma8/RFDiffusion/1.1.0/

# get path to pipeline directory
if [ -n "${SLURM_JOB_ID:-}" ]; then  # slurm job
    script_path=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
else  # started with bash
    script_path=$(realpath "$0")
fi

pipeline_dir=$(realpath "$(dirname ${script_path})/../")

echo PIPELINE_DIR $pipeline_dir
echo RUN_NAME $run_name
echo PDB_PATH $path_to_pdb
echo HOTSPOTS $hotspots
echo MIN_LENGTH $min_length
echo MAX_LENGTH $max_length
echo NUM_STRUCTS $num_structs
echo OUTPUT_DIR $output_dir

module load python/3.11.3

contig=$(python ${pipeline_dir}/scripts/get_contig.py "$path_to_pdb")
echo
echo Contig $contig

module unload python/3.11.3

echo
echo Loading module...
module load RFDiffusion/1.1.0

echo Activating conda...
eval "$(conda shell.bash hook)"
conda activate /hpf/tools/centos7/miniforge/3/envs/SE3nv

echo
echo Running RFdiffusion...

$RFDIFFUSION_DIR/scripts/run_inference.py \
    inference.input_pdb=$path_to_pdb \
    "contigmap.contigs=[$contig $min_length-$max_length]" \
    "ppi.hotspot_res=[$hotspots]" \
    inference.num_designs=$num_structs \
    inference.output_prefix=$output_dir/rfdiffusion/$run_name \
    denoiser.noise_scale_ca=0 \
    denoiser.noise_scale_frame=0

echo
echo Done.
