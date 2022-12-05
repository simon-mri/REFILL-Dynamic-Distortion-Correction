# REFILL-Dynamic-Distortion-Correction

MATLAB code for "Improved dynamic distortion correction for fMRI using single-echo EPI and a readout-reversed first image (REFILL)" [1,2]

Example data is available at https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/ZWNZXM 

Instructions

.) Set paths and options in refill_set_defaults.m and refill_select_data.m 
	(For the example data, only data.root_dir in refill_set_defaults.m needs changing)
.) Install the phase unwrapping program ROMEO* and set the path to that (RD.path_to_binary) in romeo_unwrap.m

run refill_ddc_main.m

.) To view interim results, including an assessment and comparison of the fieldmaps, set data.verbose = 1 in refill_set_defaults.m

* https://github.com/korbinian90/CompileMRI.jl/releases v3.6.3 or later
 (see also the info on https://github.com/korbinian90/ROMEO)

assessment: in refill/results/sub{i}/fMRI_hands_refill/distortion_correction

compare: 
	epi_m_mc_mosaic.nii ('Original' in sfig{i+1}.avi)
	epi_m_sdc_bet_mc_mosaic.nii ('Static DC' in sfig{i+1}.avi)
	epi_m_ddc_bet_mc_mosaic.nii ('Dynamic DC' in sfig{i+1}.avi)

the avis in sfig2, sfig3 and sfig4 were generated  

[1] Robinson S, Bachrata B, Eckstein K, Trattnig S, Enzinger, Christian, Barth, Markus. Improved dynamic distortion correction for fMRI using single-echo EPI, a fast sensitivity scan and readout-reversed first image (REFILL). Proc. 2021 ISMRM SMRT Annu. Meet. Exhib. Virtual 2021:671.
[2] Robinson S, Bachrata B, Eckstein K, et al. Evaluation of the REFILL dynamic distortion correction method for fMRI. Proc. 2022 ISMRM SMRT Annu. Meet. Exhib. Virtual 2022:671.

Includes
1) Tools for NIfTI and ANALYZE image by Jimmy Shen https://de.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image?s_tid=ta_fx_results
2) Cosine transform functions dctn and idctn by Damian Garcia 
