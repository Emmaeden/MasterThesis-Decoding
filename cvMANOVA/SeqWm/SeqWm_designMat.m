close all;clear all; clc;

%% Path Directories
PathDir = '/disco/vivien/SeqWM/02_data/A_RAW';
outDir = '/disco/emma/matlabscripts/SeqWm/Data';
allSubjects = 1:24; 
allSubjects(9) = [];  % Remove subject 9 if needed

%% Parameters
TR = 0.8;
nVolsPerSession = 1600;
nSession = 4;
nRuns = 4; % 4 runs per session, total 16 runs per subject
nBf = 12; % Number of Basis Functions
basis_pwr = nBf - 1;
timewindow = -2:22; % FIR time window
nFir = length(timewindow); % Number of FIRs


%% Loop through Subjects
for sub = allSubjects
    substr = ['sub' num2str(sub, '%02d')];
    folder = fullfile(PathDir, substr, 'behav');
    folderRes = fullfile(outDir, substr);

    logFilePath = fullfile(folder, ['sub' num2str(sub, '%02d') '-allDat.mat']);
    logData = load(logFilePath);  % Load the struct with all runs

    %% Loop through the 16 runs inside logData
    for runIdx = 1:16  % Assuming 16 runs per subject
        disp(['Processing Subject: ' substr ', Run: ' num2str(runIdx)]);
        % Extract relevant run data
        runData = logData.Value(runIdx);  % Get the specific run's data
        cue = runData.design.cue;
        sample = runData.design.target;

        % Shift negative sample orientations into the positive space XX
        % uses, and round so we can use the BF as a lookup table
        sample(sample < 0) = sample(sample < 0) + 180;
        sample = round(sample);
        % Get onset times for trials
        trialsOnsets = arrayfun(@(t) runData.onsets.STIM(cue(t),t), 1:48);
        %% Define Basis Functions
        XX = 0:1:180; 
        mu = runData.parameters.orientation_bins; 
        make_basis_function = @(m,XX) abs(cosd(XX-m)).^basis_pwr;

        % bf for all centers
        basis_functions = zeros(nBf, length(XX));
        for bf = 1:nBf
            basis_functions(bf, :) = make_basis_function(mu(bf), XX);
        end


         Xr = zeros(nVolsPerSession, nBf * nFir);
        
        for trial = 1:length(sample)
            sampleIDX = sample +1;
            trial_weights = basis_functions(:, sampleIDX(trial));
            
            % Convert to TRs
            onset_TR = round(trialsOnsets(trial) / TR) + 1;
            onset_TR = onset_TR + timewindow;
            
            % Add to design matrix
            for bf = 1:nBf
                for nf = 1:nFir
                    regind = sub2ind([nFir, nBf], nf, bf);
                    Xr(onset_TR(nf), regind) = trial_weights(bf);
                end
            end
        end
        fprintf('    - Design Matrix Size: %dx%d\n',size(Xr,1),size(Xr,2));
        % Save the design matrix for this run
        save(fullfile(folderRes, ['designMat_BFRun_new' num2str(runIdx, '%02d') '.mat']), 'Xr');
    end
end