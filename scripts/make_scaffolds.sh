#!/bin/bash
# Make secondary structure and block adjacency pytorch files from a PDB.
# Used for RFdiffusion fold conditioning.

### REQUIRED POSITIONAL ARGUMENTS
input=$(realpath $1)  # can be PDB or directory of PDBs to scaffold
output_dir=$(realpath $2)
##############################

set -eo pipefail

RFDIFFUSION_DIR=/hpf/tools/alma8/RFDiffusion/1.1.0/

echo Loading module...
module load RFDiffusion/1.1.0

echo Activating conda...
eval "$(conda shell.bash hook)"
conda activate /hpf/tools/centos7/miniforge/3/envs/SE3nv

echo Loading module with pyrosetta...
module load dl_binder_design/v1.0.1

# check if input is a directory or single file

if [[ -d $input ]]; then
    echo $input is a directory.
    echo Running script...

    $RFDIFFUSION_DIR/helper_scripts/make_secstruc_adj.py \
        --pdb_dir $input \
        --out_dir $output_dir    

elif [[ -f $input ]]; then
    echo $input is a file.

    $RFDIFFUSION_DIR/helper_scripts/make_secstruc_adj.py \
        --input_pdb $input \
        --out_dir $output_dir
else
    echo $input is not a valid input.
    exit 1
fi

echo Done.
