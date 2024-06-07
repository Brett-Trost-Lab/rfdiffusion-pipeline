"""
Sort outputs by in silico success criteria and label designs as successful or unsuccessful.
Creates a new <>.out.txt file in the same location as <>.out.sc

Binder designs are classified as successful if:
    1. pAE interaction < 10
    2. RMSD between RFdiffusion designed binder and AF2 prediction < 1 Angstrom
    3. AF2 pLDDT of monomer > 80

argv[1]: path to out.sc
"""

import os
import sys
import pandas as pd

out_sc_file = sys.argv[1]

def main():
    df = pd.read_csv(out_sc_file, sep='\s+')

    # label successful designs
    cols = df.columns
    df[cols[2:10]] = df[cols[2:10]].apply(pd.to_numeric)
    
    df['successful'] = (df['pae_interaction'] < 10) & \
                       (df['binder_aligned_rmsd'] < 1) & \
                       (df['plddt_binder'] > 80)
    
    df.sort_values(['pae_interaction','successful','binder_aligned_rmsd','plddt_binder'], \
                   ascending=[True, False, True, True], \
                   inplace=True)

    file_name = os.path.splitext(os.path.abspath(out_sc_file))[0] + '.txt'
    df.to_csv(file_name, sep='\t', index=False)

    print("Output scores:", file_name)
    
if __name__ == "__main__":
    main()
