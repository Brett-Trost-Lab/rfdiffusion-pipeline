#!/bin/bash
#SBATCH -G 1 --mem 32G
#BATCH --job-name run_alphafold

echo
echo Loading alphafold module...

module load alphafold/2.3.2

echo
echo Running alphafold script...

alphafold \
--fasta_paths=$OUTPUT_DIR/ProteinMPNN_output/seqs/sample_1.fasta \
--output_dir=$OUTPUT_DIR/alphafold_output/ \
--model_preset=monomer_ptm \
--data_dir=$ALPHAFOLD_DIR/data/ \
--max_template_date=2024-05-01 \
--uniref90_database_path=$ALPHAFOLD_DIR/data/uniref90/uniref90.fasta \
--mgnify_database_path=$ALPHAFOLD_DIR/data/mgnify/mgy_clusters_2022_05.fa \
--template_mmcif_dir=$ALPHAFOLD_DIR/data/pdb_mmcif/mmcif_files \
--obsolete_pdbs_path=$ALPHAFOLD_DIR/data/pdb_mmcif/obsolete.dat \
--use_gpu_relax=true \
--db_preset=reduced_dbs \
--small_bfd_database_path=$ALPHAFOLD_DIR/data/small_bfd/bfd-first_non_consensus_sequences.fasta \
--pdb70_database_path=$ALPHAFOLD_DIR/data/pdb70/pdb70

echo
echo Done alphafold.

