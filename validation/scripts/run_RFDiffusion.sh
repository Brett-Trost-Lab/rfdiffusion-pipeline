#!/bin/bash
#SBATCH -G 1 --mem 8G
#SBATCH --job-name run_RFDiffusion

echo Loading RFDiffusion module...

module load RFDiffusion/1.1.0

echo
echo Activating conda...

eval "$(conda shell.bash hook)"
conda activate /hpf/tools/centos7/miniforge/3/envs/SE3nv

echo
echo Running RFDiffusion script...

$RFDIFFUSION_DIR/scripts/run_inference.py \
inference.output_prefix=$OUTPUT_DIR/RFDiffusion_output/RFDiffusion \
inference.num_designs=1 \
'contigmap.contigs=[A1-305/0 25-50]' \
inference.input_pdb=$INPUT_DIR/6w63.pdb \
'ppi.hotspot_res=[A41,A145]' \
denoiser.noise_scale_ca=0 \
denoiser.noise_scale_frame=0

echo
echo Done RFDiffusion.
