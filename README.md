# Protein Binder Design

## Validation Pipeline

A collection of scripts that automates the validation process of [RFdiffusion](https://github.com/RosettaCommons/RFdiffusion) using [ProteinMPNN and AlphaFold2](https://github.com/nrbennet/dl_binder_design). Developed specifically for protein binder design.
 
The pipeline designs binders to hotspot residues on the target protein. It then evaluates how well the designed structures will bind to their target.
 
### Input
Specify all input configurations in a single text file, one row per target protein. This file MUST follow the format provided in 'inputs/input.txt' with the headers included. The parameters are as follows:
| Parameter | Description | Notes |
| --- | --- | --- |
| NAME | Name of the run | Must be unique. Can have two runs with the same target PDB but different names. |
| PATH_TO_PDB | Absolute path to target PDB | Avoid ~, $HOME, .., etc. |
| CLEAN | Whether to clean the target PDB (yes/no) | Avoid cleaning already cleaned PDBs |
| HOTSPOTS | Hotspots for RFdiffusion | e.g. 'A232,A245,A271' (no spaces, separate with commas) OR 'predict' will sample hotspots from a predicted binding site |
| MIN_LENGTH | Minimum length for binder (aa) | |
| MAX_LENGTH | Maximum length for binder (aa) | |
| NUM_STRUCTS | Number of RFdiffusion structures to generate | |
| SEQUENCES_PER_STRUCT | Number of ProteinMPNN sequences to generate for each structure | |
| MEM | Amount of memory for job to use | e.g. 128G |
| TEMP | Amount of temporary space for job to use | e.g. 128G |
| TIME | Maximum time allotted for job | e.g. 48:00:00 |
| RFDIFFUSION_MODEL | RFdiffusion model to use | e.g. Complex_base_ckpt.pt |
| OUTPUT_DIR | Output directory | |


 
### Usage
```
bash validation/launch.sh inputs/input.txt
```
### Output
Outputs are provided for the individual steps of the pipeline. The RFdiffusion designed structure in `<output_dir>/<pdb_name>/rfdiffusion` can be compared with the AF2 predicted structure in `<output_dir>/<pdb_name>/af2`.
 
Successful designs and output scores are sorted in `<output_dir>/<pdb_name>/<pdb_name>.out.txt`.

## Individual Components
### Extracting Ligands and Cleaning PDBs
Adapted from [PDB_Cleaner](https://github.com/LePingKYXK/PDB_cleaner). Clean PDBs and Ligands are outputed to the specified output path. The program will generate a cleaned PDB for all files in the specified folder. Example cleaned pdbs can be found in cleaning/clean_pdbs

usage: `python cleaning/pdb_cleaner.py <folder-of-pdbs> <folder-for-output> <save_ligands(true/false)>`

### Selecting Hotspot Residues (for proteins with ligands)
For proteins with a known ligand binder, to generate accurate and effective hotspot residues to RFDiffusion, we developed 2 methods: randomly select 6 hydrophobic residues within an 11 angstrom radius of the ligand centroid and select the top 6 residues closest to ANY atom in the ligand. This ensures they are "important" binding residues and allows us to generate residues which RFDiffusion will accept.

usage: `python residue_selection/select_residues_using_centroid.py <pdb-of-interest> <pdb-of-ligand> <output-path>`

usage: `python residue_selection/select_residues_using_AAdistance.py <pdb-of-interest> <pdb-of-ligand> <output-path>`

### Prediction

A collection of scripts that run protein binding site prediction methods. To be used when no known ligands are present, or novel binding sites are desired.

Currently installed:
#### [P2Rank](https://github.com/rdk/p2rank) (2018)
* A rapid, template-free machine learning model based on Random Forest.
* Usage: `sbatch prediction/p2rank/p2rank.sh` (specify the protein inside of the script)
* Predicted pockets will be output in order of confidence to `<>.pdb_predictions.csv`.
* One pocket and its hotspots can then be extracted and prepared for RFdiffusion: `python prediction/p2rank/extract_hotspots.py <pdb_name> <path_to_predictions.csv> <pocket_number>`
#### [ScanNet](https://github.com/jertubiana/ScanNet) (2022)
* A geometric deep learning architecture for prediction.
* Usage: `sbatch prediction/scannet/scannet.sh` (specify the protein inside of the script)
