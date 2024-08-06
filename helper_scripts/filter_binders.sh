#!/bin/bash

# Given a directory of binder-target PDBs, create secondary structures for the binders and calculate their number of helical bundles. Move designs with fewer than MIN_HELICES helical bundles into a separate directory.

### REQUIRED POSITIONAL ARGUMENTS
pdb_dir=$(realpath $1)
min_helices=$2

set -eo pipefail

RFDIFFUSION_DIR=/hpf/tools/alma8/RFDiffusion/1.1.0/

# get path to pipeline directory
if [ -n "${SLURM_JOB_ID:-}" ] && [ "${SLURM_JOB_RESERVATION}" != "interactive" ]; then  # slurm job
    script_path=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
else  # started with bash
    script_path=$(realpath "$0")
fi

pipeline_dir=$(realpath "$(dirname ${script_path})/../")

echo PIPELINE_DIR $pipeline_dir
echo PDB_DIR $pdb_dir
echo MIN_HELICES $min_helices

if [ -z "${min_helices}" ]; then
    echo MIN_HELICES not specified. Exiting.
    exit 125
fi

echo Loading module with pyrosetta...
module load dl_binder_design/v1.0.1

echo
echo Isolating binders from their PDB complexes...
python $pipeline_dir/scripts/isolate_binders.py $pdb_dir $pdb_dir/binders_only/

echo
echo Making binder secondary structures...
python $pipeline_dir/scripts/make_secstruc.py \
    --pdb_dir $pdb_dir/binders_only/ \
    --out_dir $pdb_dir/binders_only/sec_structs/

echo
echo Filtering by number of helical bundles...

mkdir -p $pdb_dir/below_threshold/

for design in $pdb_dir/*.pdb; do
    design_name=$(basename "${design%.pdb}")

    echo
    echo Design $design_name

    binder_pdb=$pdb_dir/binders_only/${design_name}_binder.pdb
    ss_file=$pdb_dir/binders_only/sec_structs/${design_name}_binder_ss.pt
    
    if [ -f $ss_file ] && [ -f $binder_pdb ]; then
	echo Sec struct file $ss_file
	num_helices=$(python $pipeline_dir/scripts/count_helices.py $ss_file)
	echo Number of helices: $num_helices

	if [ "$num_helices" -lt "$min_helices" ]; then
	    echo Does not pass threshold. Moving design to $pdb_dir/below_threshold/
	    mv $pdb_dir/$design_name.* $binder_pdb $pdb_dir/below_threshold/
	fi

    else
	echo Sec struct file does not exist.
    fi

done

echo
echo Done.
