#!/bin/bash
#SBATCH -G 1 --mem=8G
#SBATCH --job-name test_RFdiffusion_pipeline

# This shell script runs the pipeline from RFDiffusion -> ProteinMPNN -> alphafold.

input_dir=$HOME/RFdiffusion_pipeline/inputs/
output_dir=$HOME/RFdiffusion_pipeline/test_outputs/mpro_binder/

# Important: Files with the same name may not be overwritten.

RFDiffusion_dir=/hpf/tools/alma8/RFDiffusion/1.1.0/
ProteinMPNN_dir=/hpf/tools/alma8/ProteinMPNN/v1.0.1/
alphafold_dir=/hpf/tools/centos7/alphafold/2.3.2/

# Step 1: RFDiffusion to generate a structure

echo Loading RFDiffusion module...

module load RFDiffusion/1.1.0

echo
echo Activating conda...

eval "$(conda shell.bash hook)"
conda activate /hpf/tools/centos7/miniforge/3/envs/SE3nv

echo
echo Running RFDiffusion script...

$RFDiffusion_dir/scripts/run_inference.py \
inference.output_prefix=$output_dir/RFDiffusion/RFDiffusion \
inference.num_designs=1 \
'contigmap.contigs=[A1-305/0 25-50]' \
inference.input_pdb=$input_dir/pdbs/6w63.pdb \
'ppi.hotspot_res=[A41,A145]' \
denoiser.noise_scale_ca=0 \
denoiser.noise_scale_frame=0

echo
echo Done RFDiffusion.

# Step 2: ProteinMPNN to retrieve the amino acid sequence

echo
echo Loading ProteinMPNN module...

module load ProteinMPNN/v1.0.1

echo Running ProteinMPNN script...

python $ProteinMPNN_dir/protein_mpnn_run.py \
--pdb_path $output_dir/RFDiffusion/RFDiffusion_0.pdb \
--out_folder $output_dir/ProteinMPNN/ \
--num_seq_per_target 8
--sampling_temp "0.0001"

echo
echo Done ProteinMPNN.

# Step 3: alphafold to regenerate the structure using the sequence

# Prepare output from ProteinMPNN for alphafold
echo
echo Parsing FASTA file...
bash ./parse_fasta.sh $output_dir/ProteinMPNN/seqs/RFDiffusion_0.fa

echo
echo Loading alphafold module...

module load alphafold/2.3.2

echo
echo Running alphafold script...

alphafold \
--fasta_paths=$output_dir/ProteinMPNN/seqs/sample_1.fasta \
--output_dir=$output_dir/alphafold/ \
--data_dir=$alphafold_dir/data/ \
--max_template_date=2024-05-01 \
--uniref90_database_path=$alphafold_dir/data/uniref90/uniref90.fasta \
--mgnify_database_path=$alphafold_dir/data/mgnify/mgy_clusters_2022_05.fa \
--template_mmcif_dir=$alphafold_dir/data/pdb_mmcif/mmcif_files \
--obsolete_pdbs_path=$alphafold_dir/data/pdb_mmcif/obsolete.dat \
--use_gpu_relax=true \
--db_preset=reduced_dbs \
--small_bfd_database_path=$alphafold_dir/data/small_bfd/bfd-first_non_consensus_sequences.fasta \
--pdb70_database_path=$alphafold_dir/data/pdb70/pdb70

echo
echo Done alphafold.

echo
echo Job done.
