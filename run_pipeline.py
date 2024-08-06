'''
Parse arguments and submit a job.
'''

import os
import argparse
import pathlib

PIPELINE_DIR = pathlib.Path(__file__).parent.resolve()

def main(args):
    path_to_pdb = os.path.abspath(args.path_to_pdb)
    output_dir = os.path.abspath(args.output_dir)
    if args.scaffold_dir is not None:
        scaffold_dir = os.path.abspath(args.scaffold_dir)
        min_length = None
        max_length = None
    else:
        scaffold_dir = None
        min_length = args.min_length
        max_length = args.max_length
    
    print("\nrun_name:", args.run_name)
    print("path_to_pdb:", path_to_pdb)
    print("hotspots:", args.hotspots)
    print("min_length:", min_length)
    print("max_length:", max_length)
    print("num_structs:", args.num_structs)
    print("sequences_per_struct:", args.sequences_per_struct)
    print("min_helices:", args.min_helices)
    print("output_dir:", output_dir)
    print("scaffold_dir:", scaffold_dir, "\n")

    sbatch_command = f"sbatch --job-name {args.run_name} --output {output_dir}/{args.run_name}/slurm-{args.run_name}-%j.out {args.sbatch_flags} {PIPELINE_DIR}/scripts/pipeline.sh {PIPELINE_DIR} {args.run_name} {path_to_pdb} {args.hotspots} {min_length} {max_length} {args.num_structs} {args.sequences_per_struct} {args.min_helices} {output_dir} {scaffold_dir}"
    print(sbatch_command, "\n")
    os.system(sbatch_command)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    optional = parser._action_groups.pop()
    required = parser.add_argument_group('required arguments')

    optional.add_argument("--run_name", type=str, default="test_run", help="Name of run. Must be unique as this is used to name the output files and directory (default: test_run)")
    required.add_argument("--path_to_pdb", type=str, required=True, help="Path to target PDB. Note that RFdiffusion will only process standard residues designated ATOM.")
    required.add_argument("--hotspots", type=str, required=True, help='Hotspot residues. Comma-separated list of <chain_id><residue_index>, no spaces e.g. "A30,A33,A34"') 
    optional.add_argument("--min_length", type=int, default=50, help="Minimum binder length (default: 50)")
    optional.add_argument("--max_length", type=int, default=90, help="Maximum binder length (default: 90)")
    optional.add_argument("--num_structs", type=int, default=2, help="Number of RFdiffusion structures to generate (default: 2)")
    optional.add_argument("--sequences_per_struct", type=int, default=2, help="Number of sequences to generate per structure (default: 2)")
    optional.add_argument("--min_helices", type=int, default=1, help="Minimum number of helices for the binders. Note that this is coded as a filtering step after RFdiffusion (default: None)")
    optional.add_argument("--output_dir", type=str, default=".", help="Output directory (default: current directory)")
    optional.add_argument("--scaffold_dir", type=str, help="Scaffold directory if using fold conditioning. Use make_scaffold.sh to make binder scaffolds from PDBs. If this is provided we will ignore min_length and max_length (default: None)")
    optional.add_argument("--sbatch_flags", default="-G 1 --mem=8G --time=2:00:00", help='Flags to pass to sbatch command. GPU is required (default: "-gpus 1 --mem=8G --time=2:00:00")')

    parser._action_groups.append(optional)
    args = parser.parse_args()    
    main(args)   
