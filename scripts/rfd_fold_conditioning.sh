#!/bin/bash

# Run RFdiffusion with fold conditioning.
# Scaffolds of the binders and target must first be created using make_scaffolds.sh. 

# REQUIRED ARGUMENTS:
# 1: run_name
# 2: output_dir
# 3: target pdb_path
# 4: hotspots
# 5: num_structs
# 6: target secondary structure *_ss.pt
# 7: target block adjacency *_adj.pt
# 8: binder scaffold directory (ss and adj for each scaffold)

set -eo pipefail

repo_dir=/hpf/tools/alma8/RFDiffusion/1.1.0/

echo Loading module...

module load RFDiffusion/1.1.0

echo Activating conda...

eval "$(conda shell.bash hook)"
conda activate /hpf/tools/centos7/miniforge/3/envs/SE3nv

run_name=$1
output_dir=$2
pdb_path=$3
hotspots=$4
num_structs=$5
target_ss=$6
target_adj=$7
scaffold_dir=$8

echo RUN_NAME $run_name
echo OUTPUT_DIR $output_dir
echo PDB_PATH $pdb_path
echo HOTSPOTS $hotspots
echo NUM_STRUCTS $num_structs
echo TARGET_SS $target_ss
echo TARGET_ADJ $target_adj
echo SCAFFOLD_DIR $scaffold_dir

echo
echo Running script...

$repo_dir/scripts/run_inference.py \
	scaffoldguided.target_path=$pdb_path \
	scaffoldguided.scaffoldguided=True \
	"ppi.hotspot_res=[$hotspots]" \
	scaffoldguided.target_pdb=True \
	scaffoldguided.target_ss=$target_ss \
	scaffoldguided.target_adj=$target_adj \
	scaffoldguided.scaffold_dir=$scaffold_dir \
	inference.num_designs=$num_structs \
	inference.output_prefix=$output_dir/rfdiffusion/$run_name \
	denoiser.noise_scale_ca=0 \
	denoiser.noise_scale_frame=0 \
	scaffoldguided.mask_loops=False

echo
echo Done.

