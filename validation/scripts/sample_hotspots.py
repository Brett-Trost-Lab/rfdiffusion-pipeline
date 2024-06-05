"""
Sample a given number of hotspot residues for RFdiffusion from the provided list.

argv[1]: hotspot txt file path
"""

import sys
import pandas as pd

hotspot_path = sys.argv[1]
num_hotspots=6

def main():
    df = pd.read_csv(hotspot_path, sep="\t")
    num_hotspots = min(num_hotspots, len(df)) # sample 6 hotspots, or all if less than 6 provided
    
    df = df.sample(n=num_hotspots)
    df.sort_values(['chain_identifier', 'residue_sequence_number'], inplace=True)
    
    df['hotspot'] = df['chain_identifier'].astype(str) + df['residue_sequence_number'].astype(str)
    hotspots = ','.join(df['hotspot'])
    
    print(hotspots)

if __name__ == "__main__":
    main()

