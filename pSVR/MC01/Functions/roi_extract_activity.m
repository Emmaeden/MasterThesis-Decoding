      
function [roi_idx, ROI_nii] = roi_extract_activity(SUB, DIR,roi,param_size)


    t_directory = fullfile(DIR.lvl1);
    mask =  roi;

        fprintf('------ Extract Activity SUBJECT: %02d------\n', SUB);

        % Activation based masks for sensory areas:
        t_vol = spm_vol(fullfile(t_directory,'spmT_0001.nii'));
        t_img = spm_read_vols(t_vol);  
        m_index = find(mask);
        
        t_img = t_img .* mask;
                        
        % find indices of most activated voxels in the original image space
        [~,roi_idx_sorted] = sort(t_img(m_index),'descend');

        max_roi_size = max(param_size);    
%         size(roi_idx_sorted)  
%         max_roi_size = min(numel(roi_idx_sorted),max_roi_size);
        roi_idx = roi_idx_sorted(1:max_roi_size);
                
        roi_img_idx = m_index(roi_idx); % needed for 3D image reconstruction

        original_image_size = size(t_img);

        % Mask
        %t_img(find(mask==0)) = 0;
        %mask = spm_read_vols(spm_vol(fullfile(DIR.subjRoiDir,[curr_roi '.nii'])));
        
        t_img(find(mask==0)) = 0;
        
        % find indices of most activated voxels in the original image space
        [~,roi_img_idx_sorted] = sort(t_img(:),'descend');

        
        % load only ROI voxels of T-image
        t_roi = spmReadVolsMasked(t_vol, mask);

        % find indices of most activated voxels in ROI space
        [~,roi_idx_sorted] = sort(t_roi,'descend');

        % determine max number of voxels of interest, use to extract corresponding
        % data and voxel indeces
        max_roi_size = max(param_size);

        % get voxel indices of interest in ROI and image space               
        max_roi_size = min(numel(roi_idx_sorted),max_roi_size);
        
        roi_idx = roi_idx_sorted(1:max_roi_size);
        roi_img_idx = roi_img_idx_sorted(1:max_roi_size); % needed for 3D image reconstruction
        
        ROI_nii = zeros(original_image_size);
        ROI_nii(roi_img_idx) = 1;
    
%         mask_path = fullfile(DIR.subjRoiDir,[prefx,'t',roi,'.nii']);
%         niftiwrite(ROI_nii,mask_path);
    end