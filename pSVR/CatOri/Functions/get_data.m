function [s, data_new] = get_data(i_SUB,i_con,s, dat)

 
session = get_logs(i_SUB);

a = s.analysis;


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

    % get the trial indices for each condition
    trial_idx(:,:,run_idx) = find(log.design.sample>=0); 
    


    
    
    % get all stimulus samples for the selected trials
    
    all_stims(:,:,run_idx) = log.design.sample';    
    

    
    %% Get data
    % n_trials x n_voxels x n_runs x n_TRs
    
    sample_onset_tr = round(log.onsets.STIM./s.tr);
   
    % now we're getting the TRs indices for each trial
    tr_idx = [];    
    
    timewindow = -2:23;
    tr_idx(1:24,1:26,run_idx) = sample_onset_tr'+timewindow;
   
    
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

s.conditions.trial_idx = squeeze(trial_idx);
s.conditions.samples   = squeeze(all_stims) ;

end