# RFdiffusion pipeline

## Extracting Ligands and Cleaning PDBs
Adapted from [PDB_Cleaner](https://github.com/LePingKYXK/PDB_cleaner).

usage: `python pdb_cleaner.py <folder-of-pdbs> <folder-for-output> <save_ligands(true/false)>`

## Prediction

A collection of methods for protein binding site prediction.

Currently installed:
* [P2Rank](https://github.com/rdk/p2rank) (2018): A rapid, template-free machine learning model based on Random Forest.
* [ScanNet](https://github.com/jertubiana/ScanNet) (2022) Uses a geometric deep learning architecture for prediciton.

## Validation

A collection of scripts that automates the validation process of [RFdiffusion](https://github.com/RosettaCommons/RFdiffusion) using [ProteinMPNN](https://github.com/dauparas/ProteinMPNN) and [AlphaFold2](https://github.com/google-deepmind/alphafold). Developed specifically for protein binder design.

For protein binder validation, the authors of RFdiffusion used **ProteinMPNN-FastRelax** and **AlphaFold2 Complex Prediction** with the "initial guess" method, available [here](https://github.com/nrbennet/dl_binder_design). These versions are <ins>waiting to be installed on the cluster</ins> and will replace the current ones once ready to be used.

This means that currently, the pipeline cannot evaluate how well the designed protein binds to its target. It can only determine how well the binder itself will fold to its intended monomer structure.

The example provided is designing a 25-50aa binder to Mpro ([6w63](https://www.rcsb.org/structure/6W63)) to two known hotspot residues in the active site cavity, [His41 and Cys145](https://www.nature.com/articles/s41467-020-16954-7#:~:text=The%20catalytic%20residues%20Cys145%20and%20His41%20in%203CL%20Mpro%20are%20buried%20in%20an%20active%20site%20cavity).

pAE scores of the binder are outputted to `/test_outputs/mpro/alphafold_output/sample_1/pAE_scores.txt`.


