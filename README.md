# Protein Binder Design

In 2023, researchers at the Baker Lab published [RFdiffusion](https://github.com/RosettaCommons/RFdiffusion), a deep-learning framework for de novo protein design. Using [ProteinMPNN and AlphaFold2](https://github.com/nrbennet/dl_binder_design) for validation, the authors demonstrated RFdiffusion's ability to tackle a diverse range of design challenges, including the successful generation of high-affinity binders to desired target proteins.

# Automated Pipeline

A collection of scripts that automates the validation process of RFdiffusion &#8594; ProteinMPNN &#8594; AlphaFold2 (AF2). Developed specifically for protein binder design.

In this pipeline, RFdiffusion designs binders to hotspot residues on the target protein. It then uses AF2 to evaluate how well the designs will fold into their intended monomer structures, as well as how likely they will bind to their target.
 
### Input
Specify all input configurations in a single text file, one row per target protein. This file MUST follow the format provided in `inputs/input.txt` with the headers included. The parameters are as follows:
| Parameter | Description | Examples | Notes |
| --- | --- | --- | --- |
| RUN_NAME | Name of the run | test_run | Must be unique. Can have two runs with the same target PDB but different names. |
| PATH_TO_PDB | Absolute path to target PDB | /home/usr/inputs/target.pdb | Avoid ~, $HOME, .., etc. |
| CLEAN | Whether to clean the target PDB (yes/no) | yes | Avoid cleaning already cleaned PDBs |
| HOTSPOTS | Hotspots for RFdiffusion | A232,A245,A271 | Enter 'predict' to sample hotspots from a predicted binding site |
| MIN_LENGTH | Minimum length for binder (aa) | 20 | |
| MAX_LENGTH | Maximum length for binder (aa) | 60 | |
| NUM_STRUCTS | Number of RFdiffusion structures to generate  | 1000 | |
| SEQUENCES_PER_STRUCT | Number of ProteinMPNN sequences to generate for each structure | 2 | |
| MEM | Amount of memory for job to use | 128G | See [Slurm HPC Quickstart](https://hpc.ccm.sickkids.ca/w/index.php/Slurm_HPC_Quickstart) for syntax |
| TEMP | Amount of temporary space for job to use | 128G | |
| TIME | Maximum time allotted for job | 48:00:00 | |
| RFDIFFUSION_MODEL | RFdiffusion model to use | Complex_base_ckpt.pt | Alternative option: Complex_beta_ckpt.pt |
| OUTPUT_DIR | Output directory | /home/usr/outputs/ | |
 
### Usage
```
bash validation/launch.sh inputs/input.txt
```
### Output
Output scores are provided in `<OUTPUT_DIR>/<NAME>/<NAME>.out.txt`.

RFdiffusion designed structures in `<OUTPUT_DIR>/<NAME>/rfdiffusion/` can be compared with their respective AF2 predicted structures in `<OUTPUT_DIR>/<NAME>/af2/`.

# Individual Steps of the Pipeline

The following explains how to run components of the pipeline individually.

## PDB Cleaning
Adapted from [PDB_Cleaner](https://github.com/LePingKYXK/PDB_cleaner). Clean PDBs and any ligands are outputted to the specified output path. The program will generate a cleaned PDB for all files in the specified folder.

usage: `python scripts/pdb_cleaner.py <folder-of-pdbs> <folder-for-output> <save_ligands(true/false)>`

## Selecting Hotspot Residues

### Proteins with a Ligand (outdated)
For proteins with a known ligand, to generate accurate and effective hotspot residues to RFDiffusion, we developed 2 methods: 1) randomly select 6 hydrophobic residues within an 11-angstrom radius of the ligand centroid, and 2) select the top 6 residues closest to ANY atom in the ligand. This ensures they are "important" binding residues and allows us to generate residues that RFDiffusion will accept.

usage: `python residue_selection/select_residues_using_centroid.py <pdb-of-interest> <pdb-of-ligand> <output-path>`

usage: `python residue_selection/select_residues_using_AAdistance.py <pdb-of-interest> <pdb-of-ligand> <output-path>`

### Proteins without a Ligand

A collection of scripts that run protein binding site prediction methods. To be used when no known ligands are present, or novel binding sites are desired.

Currently installed:
#### [P2Rank](https://github.com/rdk/p2rank) (2018) (used in validation pipeline)
A rapid, template-free machine learning model based on Random Forest.

1. `sbatch scripts/p2rank.sh <input_pdb> <output_dir>`

Predicted pockets will be output in order of confidence to `output_dir/<pdb_name>.pdb_predictions.csv`. Pockets and residues can be viewed by downloading and opening `output_dir/visualizations/`. One pocket and its hotspots can then be extracted into a text file:

2. `python scripts/extract_hotspots.py <pdb_name> <pdb_name>.pdb_predictions.csv <pocket_number>`

This `<pdb_name>_hotspots.txt` output will be created in the same location as `<pdb_name>.pdb_predictions.csv`. To sample and format hotspots to pass to RFdiffusion:

3. `python scripts/sample_hotspots.py <pdb_name>_hotspots.txt`

This will return a set of hotspots in the correct format for RFdiffusion. e.g. `A232,A245,A271`

#### [ScanNet](https://github.com/jertubiana/ScanNet) (2022)
* A geometric deep learning architecture for prediction.
* Usage: `sbatch helper_scripts/scannet/scannet.sh` (specify the protein inside of the script)

## RFdiffusion
1. Get contig

The contig tells RFdiffusion what section of the target protein to use. To extract the contig for the entire target protein:

`python scripts/get_contigs.py <PATH_TO_PDB>`

Output contig is printed.

2. Run script
   
`sbatch --gpus 1 scripts/rfdiffusion.sh <RUN_NAME> <OUTPUT_DIR> <PATH_TO_PDB> <CONTIG> <HOTSPOTS> <MIN_LENGTH> <MAX_LENGTH> <NUM_STRUCTS> <RFDIFFUSION_MODEL>` (GPU required, specify more resources as necessary)

Results are output to `<OUTPUT_DIR>/rfdiffusion/`.

## ProteinMPNN
RFdiffusion output must be in `<OUTPUT_DIR>/rfdiffusion/`.

`sbatch scripts/proteinmpnn.sh <RUN_NAME> <OUTPUT_DIR> <SEQ_PER_STRUCT>` (no GPU required, specify more resources as necessary)

Results are output to `<OUTPUT_DIR>/proteinmpnn/`.

## AlphaFold2
ProteinMPNN output must be in `<OUTPUT_DIR>/proteinmpnn/`.

`sbatch --gpus 1 scripts/af2.sh <RUN_NAME> <OUTPUT_DIR>` (GPU required, specify more resources as necessary)

Results are output to `<OUTPUT_DIR>` and `<OUTPUT_DIR>/af2/`.
