#!/bin/bash
#SBATCH -G 1 --mem 32G
# SBATCH --job-name run_pipeline

set -e

# This script runs the pipeline from RFDiffusion -> ProteinMPNN -> alphafold.

export INPUT_DIR=$HOME/RFdiffusion_pipeline/inputs/
export OUTPUT_DIR=$HOME/RFdiffusion_pipeline/validation/test_outputs/mpro/

export RFDIFFUSION_DIR=/hpf/tools/alma8/RFDiffusion/1.1.0/
export PROTEINMPNN_DIR=/hpf/tools/alma8/ProteinMPNN/v1.0.1/
export ALPHAFOLD_DIR=/hpf/tools/centos7/alphafold/2.3.2/

### STEP 1: RFDiffusion
bash ./run_RFDiffusion.sh

### STEP 2: ProteinMPNN
bash ./run_ProteinMPNN.sh

# prepare ProteinMPNN output for alphafold
echo
echo Parsing FASTA file...
bash ./parse_fasta.sh $OUTPUT_DIR/ProteinMPNN_output/seqs/RFDiffusion_0.fa

# Step 3: alphafold
bash ./run_alphafold.sh

# extract pAE scores from alphafold output
echo
echo Loading python module...
module load python/3.11.3

echo
echo Extracting pAE scores...

python ./extract_pAE_scores.py $OUTPUT_DIR/alphafold_output/sample_1/result_model_1_ptm_pred_0.pkl

echo
echo Job done.
