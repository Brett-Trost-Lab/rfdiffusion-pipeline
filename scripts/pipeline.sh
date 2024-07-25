#!/bin/bash

# Runs the pipeline from RFDiffusion -> ProteinMPNN -> AlphaFold2.

RFDIFFUSION_DIR=/hpf/tools/alma8/RFDiffusion/1.1.0/
DL_BINDER_DESIGN_DIR=/hpf/tools/alma8/dl_binder_design/v1.0.1/base_dir/

set -eo pipefail

convert_seconds() {
    printf '%02dh:%02dm:%02ds\n' $((${1}/3600)) $((${1}%3600/60)) $((${1}%60))
}

# Measure computation time
SECONDS=0
total_seconds=0

pipeline_dir=$1
run_name=$2
path_to_pdb=$3
hotspots=$4
min_length=$5
max_length=$6
num_structs=$7
seq_per_struct=$8
output_dir="$9/${run_name}/"
scaffold_dir="${10}"

echo PIPELINE_DIR $pipeline_dir
echo RUN_NAME $run_name
echo PDB_PATH $path_to_pdb
echo HOTSPOTS $hotspots
echo MIN_LENGTH $min_length
echo MAX_LENGTH $max_length
echo NUM_STRUCTS $num_structs
echo SEQ_PER_STRUCT $seq_per_struct
echo OUTPUT_DIR $output_dir
echo SCAFFOLD_DIR $scaffold_dir

echo
echo STEP 0: Data Preparation

echo
echo Using hotspots $hotspots

echo
echo Getting Contig...

module load python/3.11.3

contig=$(python ${pipeline_dir}/scripts/get_contig.py "$path_to_pdb")
echo Contig $contig

module unload python/3.11.3

echo
echo Data prep time elapsed: $(convert_seconds $SECONDS)
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo
echo STEP 1: RFDiffusion

echo Loading module...
module load RFDiffusion/1.1.0

echo Activating conda...
eval "$(conda shell.bash hook)"
conda activate /hpf/tools/centos7/miniforge/3/envs/SE3nv

echo Running RFdiffusion...

if [ "$scaffold_dir" = "None" ]; then
    echo No fold conditioning.
    echo

    $RFDIFFUSION_DIR/scripts/run_inference.py \
        inference.input_pdb=$path_to_pdb \
	"contigmap.contigs=[$contig $min_length-$max_length]" \
	"ppi.hotspot_res=[$hotspots]" \
	inference.num_designs=$num_structs \
	inference.output_prefix=$output_dir/rfdiffusion/$run_name \
	denoiser.noise_scale_ca=0 \
	denoiser.noise_scale_frame=0
    
else
    echo Generating target scaffolds for fold conditioning...
    bash ${pipeline_dir}/scripts/make_scaffolds.sh "$path_to_pdb" "${output_dir}/target_scaffold/"

    pdb_name=$(basename -- "$path_to_pdb")
    pdb_name="${pdb_name%.*}"
    echo
    echo pdb_name $pdb_name

    target_ss=${output_dir}/target_scaffold/${pdb_name}_ss.pt
    target_adj=${output_dir}/target_scaffold/${pdb_name}_adj.pt
    echo target_ss $target_ss
    echo target_adj $target_adj
    echo

    $RFDIFFUSION_DIR/scripts/run_inference.py \
        scaffoldguided.target_path=$path_to_pdb \
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

fi

conda deactivate
module unload RFDiffusion/1.1.0

echo
echo RFDiffusion time elapsed: $(convert_seconds $SECONDS)
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo
echo STEP 2: ProteinMPNN

echo Loading module...
module load dl_binder_design/v1.0.1

echo Running ProteinMPNN...

$DL_BINDER_DESIGN_DIR/mpnn_fr/dl_interface_design.py \
    -pdbdir $output_dir/rfdiffusion/ \
    -outpdbdir $output_dir/proteinmpnn/ \
    -relax_cycles 0 \
    -seqs_per_struct $seq_per_struct \
    -checkpoint_name ${output_dir}/${run_name}.check.point \
    -temperature 0.0001  # as specified in Watson et al. supplementary methods

echo
echo ProteinMPNN time elapsed: $(convert_seconds $SECONDS)
total_seconds=$((total_seconds+SECONDS))
SECONDS=0

echo
echo STEP 3: AlphaFold2

echo Activating conda...
conda activate $DL_BINDER_DESIGN_DIR/../af2_binder_design

echo Running AF2...
$DL_BINDER_DESIGN_DIR/af2_initial_guess/predict.py \
    -pdbdir $output_dir/proteinmpnn/ \
    -outpdbdir $output_dir/af2/ \
    -checkpoint_name ${output_dir}/${run_name}.check.point \
    -scorefilename ${output_dir}/${run_name}.out.sc

conda deactivate
module unload dl_binder_design/v1.0.1

echo
echo Filtering output scores...
module load python/3.11.3
python $pipeline_dir/scripts/filter_output.py ${output_dir}/${run_name}.out.sc

echo
echo AF2 time elapsed: $(convert_seconds $SECONDS)
total_seconds=$((total_seconds+SECONDS))
echo Total time elapsed: $(convert_seconds $total_seconds)

echo
echo Done pipeline.

