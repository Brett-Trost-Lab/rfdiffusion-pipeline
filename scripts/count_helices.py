"""
Given a secondary structure _ss.pt file, calculate the number of helical bundles.

Tensor encodings:

"Helix" = 0.0
"Sheet" = 1.0
"Loop" = 2.0
"Mask" = 3.0

Since RFdiffusion rarely designs beta sheets, we assume the binder is only made of helical bundles.

argv[1]: _ss.pt file
"""

import torch
import sys

ss_pt_file = sys.argv[1]

def calculate_num_bundles(ss_pt_file):
    tensor = torch.load(ss_pt_file)

    # convert ensor to CPU
    if tensor.is_cuda:
        tensor = tensor.cpu()

    # find changes in residue encoding (check where current residue differs from previous residue, and current element is a helix)
    diff = tensor != torch.cat((torch.tensor([0.0]), tensor[:-1]))
    num_bundles = (diff & (tensor == 0.0)).sum().item()

    return num_bundles

def main():
    num_bundles = calculate_num_bundles(ss_pt_file)
    print(num_bundles)

if __name__ == "__main__":
    main()
