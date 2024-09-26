# RFdiffusion Pipeline

In 2023, the Baker Lab published [RFdiffusion](https://github.com/RosettaCommons/RFdiffusion), a deep-learning framework for *de novo* protein design. Using [ProteinMPNN and AlphaFold2](https://github.com/nrbennet/dl_binder_design) for validation, the authors demonstrated RFdiffusion's ability to tackle a diverse range of design challenges, including the successful generation of high-affinity binders to desired target proteins.

# Table of Contents

- [Automated Pipeline](#automated-pipeline)
  - [Input](#input)
  - [Usage](#usage)
  - [Output](#output)
- [Individual Steps of the Pipeline](#individual-steps-of-the-pipeline)
  - [RFdiffusion](#rfdiffusion)
  - [ProteinMPNN](#proteinmpnn)
  - [AlphaFold2](#alphafold2)
- [Additional Functionalities](#additional-functionalities)
  - [Selecting Hotspot Residues](#selecting-hotspot-residues)
  - [Isolate Successful Designs](#isolate-successful-designs)
  - [Binder Validation](#binder-validation)
  - [Filter by Number of Helices](#filter-by-number-of-helices)
  - [Filter by Binder Length](#filter-by-binder-length)
  - [Aggregate Results](#aggregate-results)
  - [Extract Binder Sequences](#extract-binder-sequences)
- [Troubleshooting](#troubleshooting)

----
  
# Automated Pipeline

A collection of scripts that automates the validation process of **RFdiffusion &#8594; ProteinMPNN &#8594; AlphaFold2 (AF2)**. Developed specifically for protein binder design on the SickKids High-Performance Computing (HPC) cluster.

![image](https://github.com/sophia-xie/protein-binder-design/assets/154448471/28c5fb17-8c1a-4819-af37-63d485732065)
<sub>Image adapted from [Watson et al.](https://www.nature.com/articles/s41586-023-06415-8)</sub>

In this pipeline, *RFdiffusion* designs binders to hotspot residues on the target protein. It then uses *ProteinMPNN* to generate sequences for the designed structures. Finally, *AlphaFold2* reconstructs the binders onto the target and evaluates their likelihood of success.

*In silico* success is defined by three confidence metrics produced by *AlphaFold2*:
1. **pae_interaction < 10**: how likely binder will bind to target (key indicator of success)
2. **plddt_binder > 80**: how likely binder will fold into its intended structure
3. **binder_aligned_rmsd < 1**: similarity between RFdiffusion and AF2 binder structures

### Input
The input arguments to the pipeline are as follows:
```
usage: run_pipeline.py [-h] [--run_name RUN_NAME] --path_to_pdb PATH_TO_PDB
                       --hotspots HOTSPOTS [--min_length MIN_LENGTH]
                       [--max_length MAX_LENGTH] [--num_structs NUM_STRUCTS]
                       [--sequences_per_struct SEQUENCES_PER_STRUCT]
                       [--min_helices MIN_HELICES] [--output_dir OUTPUT_DIR]
                       [--scaffold_dir SCAFFOLD_DIR]
                       [--sbatch_flags SBATCH_FLAGS]

required arguments:
  --path_to_pdb PATH_TO_PDB
                        Path to target PDB. Note that RFdiffusion will only
                        process standard residues designated ATOM.
  --hotspots HOTSPOTS   Hotspot residues. Comma-separated list of
                        <chain_id><residue_index>, no spaces e.g.
                        "A30,A33,A34"

optional arguments:
  -h, --help            show this help message and exit
  --run_name RUN_NAME   Name of run. Must be unique as this is used to name
                        the output files and directory (default: test_run)
  --min_length MIN_LENGTH
                        Minimum binder length (default: 50)
  --max_length MAX_LENGTH
                        Maximum binder length (default: 90)
  --num_structs NUM_STRUCTS
                        Number of RFdiffusion structures to generate (default:
                        2)
  --sequences_per_struct SEQUENCES_PER_STRUCT
                        Number of sequences to generate per structure
                        (default: 2)
  --min_helices MIN_HELICES
                        Minimum number of helices for the binders. Note that
                        this is coded as a filtering step after RFdiffusion
                        (default: None)
  --output_dir OUTPUT_DIR
                        Output directory (default: current directory)
  --scaffold_dir SCAFFOLD_DIR
                        Scaffold directory if using fold conditioning. Use
                        make_scaffold.sh to make binder scaffolds from PDBs.
                        If this is provided we will ignore min_length and
                        max_length (default: None)
  --sbatch_flags SBATCH_FLAGS
                        Flags to pass to sbatch command. GPU is required
                        (default: "-gpus 1 --mem=8G --time=2:00:00")
```

### Usage
#### Single run
To run one job:
```
srun --pty bash  # enter compute node
python run_pipeline.py <ARGUMENTS>
```

#### Bulk run
To run multiple jobs at once, specify all arguments in a single text file, one row per run. See `inputs/input.txt` for an example. 
```
srun --pty bash  # enter compute node
bash launch.sh inputs/input.txt
```

### Output
Logging will be written in `<OUTPUT_DIR>/<RUN_NAME>/slurm-<RUN_NAME>-<job_id>.out`.

AF2 scores are output to `<OUTPUT_DIR>/<RUN_NAME>/<RUN_NAME>.out.txt`, sorted from best to worst design. The `successful` column indicates whether the design passed all three criteria (`pae_interaction` < 10, `plddt_binder` > 80, `binder_aligned_rmsd` < 1).

AF2 predicted structure .pdbs in `<OUTPUT_DIR>/<RUN_NAME>/af2/` can be visualized and compared with their respective RFdiffusion designs in `<OUTPUT_DIR>/<RUN_NAME>/rfdiffusion/`.

----

# Individual Steps of the Pipeline

The following explains how to run the individual components of the pipeline. The provided commands submit slurm jobs but the scripts can also be run from an interactive node using bash.

## RFdiffusion
#### Without fold conditioning:
```
sbatch --gpus 1 --mem 8G --tmp 8G --time=2:00:00 scripts/rfdiffusion.sh <RUN_NAME> <PATH_TO_PDB> <HOTSPOTS> <MIN_LENGTH> <MAX_LENGTH> <NUM_STRUCTS> <OUTPUT_DIR>
```

#### With fold conditioning:
This feature allows you to prespecify desired topologies for your binders. This is done by passing information from other PDBs with those desired topologies, which will act as scaffolds.
```
# make binder scaffolds if not already made
sbatch helper_scripts/make_scaffolds.sh <INPUT_PDBS> <SCAFFOLD_DIR>

# run script
sbatch --gpus 1 --mem 8G --tmp 8G --time=2:00:00 scripts/fold_conditioning.sh <RUN_NAME> <PATH_TO_PDB> <HOTSPOTS> <NUM_STRUCTS> <OUTPUT_DIR> <SCAFFOLD_DIR>
```

Results are output to `<OUTPUT_DIR>/rfdiffusion/`.

For more options and other design tasks, see [https://github.com/RosettaCommons/RFdiffusion](https://github.com/RosettaCommons/RFdiffusion).

## ProteinMPNN
Pass the directory of RFdiffusion output PDBs as `<input_dir>`.
```
sbatch scripts/proteinmpnn.sh <RUN_NAME> <input_dir> <SEQ_PER_STRUCT> <OUTPUT_DIR>
```
Results are output to `<OUTPUT_DIR>/proteinmpnn/`.

## AlphaFold2
Pass the directory of ProteinMPNN output PDBs as `<input_dir>`.
```
sbatch --gpus 1 --mem 8G --tmp 8G --time 2:00:00 scripts/af2.sh <RUN_NAME> <input_dir> <OUTPUT_DIR>
```
Results are output to `<OUTPUT_DIR>/af2/`.

The sorted score file will be created as `<OUTPUT_DIR>/<RUN_NAME>.out.txt`.

----

# Additional Functionalities

Here we provide a set of scripts to run additional, optional functionalities for the pipeline.

To run python scripts:
```
srun --pty bash  # enter a compute node
module load python/3.11.3  # this python version has the required packages for all scripts used below
```

## Selecting Hotspot Residues

### Proteins with a Known Binder 
For proteins with a known binding protein, we can find all residues on the target within a certain distance of the ligand. Baker defined a "hotspot residue" as any residue within 10A Cbeta distance of the known binder (only 0-20% of these hotspots were actually provided to the model).

```
python helper_scripts/get_hotspots_PPI.py <target-pdb> <binder-pdb> <max-cbeta-distance>
```

This prints all the hotspot residues on the target protein. We recommend only using the ones labeled "hydrophobic".

### Proteins without a Known Binder 

When no known binders are present (or novel binding sites are desired), we can use protein binding site prediction methods.

Currently installed:
#### [P2Rank](https://github.com/rdk/p2rank) (2018)
A rapid, template-free machine learning model based on Random Forest.

```
srun --pty bash  # enter compute node
bash helper_scripts/p2rank.sh <input_pdb> <output_dir>
```

Predicted pockets will be output in order of confidence to `output_dir/<pdb_name>.pdb_predictions.csv`. Pockets and residues can be viewed by downloading and opening `output_dir/visualizations/`.

## Isolate Successful Designs
Given the `.out.txt` file, you may wish to move all successful PDBs into their own directory. This can be done for either ProteinMPNN-generated PDBs (to validate the successful sequences on another target, for example) or to isolate the successful AF2 reconstructed designs.

```
bash helper_scripts/isolate_successful.sh <.out.txt> <folder_with_all_pdbs> <new_folder_for_successful_pdbs_only>
```

## Binder Validation
You may be interested in designing binders to one target protein, but validating them on another. This could be to analyze the specificity of the binders to similar proteins. Or, the protein was truncated for RFdiffusion, but the entire structure is to be used in AF2 validation. Alternatively, you may be interested in validating a solved binder for your target protein.

The script below takes designed binders from ProteinMPNN-generated PDBs (or a particular chain from any PDBs) and adds them to a separate target PDB. This output can then be passed to AF2, allowing the binders to be validated on proteins they weren't designed for. Note that this script handles AF2's requirement for unique residue indices across chains.

```
python helper_scripts/integrate_binders.py <old_target_proteinmpnn_outdir> <chain_id> <path_to_new_target_pdb> <new_output_dir>
```

Note that for ProteinMPNN-generated PDBs, the `<chain_id>` will be `A`.

## Filter by Number of Helices
The *RFdiffusion* authors did not order any binder designs with two helical bundles or fewer. These do not form a well-packed protein core and are therefore unlikely to express in solution. We developed functionality for filtering binders by a minimum number of helices. This can be applied directly after RFdiffusion (so that the binder is not passed through ProteinMPNN and AlphaFold2) or after AlphaFold2.

```
srun --pty bash  # enter compute node
sbatch --time=2:00:00 helper_scripts/filter_helices.sh <pdb_dir> <min_helices>
```
Takes about 45 minutes for 1000 binders.

Binders that don't meet the threshold will be moved to a subdirectory within `<pdb_dir>`.

## Filter by Binder Length
To filter out binders not within a certain range:

```
srun --pty bash  # enter compute node
python helper_scripts/filter_binder_length.py <pdb_dir> <min_length> <max_length>
```
Binders shorter than `<min_length>` or longer than `<max_length>` will be moved to a subdirectory within `<pdb_dir>`.

## Aggregate Results
Aggregates the results from multiple runs. Usage:

```
usage: aggregate_results.py [-h] -i INPUT_DIR [--max_designs MAX_DESIGNS] [--copy_designs]
                            [--non_distinct] [--include_failed] [--output_dir OUTPUT_DIR]

options:
  -h, --help            show this help message and exit
  -i INPUT_DIR, --input_dir INPUT_DIR
                        Output directory of RFdiffusion pipeline. Use this flag multiple times,
                        once for each directory (required)
  --max_designs MAX_DESIGNS
                        Maximum number of designs to aggregate (default: None)
  --copy_designs        Copy designs to a new directory
  --non_distinct        Do not filter for distinct binders
  --include_failed      Include failed designs
  --output_dir OUTPUT_DIR
                        Directory to move successful designs to and create output file (default:
                        current directory)
```

This creates a new, sorted `<.out.txt>` file. Optionally copies all successful AF2 designs into `<output_dir>/aggregate_designs/`. Example:
```
python helper_scripts/aggregate_results.py -i outdir/test_run1 -i outdir/test_run2 --max_designs 200 --copy_designs
```

To quickly get all folders in a directory, use this bash command to create a string:
```
dirs=""
for dir in *; do
    dirs+=" -i ${dir}"
done
echo $dirs
```

## Extract Binder Sequences
To convert a directory of PDBs to a FASTA file:
```
srun --pty bash  # enter compute node
python helper_scripts/pdb_to_fasta.py <pdb_dir> <out_txt>
```
Binder sequences will be output to `<output.fasta>`.

----

# Troubleshooting

* **Activating conda... ModuleNotFoundError: No module named 'MODULE':** The conda environment required for the script may be conflicting with your local conda environment. To unreference your local conda environment, remove the `>>> conda initialize <<<` portion of your `.bashrc` file.
* **Struct with tag 'SAMETAG' failed in 0 seconds with error: <class 'EXCEPTION'>:** See [dl_binder_design: Troubleshooting](https://github.com/nrbennet/dl_binder_design?tab=readme-ov-file#troubleshooting-)
