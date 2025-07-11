function [s, data_new] = get_data_updatedEm(i_SUB,i_con,s, dat)

 
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

for i_sess = 1:4

    for i_run = 1:4
        run_idx = i_run + 4*(i_sess-1);

        log = session(i_sess).logs(i_run).log;

        % get the trial indices for each load condition
        trialIndx= find(log.design.load);
        trial_idx(:,run_idx) = trialIndx; 
        cue(:,run_idx) = log.design.cue';
        % get all stimulus samples for the selected trials
        all_stims(:,run_idx)       = log.design.target(:,trial_idx(:,run_idx) );
        

         %% Get data
        % n_trials x n_voxels x n_runs x n_TRs
        trialsOnsets = arrayfun(@(t) log.onsets.STIM(cue(t),t), 1:48);
        sample_onset_tr = round(trialsOnsets/s.tr);

        
       
        % now we're getting the TRs indices for each trial
        tr_idx = [];    
        
        timewindow = -2:22;
        tr_idx(1:48,1:25,run_idx) = sample_onset_tr'+timewindow;
        
    
        % format data for tdt

           for i_trial = 1:size(tr_idx,1)

                if any(tr_idx(i_trial,:,run_idx) >= size(dat,1)) 
                    fprintf('Error')
                    keyboard
                end
                validTrials = min(tr_idx(i_trial,:,run_idx),size(dat,1)); 
                %dat_tmp = dat(tr_idx(i_trial,:,run_idx),:,run_idx);
                dat_tmp = dat(validTrials,:,run_idx);
        
                data_new(i_trial,:,run_idx,:)  = permute(dat_tmp, [2,3,1]); 
               
                clear dat_tmp;
          end
     end
 end

s.conditions.trial_idx = trial_idx;
s.conditions.samples   = all_stims ; 
end