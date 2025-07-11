function DIR = get_dir(i_SUB, s)
    
    %% First we get all the main directories
    DIR.baseDir = fullfile('SeqWm');
    DIR.dataDir = fullfile('/disco/vivien/SeqWM/02_data'); 
    DIR.resDir  = fullfile(DIR.baseDir, 'PsvrSeq_results'); 
    DIR.mniDir  = fullfile('Toolboxes','spm12');

    %% Then subject specific directories
    subcode = ['sub' num2str(i_SUB,'%02d')];
    
    DIR.roiTemplates = fullfile(DIR.dataDir, 'D_ROI','ROI_templates');  
    DIR.subjRoiDir   = fullfile(DIR.dataDir,'D_ROI', subcode);

    DIR.anat = fullfile(DIR.dataDir, 'B_PREPROC', 'anat', subcode,'/');
    DIR.func = fullfile(DIR.dataDir, 'B_PREPROC', 'func', subcode,'/');
%     if ~exist(DIR.anat, 'dir'), mkdir(DIR.anat); end
%     if ~exist(DIR.func, 'dir'), mkdir(DIR.func); end

    DIR.lvl1 = fullfile(DIR.dataDir, 'C_LVL1', subcode);

    
    for i_s = 1:4
        sessioncode = ['session' num2str(i_s)];
        
        DIR.dicomDir{i_s} = fullfile(DIR.dataDir,'A_RAW',subcode,'mri',sessioncode);
        DIR.behavDir{i_s} = fullfile(DIR.dataDir,'A_RAW',subcode,'behav',sessioncode);
        DIR.behavDirGen = fullfile(DIR.dataDir,'A_RAW',subcode, 'behav');
         
        for i_r = 1:4
            runcode = ['run' num2str(i_r)];
            DIR.runDir{i_s,i_r} = fullfile(DIR.func,sessioncode,runcode);

%             if ~exist(DIR.runDir{i_s,i_r}, 'dir')
%                mkdir(DIR.runDir{i_s,i_r})
%             end
        end
    end