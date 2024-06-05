"""
Extract the hotspots from a given p2rank output pocket.

argv[1]: pdb name
argv[2]: p2rank predictions csv
argv[3]: pocket number
"""

import os
import sys
import pandas as pd

pdb_name = sys.argv[1]
predictions_csv = sys.argv[2]
pocket_number = sys.argv[3]

def main():
    df = pd.read_csv(predictions_csv)
    hotspot_list = df.iloc[int(pocket_number) - 1,9].split()
    
    data = {'chain_identifier': [],
            'residue_sequence_number': []}
    for hotspot in hotspot_list:
        chain, residue = hotspot.split('_')
        data['chain_identifier'].append(chain)
        data['residue_sequence_number'].append(int(residue))

    df = pd.DataFrame(data)

    output_dir = os.path.dirname(predictions_csv)
    df.to_csv(f"{output_dir}/{pdb_name}_hotspots.txt", sep='\t')

    print(df)

if __name__ == "__main__":
    main()

