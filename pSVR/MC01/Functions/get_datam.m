function [s, data_new] = get_datam(i_SUB,i_con,s, dat)

 
session = get_logs(i_SUB);

visOro = s.analysis;


% moving average shifts TRs:
if s.preproc.average_TR == 3
    timeshift = 1; 
elseif s.preproc.average_TR == 5
    timeshift = 2;
elseif s.preproc.average_TR == 0
    timeshift = 0;
end


for i_run = 1:8
    run_idx = i_run;
    log = session(i_run).logs.log;

    
    indices_visual_cued = find(log.design.cued_modality == 1); % visual item is cued
    trial_idx(:,run_idx) = indices_visual_cued;

    

    % get Onsets for maintained trials 
    select_onsets_mantained = log.onsets.trial(1,indices_visual_cued);
    
    
    % get all stimulus samples for the selected trials
    
    all_stims(:,run_idx) = log.design.orientation(indices_visual_cued);    
   

    
    %% Get data
    % n_trials x n_voxels x n_runs x n_TRs
    
    sample_onset_tr = round(log.onsets.trial(indices_visual_cued)./1000./s.tr);
   
    % now we're getting the TRs indices for each trial
    tr_idx = [];    
    
    timewindow = -2:25;
    tr_idx(1:16,1:28,run_idx) = sample_onset_tr'+timewindow;
   
    
    % format data for tdt

    for i_trial = 1:size(tr_idx,1)

        if any(tr_idx(i_trial,:,run_idx) >= size(dat,1)) 
            fprintf('Error')
            keyboard
        end
          
        dat_tmp = dat(tr_idx(i_trial,:,run_idx),:,run_idx);

        data_new(i_trial,:,run_idx,:)  = permute(dat_tmp, [2,3,1]); 
       
        clear dat_tmp;
    end
end

s.conditions.trial_idx = trial_idx;
s.conditions.samples   = all_stims -180;
 
end