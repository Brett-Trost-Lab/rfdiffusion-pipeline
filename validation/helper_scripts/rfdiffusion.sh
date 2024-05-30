#!/bin/bash
#SBATCH -G 1 --mem 16G

set -e

repo_dir=/hpf/tools/alma8/RFDiffusion/1.1.0/

echo Loading module...

module load RFDiffusion/1.1.0

echo Activating conda...

eval "$(conda shell.bash hook)"
conda activate /hpf/tools/centos7/miniforge/3/envs/SE3nv

echo Running script...

$repo_dir/scripts/run_inference.py \
inference.output_prefix=$OUTPUT_DIR/rfdiffusion/$PDB_NAME \
inference.num_designs=2 \
"contigmap.contigs=[$1 25-30]" \
inference.input_pdb=$PDB_PATH \
"ppi.hotspot_res=[$2]" \
denoiser.noise_scale_ca=0 \
denoiser.noise_scale_frame=0

echo
echo Done.
