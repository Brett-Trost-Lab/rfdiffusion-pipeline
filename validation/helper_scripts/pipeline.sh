#!/bin/bash
#SBATCH -G 1
#SBATCH --mem=16G --tmp=16G

set -e

# This script runs the validation pipeline from RFDiffusion -> ProteinMPNN -> AlphaFold2.

export PDB_PATH=$1
input_dir=$(dirname $(realpath $PDB_PATH))
pdb_file_name=$(basename $PDB_PATH)

export PDB_NAME=${pdb_file_name%.*}
export OUTPUT_DIR=$input_dir/../outputs/$PDB_NAME

contig=$2

SECONDS=0 # measure computation time

script_dir=$input_dir/../helper_scripts/

echo STEP 1: RFDiffusion
bash $script_dir/rfdiffusion.sh $contig

echo RFDiffusion seconds elapsed: $SECONDS
SECONDS=0

echo STEP 2: ProteinMPNN
bash $script_dir/proteinmpnn.sh

echo ProteinMPNN seconds elapsed: $SECONDS
SECONDS=0

echo STEP 3: AlphaFold2
bash $script_dir/af2.sh

echo AF2 seconds elapsed: $SECONDS

mv $PWD/${PDB_NAME}.out.sc $PWD/${PDB_NAME}.check.point $OUTPUT_DIR

echo Done pipeline.
