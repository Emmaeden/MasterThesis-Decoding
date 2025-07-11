function [data,regs] = load_subject_data(s)

s.scratchFile = fullfile(s.scratchDataDir,['sub' num2str(s.i_SUB,'%02d') '_ROI.mat']);

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
