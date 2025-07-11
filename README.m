README.txt
===========

fMRI Decoding Analyses with pSVR and CV-MANOVA
----------------------------------------------
This repository contains MATLAB code to perform multivariate decoding analyses on three fMRI working memory datasets using two complementary approaches:

- Periodic Support Vector Regression (pSVR)
- Cross-validated MANOVA (CV-MANOVA)

It also includes behavioral analyses aligned with the imaging experiments.

----------------------------------------------
Datasets
----------------------------------------------
The pipeline is applied to three independent fMRI datasets:

Dataset1 - SeqWM  
Dataset2 - CatOri 
Dataset3 - MC01   

Each dataset has its own subfolder within each analysis method. While the general pipeline is consistent, scripts are tailored to dataset-specific parameters such as:

- Number of subjects
- Number of TRs / FIRs
- Number of trials per run
- Number of runs and sessions

----------------------------------------------
Methods
----------------------------------------------
1. pSVR (Periodic Support Vector Regression)
   - Implemented using The Decoding Toolbox (TDT).
   - Decodes continuous orientation content maintained in working memory by transforming orientations into sine and cosine components.
   - A support vector regression model predicts these from multivoxel patterns.
   - Angular decoding errors are computed across the delay period to assess representational fidelity.

   Reference:
     Hebart, M. N., Görgen, K., & Haynes, J.-D. (2015). The Decoding Toolbox (TDT): 
     a versatile software package for multivariate analyses of functional imaging data. 
     Frontiers in Neuroinformatics, 8, 88. 
     https://doi.org/10.3389/fninf.2014.00088

2. CV-MANOVA (Cross-validated MANOVA)
   - Implemented using the cvCrossMANOVA toolbox.
   - Estimates explained variance and pattern distinctness (D) to quantify separability of multivoxel patterns associated with different orientation contents.
   - Enables  population-level inference on representational changes across time (e.g. early vs. late learning).

   Reference:
     Allefeld, C., Görgen, K., & Haynes, J.-D. (2016). Valid population inference for 
     information-based imaging: From the second-level t-test to prevalence inference. 
     NeuroImage, 141, 378–392.
     https://doi.org/10.1016/j.neuroimage.2016.07.040

3. Behavioral Analysis
   - Scripts compute behavioral accuracy, reaction times, and recall errors.
   - Produces plots to visualize performance changes across sessions.

----------------------------------------------
Folder structure
----------------------------------------------
.
├── psvr/
│   ├── SeqWM/
│   ├── CatOri/
│   └── MC01/
├── cvmanova/
│   ├── SeqWM/
│   ├── CatOri/
│   └── MC01/
└── bhv/
    ├── SeqWM/
    ├── CatOri/
    └── MC01/

Each folder contains:
- MATLAB scripts for preprocessing, decoding, and statistics
- Parameter files tailored to each dataset (e.g. number of subjects, runs, FIRs)
- Generated figures (time courses, bar plots) and .mat result files

----------------------------------------------
How to run
----------------------------------------------
Make sure MATLAB has access to required toolboxes.

Adjust parameters inside scripts for new datasets.

----------------------------------------------
Requirements
----------------------------------------------
- MATLAB (tested on R2021b+)
- The Decoding Toolbox (TDT)
  https://www.tnu.ethz.ch/en/software/tdt.html
- cvCrossMANOVA toolbox
  https://github.com/markusschroeter/cvCrossMANOVA
- Statistics & Machine Learning Toolbox

----------------------------------------------
Analyses include
----------------------------------------------
- Decoding of working memory content across delay period
- Comparison of representational fidelity (early vs. late sessions / runs)
- Behavioral analysis of recall precision and reaction times
- Plots summarizing angular errors, pattern distinctness, and performance

----------------------------------------------
Notes
----------------------------------------------
- The pipeline is the same across datasets but scripts are adjusted to dataset-specific parameters.
- Results (decoding accuracies, angular errors, D statistics) are saved as .mat files and automatically plotted.
- This repository does NOT include raw fMRI or behavioral data.

----------------------------------------------
License
----------------------------------------------
This code is open for academic use under the MIT License. See LICENSE file.

----------------------------------------------
Citation
----------------------------------------------
If you use this code, please cite the original toolboxes (TDT and cvCrossMANOVA) and consider acknowledging this repository in your work.

----------------------------------------------
Contact
----------------------------------------------
For questions about the analysis pipeline, please open an issue on GitHub or contact:

Emma Eden 
emmaeden.sci@gmail.com

----------------------------------------------
