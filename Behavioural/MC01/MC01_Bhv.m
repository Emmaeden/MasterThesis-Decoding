
close all; clear all; clc;

%% Dir of Logs
p = struct;
p.dirs.data          = '/disco/thomas/MC01/rawData/';
p.data.n_runs        = 8;

subjects = 1:38;
missing = [14 20];
subjects(missing) = [];

% arrays to store accuracies for each subject
early_accuracies = [];
late_accuracies = [];


for SUB = 1:numel(subjects)
    i_sub = subjects(SUB);
    sub_str = num2str(i_sub,'%02i');
    in_dir = fullfile(p.dirs.data,['sub' sub_str]);
    
    % Load log files and behavioral data  
    for i_run = 1:p.data.n_runs
        run_str = num2str(i_run,'%02i');
        logfile = dir(fullfile(in_dir,'LOGS',['*_main_run' run_str '_set00_log.mat']));
        load(fullfile(logfile.folder, logfile.name),'log');
        logs(SUB,i_run) = log;
    end
    
   
    % extract visual trials
    m_b = struct([]);
    m_d = struct([]);

    % Extract behavioral data
    b = [logs(SUB,:).behaviour];
    d = [logs(SUB,:).design];

      
    for ridx = 1:length(d)

        vistrial = d(ridx).cued_modality ==1 ;
        m_b(ridx).correct = b(ridx).correct(vistrial);
        m_b(ridx).miss = b(ridx).miss(vistrial);
        m_b(ridx).rt = b(ridx).rt(vistrial);

        m_d(ridx).task_orientation_diff = d(ridx).task_orientation_diff(vistrial);
        m_d(ridx).cued_modality = d(ridx).cued_modality(vistrial);
    end
      
    % all visual trials
    correct = [m_b.correct];
    miss = [m_b.miss];
    rt = [m_b.rt];
    diff = [m_d.task_orientation_diff];
    mod = [m_d.cued_modality ]; 
    
    % for run comparison
    correctmat = reshape(correct, 16,[]); %32trialsx8
    missmat = reshape(miss,16,[]);
    rtmat= reshape(rt,16,[]);
    modmat = reshape(mod,16,[]);
    
    % Split data
    % define learning phases within sessions
     earlySess = 1:4;  %earlySess = [1 2 5 6];
     lateSess = 5:8;  %lateSess = [3 4 7 8];

    early_correct = correctmat(:,earlySess);  % Correct responses for first 4 runs
    early_miss = missmat(:,earlySess);        % Misses for first 4 runs
    early_rt = rtmat(:,earlySess);            % RT for first 4 runs
    early_mod = modmat(:,earlySess);
  
    late_correct = correctmat(:,lateSess);  % Correct responses for last 4 runs
    late_miss = missmat(:,lateSess);        % Misses for last 4 runs
    late_rt = rtmat(:,lateSess);            % RT for last 4 runs
    late_mod = modmat(:,lateSess);            % RT for last 4 runs

    
    %% Calculate accuracy rates 
    early_accuracy = mean(early_correct(~early_miss & early_mod == 1)); %
    late_accuracy = mean(late_correct(~late_miss & late_mod == 1)); % 

    early_rt_avg = mean(early_rt(~early_miss & early_mod == 1));
    late_rt_avg = mean(late_rt(~late_miss & late_mod == 1));
    
    % Store accuracies and RT for averaging later
    res.early_accuracies(SUB) = early_accuracy;
    res.late_accuracies(SUB) = late_accuracy;

    res.early_rt_avg_subjects(SUB)= early_rt_avg;
    res.late_rt_avg_subjects(SUB)= late_rt_avg;     

end
 
%% save Results
save('MC01-Bhv-AcrossSessions.mat','res');


