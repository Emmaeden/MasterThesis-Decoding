function session = get_logs(SUB)


    substr = ['sub' num2str(SUB,'%02d')];
    logs_root = fullfile('/disco/thomas/MC01/rawData', substr, 'LOGS');
    log_dir = dir(logs_root);

    %DIR = get_dir(SUB);
    session = struct();


  for n_s = 1:8 %Runds
        pattern = ['^.+(','_main_run0',num2str(n_s),'_set00_log.mat',')$'];
        for n_log = 1:size(log_dir, 1)
            if regexp(log_dir(n_log).name, pattern)
                session(n_s).logs = load(fullfile(log_dir(n_log).folder, log_dir(n_log).name));
            end
        end
  end
end


