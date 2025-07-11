%%%% Script to get ROI data for each participant %%%%%
% gets the activation maps, 1000 most active voxel in each ROI
% and saves everything in new directory
% this way not all data needs to be loaded everytime

function [data,regs] = get_ROI_data(i_SUB,s)

    % Check if data is already there %% loop through each subject and take
    % the data 
    if isfield(s,'scratchDataDir')
        s.scratchFile = fullfile(s.scratchDataDir,['sub' num2str(i_SUB,'%02d') '_ROI.mat']);

        if exist(s.scratchFile,'file')
            loaded_data = load(s.scratchFile);

            assert(isequal(loaded_data.s.analysis.ROI,s.analysis.ROI),'trying to load_data for different ROIS');
            assert(isequal(loaded_data.s.preproc.n_voxel,s.preproc.n_voxel),'trying to load_data for different Voxel Counts');
            %assert(isequal(loaded_data.s.preproc.average_TR,s.preproc.average_TR),'trying to load_data for different Sliding Window width');
            %assert(isequal(loaded_data.s.preproc.n_nodes,s.preproc.n_nodes),'trying to load_data for different number of filter nodes'); 
    
            data = loaded_data.data;
            regs = loaded_data.regs;
            fprintf('--- Loading previously extracted and preprocessed data ---- \n')
            return;        
        end
    end
    
    
    %% Get the activity maps and ROIs
    DIR.baseDir = fullfile('/disco/joana/CategOri_MRI/CategOri_MRIdata/02_data/nifti');
    DIR.lvl1 = fullfile('/disco/joana/CategOri_MRI/CategOri_MRIdata/02_data/lvl1/model_sample_activation_orientation', sprintf('sub%02d',i_SUB)); %% change
    DIR.dataDir = fullfile(DIR.baseDir,sprintf('sub%02d',i_SUB));
    DIR.CatOri = fullfile('/disco/emma/CvmRes_CatOri',sprintf('sub%02d',i_SUB));
    %mkdir(fullfile(DIR.CatOri,'results'));
    DIR.resDir  = fullfile(DIR.CatOri, 'results'); 
    DIR.runDir = fullfile(DIR.baseDir,sprintf('sub%02d',i_SUB),'orientation','run00');
    
    % get spm activity masks
    activity_dir = fullfile(DIR.lvl1); % link the model for each subject to get the beta maps
    
    regs = struct;
    
    nROI = numel(s.analysis.ROI);
    regions = cell(nROI, 1);
    
    % loading multiple ROIs at once
    for i_roi = 1:nROI
        n_voxel = s.preproc.n_voxel{i_roi};
        spm_mask = spm_vol(fullfile(activity_dir,'mask.nii')); 
        mask_name = [s.analysis.ROI{i_roi},'.nii'];
        roi_mask = spm_vol(fullfile('//disco/joana/CategOri_MRI/CategOri_MRIdata/02_data/ROI/',sprintf('sub%02d',i_SUB) , mask_name));


        
    
        % load files and decide which mask to use
        spm_mask = spm_read_vols(spm_mask);
        roi_mask = spm_read_vols(roi_mask);
        roi_mask(find(spm_mask==0)) = 0;                                        % Mask ROI mask with SPM mask
        mask = roi_mask;
        
        [roi_idx, ROI_nii] = roi_extract_activity(i_SUB, DIR, mask,n_voxel); 
        mask = ROI_nii;
    
        regions{i_roi} = mask;
    end
    
    
    % indices for individual ROIs within the overall loaded data - with Credit
    % to Carsten
    all_masks = regions;
    % keyboard
    regions = (cat(4, regions{:}) > 0);
    mask = any(regions, 4);
    regions = reshape(regions, [], nROI);
    
    rmvi = cell(nROI, 1);
    for i_roi = 1:nROI
        rmvi{i_roi} = find(regions(mask(:), i_roi));
        fprintf('  %d in-mask voxels in region %d\n', numel(rmvi{i_roi}), i_roi)
    end
    regs.rmvi = rmvi;
    
    % load data using cvManova toolbox
    data = [];
   % for i_session = 1:4
     for i_run = 1:8  
            %run_idx = i_run + 4*(i_session-1);
            
            vols = dir(fullfile([DIR.runDir(1:end-1), num2str(i_run)], 'rew*')); % change rundir to your folder
            files = arrayfun(@(x) fullfile(x.folder, x.name), vols, 'UniformOutput', false);
        
            data(:,:,i_run) = spmReadVolsMasked(files, mask);  % 
      end
   % end
    
    %% Preprocessing

    % detrending
    if s.preproc.n_nodes > 0
        data = detrend_spline(data, s.preproc.n_nodes, 1); % recommended: trials/2
    end

    % apply moving average to time series 
    if s.preproc.average_TR > 0
        data = moving_average(data, s.preproc.average_TR); 
    end
%     
    %% Safe files on scratch directory
    if isfield(s,'scratchDataDir')
        if ~exist(s.scratchDataDir,'dir'), mkdir(s.scratchDataDir); end
        save(s.scratchFile,'data','regs','all_masks','s')
    end

