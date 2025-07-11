
close all, clear all; clc;
%%  sub Dir 
MC01Dir = '/disco/emma/matlabscripts/MC01/data';
allSubjects = 1:38; allSubjects([14 20])=[];
%% Parameters
TR = 1.2250; 
nVolsPerSession = 936; 
nSession = 8;
nBf = 8; % N Bf
basis_pwr = nBf - 1; % Power for Bf

timewindow = -2:25;
nFir = 28;

%% Create design matrices for each run
for sub = allSubjects
    substr = ['sub' num2str(sub, '%02d')];
    folder = fullfile(MC01Dir, substr);

    % Load experimental log timing
    logs_root = fullfile('/disco/thomas/MC01/rawData', substr, 'LOGS');
    log_dir = dir(logs_root);

    for n_s = 1:8 % Runs
        pattern = ['^.+(','_main_run0', num2str(n_s), '_set00_log.mat', ')$'];
        for n_log = 1:size(log_dir, 1)
            if regexp(log_dir(n_log).name, pattern)
                logData = load(fullfile(log_dir(n_log).folder, log_dir(n_log).name));

                %% Define BF
                XX = 0:0.25:180; % Full range of orientations 
                mu =((logData.log.parameter.grating_samples)-180); % Centers of bf
                mu = mu(1):45/2:180;
                make_basis_function = @(mu, XX) abs(cosd(XX - mu)).^basis_pwr;
                
                % bf for all centers
                basis_functions = zeros(nBf, length(XX));
                for bf = 1:nBf
                    basis_functions(bf, :) = make_basis_function(mu(bf), XX);
                end

                 % plot(XX,basis_functions','LineWidth',2);
                 
                % Extract trial-specific orientations
                trial_orientations = logData.log.design.orientation - 180; % 32 orientations for this run
                trial_onsets = logData.log.onsets.sample / 1000; %  to seconds
                
                %  design matrix
                Xr = zeros(nVolsPerSession, nBf*nFir +1);
                Xr(:,end)= ones(936,1);

                             
                indices_mantained = find(logData.log.design.cued_modality == 1); % visual item is cued
                select_onsets_mantained = logData.log.onsets.sample(1,indices_mantained)';


                for trial = 1:length(indices_mantained)
                    % determine the correct column index based on sample orientation number
                    orientation = trial_orientations(indices_mantained(trial));
                    %  trial's onset and map to TR
                    onset_TR = round(select_onsets_mantained(trial) /1000 / TR) + 1; % Convert to TR
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
                
               
            end
        end
        % Save the design matrix for this run
       save(fullfile(folder,['designMat_BF_Run_' num2str(n_s) '.mat']), 'Xr');
         
    end
    
end
