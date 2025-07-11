%%%% Script to get ROI data for each participant %%%%%
% gets the activation maps, 1000 most active voxel in each ROI
% and saves everything in new directory
% this way not all data needs to be loaded everytime

function [data,regs] = get_ROI_dataupdatedEm(i_SUB,s)

    % Check if data is already there
    if isfield(s,'scratchDataDir')
        s.scratchFile = fullfile(s.scratchDataDir,['sub' num2str(i_SUB,'%02d') '_ROI.mat']);

        if exist(s.scratchFile,'file')
            loaded_data = load(s.scratchFile);

            assert(isequal(loaded_data.s.analysis.ROI,s.analysis.ROI),'trying to load_data for different ROIS');
            assert(isequal(loaded_data.s.preproc.n_voxel,s.preproc.n_voxel),'trying to load_data for different Voxel Counts');
            assert(isequal(loaded_data.s.preproc.average_TR,s.preproc.average_TR),'trying to load_data for different Sliding Window width');
            assert(isequal(loaded_data.s.preproc.n_nodes,s.preproc.n_nodes),'trying to load_data for different number of filter nodes'); 
    
            data = loaded_data.data;
            regs = loaded_data.regs;
            fprintf('--- Loading previously extracted and preprocessed data ---- \n')
            return;        
        end
    end
    
    
    %% Get the activity maps and ROIs
    DIR = get_dir(i_SUB);
    
    % get spm activity masks
    activity_dir = fullfile(DIR.lvl1,'baseline');
    
    regs = struct;
    
    nROI = numel(s.analysis.ROI);
    regions = cell(nROI, 1);
    
    % loading multiple ROIs at once
    for i_roi = 1:nROI
%         n_voxel = s.preproc.n_voxel{i_roi};

        spm_mask = spm_vol(fullfile(activity_dir,'mask.nii'));
%         roi_mask = spm_vol(fullfile(DIR.subjRoiDir,['w',s.analysis.ROI{i_roi},'_Mask.nii']));
        roi_mask = spm_vol(fullfile(DIR.subjRoiDir,[s.analysis.ROI{i_roi},'.nii']));
    
        % load files and decide which mask to use
        spm_mask = spm_read_vols(spm_mask);
        roi_mask = spm_read_vols(roi_mask);
        roi_mask(find(spm_mask==0)) = 0; % Mask ROI mask with SPM mask

        fprintf('------ Extract Activity SUBJECT: %02d------\n', i_SUB);

        t_directory = fullfile(DIR.lvl1,'baseline');
        
        % Activation based masks for sensory areas:
        t_vol = spm_vol(fullfile(t_directory,'spmT_0001.nii'));
        t_img = spm_read_vols(t_vol);  
        m_index = find(roi_mask);
        t_img = t_img .* roi_mask;
        
        % find indices of most activated voxels in the original image space
        [~,roi_idx_sorted] = sort(t_img(m_index),'descend');

        % select all voxel 
        % which have a larger t-value than 1:
        max_roi_size = size(find(t_img(m_index) > 1),1);
        % max_roi_size = max(param_size); %1000  
%         max_roi_size = round(size(roi_idx_sorted,1)*0.25);

        roi_idx = roi_idx_sorted(1:max_roi_size);
        roi_img_idx = m_index(roi_idx); % get idx in image space 
        
        ROI_nii = zeros(size(roi_mask));
        ROI_nii(roi_img_idx) = 1;

%         mask_path = fullfile(DIR.subjRoiDir,['t_V2.nii']);
%         niftiwrite(ROI_nii,mask_path);

        regions{i_roi} = ROI_nii;
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
    for i_session = 1:4
        for i_run = 1:4  
            run_idx = i_run + 4*(i_session-1);
            
        vols = dir(fullfile(DIR.runDir{i_session,i_run}, 'rew*'));
            files = arrayfun(@(x) fullfile(x.folder, x.name), vols, 'UniformOutput', false);
        
            data(:,:,run_idx) = spmReadVolsMasked(files, mask, 1);  
        end
    end
    
    %% Preprocessing

    % detrending
    if s.preproc.n_nodes > 0
        data = detrend_spline(data, s.preproc.n_nodes, 1); % recommended: trials/2
    end

    % apply moving average to time series 
    if s.preproc.average_TR > 0
        data = moving_average(data, s.preproc.average_TR); 
    end
    
    %% Safe files on scratch directory
    if isfield(s,'scratchDataDir')
        if ~exist(s.scratchDataDir,'dir'), mkdir(s.scratchDataDir); end
        save(s.scratchFile,'data','regs','all_masks','s')
    end

