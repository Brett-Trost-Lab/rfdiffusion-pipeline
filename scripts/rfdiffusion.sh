#!/bin/bash

set -e

repo_dir=/hpf/tools/alma8/RFDiffusion/1.1.0/

echo Loading module...

module load RFDiffusion/1.1.0

echo Activating conda...

eval "$(conda shell.bash hook)"
conda activate /hpf/tools/centos7/miniforge/3/envs/SE3nv

echo Running script...

pdb_path=$1
contig=$2
hotspots=$3
min_length=$4
max_length=$5
num_structs=$6
rfdiffusion_model=$7

echo PDB_PATH $pdb_path
echo CONTIG $contig
echo HOTSPOTS $hotspots
echo MIN_LENGTH $min_length
echo MAX_LENGTH $max_length
echo NUM_STRUCTS $num_structs
echo RFDIFFUSION_MODEL $rfdiffusion_model

$repo_dir/scripts/run_inference.py \
inference.input_pdb=$pdb_path \
"contigmap.contigs=[$contig $min_length-$max_length]" \
"ppi.hotspot_res=[$hotspots]" \
inference.num_designs=$num_structs \
inference.ckpt_override_path=$repo_dir/models/$rfdiffusion_model \
inference.output_prefix=$OUTPUT_DIR/rfdiffusion/$RUN_NAME \
denoiser.noise_scale_ca=0 \
denoiser.noise_scale_frame=0

echo
echo Done.
