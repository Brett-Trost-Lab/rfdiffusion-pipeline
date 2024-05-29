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
"contigmap.contigs=[$1 10-15]" \ # how to select binder length for different proteins?
inference.input_pdb=$PDB_PATH \
"ppi.hotspot_res=[A41,A145,A165]" \ # currently hardcoded, working on sampling from residue_selection output
denoiser.noise_scale_ca=0 \
denoiser.noise_scale_frame=0

echo
echo Done.
