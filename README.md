# RFdiffusion pipeline
A collection of scripts that automates the validation process of [RFdiffusion](https://github.com/RosettaCommons/RFdiffusion) using [ProteinMPNN](https://github.com/dauparas/ProteinMPNN) and [AlphaFold2](https://github.com/google-deepmind/alphafold). Developed specifically for protein binder design.

For the sequence design and validation of protein binders, the authors of RFdiffusion used ProteinMPNN-FastRelax and AlphaFold2 Complex Prediction with the "initial guess" method, available [here](https://github.com/nrbennet/dl_binder_design). These versions are being installed on the cluster and will replace the current ones once ready to use.

Currently, the pipeline is designing a 25-50aa binder to Mpro ([6w63](https://www.rcsb.org/structure/6W63)) to two known hotspot residues in the active site cavity, [His41 and Cys145](https://www.nature.com/articles/s41467-020-16954-7#:~:text=The%20catalytic%20residues%20Cys145%20and%20His41%20in%203CL%20Mpro%20are%20buried%20in%20an%20active%20site%20cavity).

pAE scores of the binder are outputted to `/test_outputs/mpro/alphafold_output/sample_1/pAE_scores.txt`.
