close all; clear all; clc;
%% define subject directory 
 
spmtPath = '/disco/joana/CategOri_MRI/CategOri_MRIdata/02_data/lvl1/model_sample_activation_orientation';
RoiPath = '/disco/joana/CategOri_MRI/CategOri_MRIdata/02_data/ROI';
outDir ='/disco/emma/CvmRes_CatOri';
allSubjects = 1:45; allSubjects([14 15 20 25 28 36])=[];
nVolsPerSession=711;

%%

Results_Early = cell(numel(allSubjects),1)';
Results_Late = cell(numel(allSubjects),1)';

for sub = allSubjects
    substr = ['sub' num2str(sub,'%02d')];
    disp(substr)
    folder =fullfile(outDir,substr);
    Masks_Path = fullfile(RoiPath, substr);
    nRuns = 8;

    % define contrast
    C = eye(8);
    
    % Params
    nTimePoint = 26;
    
    analyses = cell(1, nTimePoint);

    bf_centers =  0:22.5:172.5; %Replace with infor from log
    C = cosd(abs(bf_centers*2-bf_centers'*2));              
            
    for Tsel = 1:nTimePoint
        CperT = zeros(208,8);
        for cn = 1:8
            iPlus = cn;   
            rPlus = Tsel + 26 * (iPlus - 1);
            CperT(rPlus, :) = C(cn,:);
            
        end
        
        % Define analyses and run ROI analysis for the current subject
        analysis_stimulus = Analysis.leaveOneSessionOut(4, CperT); 
        analyses{Tsel} = analysis_stimulus;
    end
    
    % Create Ys
    %% Ys 8 runs x 3 Regions 
    nRegions = 3;
    regions = {
                fullfile(Masks_Path, 'wIPS_Mask.nii'),...
                fullfile(Masks_Path, 'wVisual_Cortex_Mask.nii'),...
                fullfile(Masks_Path, 'wFEF_Mask.nii')
                      };

   Ysearly = cell(nRegions, 4);
    Yslate = cell(nRegions, 4);

    files = dir(fullfile(folder, '4Dvol.nii'));
    V = spm_vol(fullfile(files.folder, files.name));
        
    

    for roiIdx =1: nRegions
        % Load mask
        roiMask = spm_read_vols(spm_vol(regions{roiIdx}));
    
        % Load 4D file
        run_data = zeros(nVolsPerSession, sum(roiMask, 'all'));
        
        % Construct path to the subject's spmT_0001.nii file
        TmapFilePattern = fullfile(spmtPath,substr, 'spmT_0001.nii');
        Tmapfile = dir(TmapFilePattern);
        TmapPath = fullfile(spmtPath,substr,Tmapfile.name);
        Tmap = spm_read_vols(spm_vol(TmapPath));
        
        % Process ROIs and T-map
        Tmap(~roiMask) = 0;
        [s, si] = sort(Tmap(:), 'descend');
        nv = min(1000, sum(s > 0));
        mask = Tmap * 0;
        mask(si(1:nv)) = 1;

       
        img_sub = spmReadVolsMasked(V, mask);

        % Process each Run 
        for runidx = 1:8 %runs
            idx_vols = runidx * nVolsPerSession;
            img_run = img_sub(idx_vols - nVolsPerSession + 1 : idx_vols, :);
            img_run_detrend = detrend(img_run);
            avg_img = img_run_detrend;
            for idx_img = 1:size(img_run_detrend,1)-2
                avg_img(idx_img + 1, :) = mean(img_run_detrend(idx_img:(idx_img+2),:),1);
            end
            Ys{roiIdx, runidx} = avg_img(:, :);
   
            % Load X for each Run from struct
            runX = fullfile(folder,sprintf('designMat_BFRun_0%d.mat', runidx)); 
            Xs{runidx} = load(runX);
        end
    end
    
    
    RegionVcEarly  = Ys(2, [1 2 5 6]); % Visual Cortex Region 1
    RegionIpEarly  = Ys(1, [1 2 5 6]); % IP Region 2
    RegionFefEatly = Ys(3, [1 2 5 6]); % FEF Region 3

    RegionVcLate  = Ys(2, [3 4 7 8]); % Visual Cortex Region 1
    RegionIpLate  = Ys(1, [3 4 7 8]); % IP Region 2
    RegionFefLate = Ys(3, [3 4 7 8]); % FEF Region 3


    X_cell = cell(1, nRuns);
     for ic = 1:8
        X_cell{ic} = Xs{1, ic}.Xr;
    end
            
    X_cell_Early = X_cell(:,[1 2 5 6]);
    X_cell_Late = X_cell(:,[3 4 7 8]);
    

              
    modeledData1Early = ModeledData(RegionVcEarly, X_cell_Early); % VC 
    modeledData2Early = ModeledData(RegionIpEarly, X_cell_Early); % IP 
    modeledData3Early = ModeledData(RegionFefEatly, X_cell_Early); % FEF

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
