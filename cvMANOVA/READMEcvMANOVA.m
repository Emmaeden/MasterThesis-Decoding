README_cvMANOVA.txt
===================

cvMANOVA Analysis Pipeline
---------------------------
This folder contains MATLAB code to perform cross-validated MANOVA (cvMANOVA) analyses on three fMRI working memory datasets. The goal is to quantify representational fidelity of working memory contents across time (FIRs), using explained variance (D statistics).

----------------------------------------------
Workflow overview
----------------------------------------------

1. Create design matrix
   - Scripts use time series data and behavioral logs to:
     • Extract trial onsets, durations, and orientation information.
     • Generate basis functions for each orientation (e.g. sine and cosine transformations).
   - Constructs a design matrix of size:
     
       nVolumesPerRun x (nFIRs * nBasisFunctions)
     
   - This design matrix models the expected response to each orientation across the delay period.
   - Saves a design matrix file for each run and subject.

2. CVmANOCA Script => Prepare contrasts
   - For each design matrix, we build a contrast matrix `C` based on:
     • Number of basis functions (orientations encoded)
     • Number of FIR time points
   - This sets up the comparisons tested by cvMANOVA.

  Extract ROIs
   - Extracts the top 1000 most active voxels from each ROI, based on mean activity or variance.
   - Ensures analysis is focused on the most informative voxels for each subject and run.


   - Applies:
     • Moving average smoothing to boost signal-to-noise ratio.
     • Detrending to remove low-frequency drifts.

  Run cvMANOVA analysis
   - Uses the cvCrossMANOVA toolbox to apply cvMANOVA on each ROI across runs.
   - Cross-validation is performed across runs (holding out each run in turn).
   - Analysis is performed separately in each learning phase (e.g. early vs. late sessions).

  Extract D values
   - D statistics (pattern distinctness) are computed for each FIR (time point) across the delay period.
   - These values reflect how strongly patterns differ according to the remembered orientation.

3. Plotting and statistics
   - Scripts produce:
     • Time courses of D values across FIRs
     • Bar plots comparing phases (early vs. late)
     • Statistical tests (paired t-tests) on D across sessions

----------------------------------------------
Requirements
----------------------------------------------
- MATLAB (tested on R2021b+)
- cvCrossMANOVA toolbox
  https://github.com/markusschroeter/cvCrossMANOVA
- Statistics & Machine Learning Toolbox

----------------------------------------------
Notes
----------------------------------------------
- The pipeline is modular and can be adapted to other datasets by adjusting:
    • Number of basis functions (orientations)
    • Number of FIRs (time points)
    • Number of subjects and runs
- The same core scripts handle all datasets with dataset-specific parameters loaded at runtime.

----------------------------------------------
Citation
----------------------------------------------
If you use this code, please cite:

    Allefeld, C., Görgen, K., & Haynes, J.-D. (2016). Valid population inference for 
    information-based imaging: From the second-level t-test to prevalence inference. 
    NeuroImage, 141, 378–392.
    https://doi.org/10.1016/j.neuroimage.2016.07.040

and acknowledge this repository.


