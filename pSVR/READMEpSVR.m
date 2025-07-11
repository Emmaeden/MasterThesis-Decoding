README_pSVR.txt
===============

pSVR Analysis Pipeline
-----------------------
This folder contains MATLAB code to perform periodic support vector regression (pSVR) decoding analyses on three working memory fMRI datasets. The pipeline is designed to extract and decode the orientation content maintained in memory, using TDT (The Decoding Toolbox).

----------------------------------------------
Workflow overview
----------------------------------------------
The pSVR pipeline proceeds through the following main steps:

1. Organize directories
   - Scripts start by navigating the file structure with `get_dir` functions to set up paths for each subject, ROI, and run.

2. Extract ROI data
   - From the preprocessed fMRI data, the pipeline extracts the top 1000 most active voxels in each ROI.
   - This is done using activity-based masks or variance measures.

3. Get logs
   - Behavioral log files are loaded to retrieve trial-specific information such as:
     - Stimulus orientations
     - Trial timings
     - Response data
   - Used to align fMRI time series with task events.

4. Get data
   - Using the logs, scripts extract fMRI time series for each trial and align them to task events to build a 4D data array:
       [nSubjects x nFIRs x nTrials x nRuns]
   - The pipeline applies:
     - Moving average smoothing (to increase SNR)
     - Detrending (to remove low-frequency drifts)


   - The stimulus orientations are transformed into sine and cosine components.
   - These serve as continuous labels for regression.

5. pSVR analysis
   - Uses The Decoding Toolbox (TDT) to perform SVR separately for sine and cosine labels.
   - Cross-validation is performed across runs to train and test the model.

  Compute angular error
   - Predictions from sine and cosine SVR models are combined to reconstruct predicted angles.
   - The angular decoding error is computed as the circular distance between predicted and true orientations.

6. Plotting and statistics
   - Scripts generate plots of angular decoding error across the delay period for each ROI.
   - Statistical analyses (e.g. t-tests across sessions) are performed and summary bar plots / time courses are created.


----------------------------------------------
Requirements
----------------------------------------------
- MATLAB (tested on R2021b+)
- The Decoding Toolbox (TDT)
  https://www.tnu.ethz.ch/en/software/tdt.html
- Statistics & Machine Learning Toolbox

----------------------------------------------
Notes
----------------------------------------------
- This pipeline can be easily adapted to new datasets by modifying parameters such as:
    - Number of subjects
    - Number of runs / FIRs
    - Number of trials
- All steps from ROI extraction to decoding are performed within consistent scripts, organized by dataset.

----------------------------------------------
Citation
----------------------------------------------
If you use this code, please cite:

    Hebart, M. N., Görgen, K., & Haynes, J.-D. (2015). The Decoding Toolbox (TDT): 
    a versatile software package for multivariate analyses of functional imaging data. 
    Frontiers in Neuroinformatics, 8, 88. 
    https://doi.org/10.3389/fninf.2014.00088

and acknowledge this repository.



