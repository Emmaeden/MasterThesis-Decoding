
function s = pSVRcatOri(i_SUB,s)
% This is a script to run periodic Support Vector Regression (pSVR) for
% multiple TRs.


%% Get details
% prepare struct with main conditions to compare
s.conditions = struct();
s.conditions(1).name = ' Visual Orientations';


fprintf('\n ------ Start SVR ID:%d ------ \n\n', i_SUB)

% get directories, behavioural log files and subject code
subcode = ['sub' num2str(i_SUB,'%02d')];

% load fMRI data, outputs all data and subject specific ROI data
s.i_SUB = i_SUB;
[dat_all,regs] = load_subject_data(s);

%% Main loop over ROIs, conditions and stimulus types
for i_r = 1:numel(s.analysis.ROI)
    %select current ROI when multiple are given
    s.curr_ROI = s.analysis.ROI{i_r};
    % prepare data struct D for output
    D = struct();

    fprintf('\n ------   Data Subject %d ------ \n\n', i_SUB)
    dat = dat_all(:,regs.rmvi{i_r},:);

    % make output directory if it does not exist yet
    out_dir = fullfile('CatOriRes','psvr_results',s.results.folder_name,[s.analysis.ROI{i_r}]);
    if ~exist(out_dir,'dir'), mkdir(out_dir); end

   

    %% Get labels and reformat data based on trial info
    [s, data] = get_data(i_SUB,1,s,dat);

    %% prepare labels
    labels = wrapTo360(s.conditions.samples *2); %scale from 0-360

    labels = labels(:);

    % labels in rad for sin and cos
    label_rad = deg2rad(labels)-pi;  % turn to rad and shift to range -pi:pi
    label_sin = sin(label_rad);  % extract sin and cos components
    label_cos = cos(label_rad);
    label = mat2cell([label_sin, label_cos], ones(numel(label_rad),1));

    % get data dimensions
    n_trial = size(data,1);
    n_vox   = size(data,2);
    n_run   = size(data,3);
    n_tr    = size(data,4);
   
    % prepare n_files and chunk for TDT
    n_files = n_trial * n_run;
    chunk = sort(repmat(1:n_run, 1, n_trial))';

    %% Run reconstruction via TDT across TRs

    for i_tr = 1:n_tr

        fprintf('- TR: %d ...\n ', i_tr);

        % grab data of cuurent TR and bring into right format for TDT
        yt = data(:,:,:,i_tr);
        yt = permute(yt, [1,3,2]); % turn 3D array data_decode into 2D array that can be used for TDT
        yt = reshape(yt,n_files, [], 1);

        % reassign passed_data and results to avoid looping issues
        passed_data = [];
        n_tr = size(data,4);

        % set up cfg for TDT
        cfg = decoding_defaults;
        cfg.results.overwrite = 1;
        cfg.analysis = 'ROI';
        cfg.decoding.method = 'regression';
        cfg.decoding.train.classification.model_parameters = '-s 4 -t 2 -c 1 -n 0.5 -b 0 -q';   % libsvm SVR parameters
        cfg.multitarget = 1;
        cfg.decoding.software = 'libsvm_multitarget';
        cfg.results.output = {'predicted_labels_multitarget'};
        cfg.scale.method = 'min0max1';   % rescaling to range [0 1]; makes it faster
        cfg.scale.estimation = 'across'; % scaling estimated on training data and applied to test data
        cfg.plot_selected_voxels = 0;
        cfg.plot_design = 0;
        cfg.results.write = 0;
        cfg.verbose = 0;

        % fill passed_data
        passed_data.data = yt;
        [passed_data,cfg] = fill_passed_data(passed_data, cfg, label, chunk); % decoding toolbox

        % create design (and plot once if required)
        cfg.design = make_design_cv(cfg);
        %               if i_tr == 1
        %                   cfg.fighandles.plot_design = plot_design(cfg); % function
        %                end

        %% Decoding
        [results, cfg, passed_data] = decoding(cfg, passed_data);


        %% get sin and cos predictions from result structure
        sin_y = results.predicted_labels_multitarget.output.model{1}.predicted_labels;
        cos_y = results.predicted_labels_multitarget.output.model{2}.predicted_labels;
        sin_y = reshape(sin_y, [], n_run);
        cos_y = reshape(cos_y, [], n_run);

        % reconstruct predicted angular label using four-quadran arctangent
        ang_y = atan2(sin_y,cos_y); % result in radians

        % angular deviation
        pred_diff = angdiff(label_rad,ang_y(:));

        D.angle_diff(i_tr,:)= num2cell(pred_diff,1);
        
    end


    clear data; clear data_new;

    saveFile = matfile(fullfile(out_dir, [subcode 'pSVRresults.mat']), 'Writable',true);
    saveFile.D = D;
    saveFile.s = s;
    clear saveFile, clear D
end
