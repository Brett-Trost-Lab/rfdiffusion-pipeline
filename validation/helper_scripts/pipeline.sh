#!/bin/bash
#SBATCH -G 1
#SBATCH --mem=64G --tmp=64G
#SBATCH -t 56:00:00

set -e

# This script runs the validation pipeline from RFDiffusion -> ProteinMPNN -> AlphaFold2.

export PDB_PATH=$1
input_dir=$(dirname $(realpath $PDB_PATH))

export PDB_NAME=$2
export OUTPUT_DIR=/hpf/projects/mtyers/connor/$PDB_NAME

script_dir=$input_dir/../helper_scripts/

# measure computation time
SECONDS=0
total_seconds=0

echo STEP 1: RFDiffusion

echo Contig: $3
echo Hotspots: $4

bash $script_dir/rfdiffusion.sh "$3" "$4" # 3=contig, 4=hotspots

echo RFDiffusion time elapsed: $SECONDS seconds
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo STEP 2: ProteinMPNN
bash $script_dir/proteinmpnn.sh

echo ProteinMPNN time elapsed: $SECONDS seconds
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo STEP 3: AlphaFold2
bash $script_dir/af2.sh

echo AF2 time elapsed: $SECONDS seconds

mv $PWD/${PDB_NAME}.out.sc $PWD/${PDB_NAME}.check.point $OUTPUT_DIR

echo Done pipeline.

total_seconds=$((total_seconds+SECONDS))
echo Total time elapsed: $total_seconds seconds
