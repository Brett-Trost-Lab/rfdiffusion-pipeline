'''
Aggregates results from different runs.
'''

import os
import sys
import argparse
import pathlib
import shutil
import pandas as pd

def main(args):

    input_dirs = args.input_dir
    max_designs = sys.maxsize if args.max_designs is None else args.max_designs
    copy_designs = args.copy_designs
    non_distinct = args.non_distinct
    include_failed = args.include_failed
    output_dir = os.path.abspath(args.output_dir)

    if include_failed:
        num_designs = None

    print('\nInput directories:', input_dirs)
    print('Include failed:', include_failed)
    print('Max designs:', max_designs)
    print('Non distinct:', non_distinct)
    print('Output directory:', output_dir)

    # create aggregated out_txt
    list_of_dfs = []

    for input_dir in input_dirs:
        input_dir = os.path.abspath(input_dir)
        print('\nNow reading:', input_dir)

        # get out.txt file
        out_txt_files = [f for f in os.listdir(input_dir) if f.endswith('.out.txt')]

        if len(out_txt_files) == 0:
            raise Exception('ERROR: No .out.txt file found.')
        elif len(out_txt_files) > 1:
            raise Exception('ERROR: Multiple .out.txt files found. Please remove one.')
        else:
            out_txt = os.path.join(input_dir, out_txt_files[0])
            print('out_txt:', out_txt)
            
            df = pd.read_csv(out_txt, sep='\t')
            
            if df.empty:
                continue

            if not include_failed:
                df = df[df['successful'] == True]

            df = df[['description', 'pae_interaction', 'plddt_binder', 'binder_aligned_rmsd', 'successful']]
            df['directory'] = input_dir + '/af2/'

            # check if files exist
            file_exists = (df['directory'] + '/' + df['description'] + '.pdb').astype(str).map(os.path.exists)
            df = df[file_exists]

            # filter for distinct designs
            if not non_distinct:
                df['struct'] = df['description'].str.split('_').apply(lambda x: int(x[-4]))
                df.drop_duplicates('struct', keep='first', inplace=True)
                df.drop('struct', axis=1, inplace=True)

            list_of_dfs.append(df)

    df = pd.concat(list_of_dfs)
    df.sort_values(['successful', 'pae_interaction', 'plddt_binder', 'binder_aligned_rmsd'], \
                    ascending=[False, True, False, True], \
                    inplace=True)
    
    pathlib.Path(output_dir).mkdir(parents=True, exist_ok=True)

    if copy_designs:
        pathlib.Path(output_dir + '/aggregate_designs/').mkdir(parents=True, exist_ok=True)
        def copy_file(row):
            source = row['directory'] + '/' + row['description'] + '.pdb'
            destination = output_dir + '/aggregate_designs/' + row['description'] + '.pdb'

            print('\nCopying', source, 'to', output_dir + '/aggregate_designs/')
            shutil.copyfile(source, destination)
            
        df.apply(copy_file, axis=1)

    # create output file
    output_file = output_dir + '/' + 'scores.out.txt'
    df.head(max_designs).to_csv(output_file, sep='\t', header=True, index=False)
    
    print('\nCreated output scores file:', output_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("-i", "--input_dir", type=str, action='append', required=True, help="Output directory of RFdiffusion pipeline. Use this flag multiple times, once for each directory (required)")
    parser.add_argument("--max_designs", type=int, default=None, help="Maximum number of designs to aggregate (default: None)")
    parser.add_argument("--copy_designs", action='store_true', help="Copy designs to a new directory")
    parser.add_argument("--non_distinct", action='store_true', help="Do not filter for distinct binders")
    parser.add_argument("--include_failed", action='store_true', help="Include failed designs")
    parser.add_argument("--output_dir", type=str, default='.', help="Directory to move successful designs to and create output file (default: current directory)")

    args = parser.parse_args()
    main(args)

