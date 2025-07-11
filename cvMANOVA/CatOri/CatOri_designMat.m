close all; clear all, clc;

%% Path Dir

PathDir= '/disco/joana/CategOri_MRI/CategOri_MRIdata/02_data/logs';
outDir ='/disco/emma/CvmRes_CatOri';
allSubjects = 1:45; allSubjects([14 15 20 36])=[];

%% Parameters 
TR = 0.8; 
nVolsPerSession = 711; 
nRuns = 8;
nBf = 8; % N Bf
basis_pwr = nBf - 1; % Power for Bf

timewindow = -2:23;
nFir = 26;

%% loop throu Sub
for sub= allSubjects
    substr = ['sub' num2str(sub, '%02d')];
    folder = fullfile(PathDir, substr);
    folderRes =fullfile(outDir,substr);

   
    logFiles = dir(fullfile(folder, '*orientation*.mat'));

    % Extract numeric values for sorting
    datesNum= [logFiles.datenum];
    
    [~,sortedIdx]=sort(datesNum,'ascend');
   
    
    % Reorder log files based on sorted indices
    logFiles = logFiles(sortedIdx);


% Loop through sorted log files
    for logIdx = 1:length(logFiles)
        logFilePath = fullfile(folder, logFiles(logIdx).name);
        logData = load(logFilePath);

%         if ~exist(folderRes,'dir')
%             mkdir(folderRes);
%         end
   
                
        %% Define BF
        XX = 0:0.5:180; % Full range of orientations 
        mu =logData.log.parameters.sample_orientations; % Centers of bf
        mu = mu(1):22.5:172.5;
        make_basis_function = @(mu, XX) abs(cosd(XX - mu)).^basis_pwr;
        
        % bf for all centers
        basis_functions = zeros(nBf, length(XX));
        for bf = 1:nBf
            basis_functions(bf, :) = make_basis_function(mu(bf), XX);
        end
        
        trial_orientation = logData.log.design.sample;
        trials_onsets = logData.log.onsets.STIM;


        %  design matrix
        Xr = zeros(nVolsPerSession, nBf*nFir);
        

        for trial = 1:length(trial_orientation)
            % determine the correct column index based on sample orientation number
            orientation = trial_orientation(trial);
            %  trial's onset and map to TR
            onset_TR = round(trials_onsets(trial)  / TR) + 1; % Convert to TR
            onset_TR = onset_TR + timewindow;

            %  bf weights for this trial's orientation
            trial_weights = basis_functions(:,orientation==XX);
            %trial_weights = trial_weights ./ sum(trial_weights); % Normalize

            % Add the trial's  to the design matrix
            for bf = 1:nBf
                for nf = 1:nFir
                    regind = sub2ind([nFir nBf],nf,bf);
                    Xr(onset_TR(nf), regind) = trial_weights(bf);
                end
            end
        end

        % Save the design matrix for this run
        nRuns = logIdx;

       save(fullfile(folderRes,['designMat_BFRun_' num2str(nRuns, '%02d') '.mat']), 'Xr');
                
               
    end
       
        
         
   
    
end
