function session = get_logs(SUB)


    substr = ['sub' num2str(SUB,'%02d')];
    logs_root = fullfile('/disco/joana/CategOri_MRI/CategOri_MRIdata/02_data/logs', substr,'*orientation*.mat');
    log_dir = dir(logs_root);
     % Extract numeric values for sorting
    datesNum= [log_dir.datenum];
    
    [~,sortedIdx]=sort(datesNum,'ascend');
   
   
   
    
    % Reorder log files based on sorted indices
    log_dir = log_dir(sortedIdx);

    %DIR = get_dir(SUB);
    session = struct();
    
   

%    %for n_s = 1:8
%         for n_log = 1:size(log_dir, 1)
% %             if regexp(log_dir(n_log).name,'orientation')
%                 session(n_s).logs = load(fullfile(log_dir(n_log).folder, log_dir(n_log).name));
% %             end
%         end
%   % end

      for n_s=1:length(log_dir)
          session(n_s).logs = load(fullfile(log_dir(n_s).folder, log_dir(n_s).name));
      end

 
end


