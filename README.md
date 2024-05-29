# Protein Binder Design

This pipeline consists of the following steps:
1. PDB Cleaning
2. Hotspot Residue Selection / Binding Site Prediction
3. RFdiffusion Validation (RFdiffusion --> ProteinMPNN --> AlphaFold2)

## Extracting Ligands and Cleaning PDBs
Adapted from [PDB_Cleaner](https://github.com/LePingKYXK/PDB_cleaner). Clean PDBs and Ligands are outputed to the specified output path. The program will generate a cleaned PDB for all files in the specified folder. Example cleaned pdbs can be found in cleaning/clean_pdbs

usage: `python cleaning/pdb_cleaner.py <folder-of-pdbs> <folder-for-output> <save_ligands(true/false)>`

## Selecting Hotspot Residues (for proteins with ligands)
For proteins with a known ligand binder, to generate accurate and effective hotspot residues to RFDiffusion, we developed 2 methods: randomly select 6 hydrophobic residues within an 11 angstrom radius of the ligand centroid and select the top 6 residues closest to ANY atom in the ligand. This ensures they are "important" binding residues and allows us to generate residues which RFDiffusion will accept.

usage: `python residue_selection/select_residues_using_centroid.py <pdb-of-interest> <pdb-of-ligand> <output-path>`

usage: `python residue_selection/select_residues_using_AAdistance.py <pdb-of-interest> <pdb-of-ligand> <output-path>`

## Prediction

A collection of methods for protein binding site prediction when no known ligands are present.

Currently installed:
* [P2Rank](https://github.com/rdk/p2rank) (2018): A rapid, template-free machine learning model based on Random Forest.
* [ScanNet](https://github.com/jertubiana/ScanNet) (2022) Uses a geometric deep learning architecture for prediciton.

## Validation

A collection of scripts that automates the validation process of [RFdiffusion](https://github.com/RosettaCommons/RFdiffusion) using [ProteinMPNN and AlphaFold2](https://github.com/nrbennet/dl_binder_design). Developed specifically for protein binder design.
 
The validation pipeline designs a binder to specified hotspot residues on the target protein. It then evaluates how well the designed structure folds into its intended monomer structure, as well as how well it binds to its target.
 
### Input
Place desired input PDBs (cleaned) into `validation/inputs`. (Currently working on sampling hotspot residues from here as well.)
 
### Usage
`sbatch validation/launch_validation.sh`
 
### Output
Outputs for individual steps of the pipeline are located in `validation/outputs`. The RFdiffusion designed structure in `validation/outputs/<pdb_name>/rfdiffusion` can be compared with the AF2 predicted structure in `validation/outputs/<pdb_name>/af2`.
 
Predicted aligned error (pAE) scores are outputted to `validation/outputs/<pdb_name>/<pdb_name>.out.sc`.

