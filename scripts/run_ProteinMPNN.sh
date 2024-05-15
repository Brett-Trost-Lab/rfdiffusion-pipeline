#!/bin/bash
# SBATCH --job-name run_ProteinMPNN

echo
echo Loading ProteinMPNN module...

module load ProteinMPNN/v1.0.1

echo Running ProteinMPNN script...

python $PROTEINMPNN_DIR/protein_mpnn_run.py \
--pdb_path $OUTPUT_DIR/RFDiffusion_output/RFDiffusion_0.pdb \
--out_folder $OUTPUT_DIR/ProteinMPNN_output/ \
--num_seq_per_target 1 \
--sampling_temp "0.0001"

echo
echo Done ProteinMPNN.
