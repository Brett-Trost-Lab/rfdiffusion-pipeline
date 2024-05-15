import sys
import pickle
import numpy as np
import pathlib

result_model_pkl = sys.argv[1]

with open(result_model_pkl, 'rb') as f:
    data = pickle.load(f)

result_dir = pathlib.Path(result_model_pkl).parent.resolve()
print('Result directory:', result_dir)

pAE_scores = data['predicted_aligned_error']
mean_pAE = np.mean(pAE_scores)

np.savetxt(f'{result_dir}/pAE_scores.txt', pAE_scores, fmt='%0.5f', header=f'mean pAE = {mean_pAE}')

print('pAE scores file created.')
