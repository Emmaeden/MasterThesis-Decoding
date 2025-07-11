close all; clear all; clc;
%% define subject directory 
MC01Dir = '/disco/emma/matlabscripts/MC01/data'; 
spmtPath = '/disco/thomas/MC01/data';
allSubjects = 1:38;
allSubjects([14 20])=[];

%%
Results_Early = cell(numel(allSubjects),1)';
Results_Late = cell(numel(allSubjects),1)';

for sub = allSubjects
    substr = ['sub' num2str(sub,'%02d')];
    substrr = ['sub_' num2str(sub,'%02d')];

    disp(substr)
    folder = fullfile(MC01Dir, substr);
    loadVarinfo= fullfile(folder, 'info.mat');
    load(loadVarinfo, 'nConds', 'regions', 'conditions', 'nVolsPerSession');
    modelDir = fullfile(folder, 'model');
    nSessions = 1:8;
    
    % define contrast
    C = eye(8);
    
    % Params
    nTimePoint = 28;
    
    analyses = cell(1, nTimePoint);

    bf_centers = 7.500:45/2:180; % <--- Replace with infor from log
    C = cosd(abs(bf_centers*2-bf_centers'*2));              
            
    for Tsel = 1:nTimePoint
        CperT = zeros(225,8);
        for cn = 1:8
            iPlus = cn;
                
            rPlus = Tsel + 28 * (iPlus - 1);
            
            CperT(rPlus, :) = C(cn,:);
            
        end
        
        % Define analyses and run ROI analysis for the current subject
        analysis_stimulus = Analysis.leaveOneSessionOut(4, CperT); 
        analyses{Tsel} = analysis_stimulus;
    end
    
    % Create Ys
    %% Ys 8 runs x 3 Regions 
    nRegions = 3;
    Ys = cell(nRegions, 8);
    files = dir(fullfile(folder, '4D.nii'));
    V = spm_vol(fullfile(files.folder, files.name));
    
    for roiIdx = 1:numel(regions)
        % Load mask
        roiMask = spm_read_vols(spm_vol(regions{roiIdx}));
    
        % Load 4D file
        %run_data = zeros(nVolsPerSession, sum(roiMask, 'all'));
        
        % Construct path to the subject's spmT_0001.nii file
       
        TmapPath = fullfile(spmtPath,substrr, 'lvl1/orientation_activation/spmT_0001.nii');
        Tmap = spm_read_vols(spm_vol(TmapPath));

        
        % Process ROIs and T-map
        %rois = spm_read_vols(spm_vol("wVisual_Cortex_Mask.nii"));
        Tmap(~roiMask) = 0;
        [s, si] = sort(Tmap(:), 'descend');
        nv = min(1000, sum(s > 0));
        mask = Tmap * 0;
        mask(si(1:nv)) = 1;

        img_sub = spmReadVolsMasked(V, mask);

        % Process each Run 
        for runidx = 1:8
            idx_vols = runidx * nVolsPerSession;
            img_run = img_sub(idx_vols - nVolsPerSession + 1 : idx_vols, :);
            img_run_detrend = detrend(img_run);
            avg_img = img_run_detrend;
            for idx_img = 1:size(img_run_detrend,1)-2
                avg_img(idx_img + 1, :) = mean(img_run_detrend(idx_img:(idx_img+2),:),1);
            end
            Ys{roiIdx, runidx} = avg_img(:, :);
   
            % Load X for each Run from struct
            runX = fullfile(folder,sprintf('designMat_BF_Run_%d.mat', runidx));
            Xs{runidx} = load(runX);
        end
    end
       
    
    RegionVcEarly  = Ys(2, [1 2 5 6]); % make Visual Cortex Region 1
    RegionIpEarly  = Ys(1, [1 2 5 6]); % IP Region 2
    RegionFefEarly = Ys(3, [1 2 5 6]); % FEF Region 3

    RegionVcLate  = Ys(2, [3 4 7 8]); % make Visual Cortex Region 1
    RegionIpLate  = Ys(1, [3 4 7 8]); % IP Region 2
    RegionFefLate = Ys(3, [3 4 7 8]); % FEF Region 3

    Earlyrun = [1 2 5 6];
    Laterun  = [3 4 7 8];

    X_cell_Early = cell(1,numel(Earlyrun));
    X_cell_Late  = cell(1, numel(Laterun));

    for i = 1:numel(Earlyrun)
        X_cell_Early{i} =  Xs{1,Earlyrun(i)}.Xr;
    end

    for i = 1:numel(Laterun)
        X_cell_Late{i} =  Xs{1,Laterun(i)}.Xr;
    end

    
    

              
    modeledData1Early = ModeledData(RegionVcEarly, X_cell_Early); % VC 
    modeledData2Early = ModeledData(RegionIpEarly, X_cell_Early); % IP 
    modeledData3Early = ModeledData(RegionFefEarly, X_cell_Early); % FEF

    modeledData1Late = ModeledData(RegionVcLate, X_cell_Late); % VC 
    modeledData2Late = ModeledData(RegionIpLate, X_cell_Late); % IP 
    modeledData3Late = ModeledData(RegionFefLate, X_cell_Late); % FEF
    
    ccm1Early = CvCrossManova(modeledData1Early, analyses);
    ccm2Early = CvCrossManova(modeledData2Early, analyses);
    ccm3Early = CvCrossManova(modeledData3Early, analyses);

    ccm1Late = CvCrossManova(modeledData1Late, analyses);
    ccm2Late = CvCrossManova(modeledData2Late, analyses);
    ccm3Late = CvCrossManova(modeledData3Late, analyses);
    
    % Will give you 28 Ds 
    D1Early = ccm1Early.runAnalyses; % 28 Ds for Visual Cortex  
    D2Early = ccm2Early.runAnalyses; % 28 Ds for IP 
    D3Early = ccm3Early.runAnalyses; % 28 Ds for FEF

    D1Late = ccm1Late.runAnalyses; % 28 Ds for Visual Cortex  
    D2Late = ccm2Late.runAnalyses; % 28 Ds for IP 
    D3Late = ccm3Late.runAnalyses; % 28 Ds for FEF

    Results_Early{sub} = [D1Early D2Early D3Early];
    Results_Late{sub} = [D1Late D2Late D3Late];
end
