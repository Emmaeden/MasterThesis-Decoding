close all; clear all; clc;
%% define subject directory 
 
spmtPath = '/disco/vivien/SeqWM/02_data/C_LVL1';
RoiPath = '/disco/vivien/SeqWM/02_data/D_ROI';
outDir ='/disco/emma/matlabscripts/SeqWm/Data';
allSubjects = 1:24; allSubjects(9)=[];
nVolsPerSession=1600;

%%

ResultsEarly = cell(numel(allSubjects),1)';
ResultsLate = cell(numel(allSubjects),1)';

for sub = allSubjects
    substr = ['sub' num2str(sub,'%02d')];
    disp(substr)
    folder =fullfile(outDir,substr);
    Masks_Path = fullfile(RoiPath, substr);
    nRuns = 16;

    % define contrast
    C = eye(12);
    
    % Params
    nTimePoint = 25;
    
    analyses = cell(1, nTimePoint);

    bf_centers = 0:15:172.5; %Replace with infor from log
    C = cosd(abs(bf_centers*2-bf_centers'*2));              
            
    for Tsel = 1:nTimePoint
        CperT = zeros(300,12);
        for cn = 1:12
            iPlus = cn;   
            rPlus = Tsel + nTimePoint * (iPlus - 1);
            CperT(rPlus, :) = C(cn,:) ;
            
        end
        
        % Define analyses and run ROI analysis for the current subject
        analysis_stimulus = Analysis.leaveOneSessionOut(8, CperT); 
        analyses{Tsel} = analysis_stimulus;
    end
    
    % Create Ys
    %% Ys 8 runs x 3 Regions 
    nRegions = 3;
    regions = {
                fullfile(Masks_Path, 'wIPS_Mask.nii'),...
                fullfile(Masks_Path, 'wV1-V3_Mask.nii'),...
                fullfile(Masks_Path, 'wsPCS_Mask.nii')

                      };

    Ys = cell(nRegions, nRuns);

    files = dir(fullfile(folder, '4D.nii'));
    V = spm_vol(fullfile(files.folder, files.name));
        
    

    for roiIdx =1: nRegions
        % Load mask
        roiMask = spm_read_vols(spm_vol(regions{roiIdx}));
    
        % Load 4D file
        run_data = zeros(nVolsPerSession, sum(roiMask, 'all'));
        
        % Construct path to the subject's spmT_0001.nii file
        TmapFilePattern = fullfile(spmtPath,substr,'baseline','spmT_0001.nii');
        Tmapfile = dir(TmapFilePattern);
        TmapPath = fullfile(spmtPath,substr,'baseline',Tmapfile.name);
        Tmap = spm_read_vols(spm_vol(TmapPath));
        
        % Process ROIs and T-map
        Tmap(~roiMask) = 0;
        [s, si] = sort(Tmap(:), 'descend');
        nv = min(1000, sum(s > 0));
        mask = Tmap * 0;
        mask(si(1:nv)) = 1;

        %img_sub = spmReadVolsMasked(V, mask);
        img_sub = spmReadVolsMasked(V, mask);

        % Process each Run 
        for runidx = 1:16 %runs
            idx_vols = runidx * nVolsPerSession;
            img_run = img_sub(idx_vols - nVolsPerSession + 1 : idx_vols, :);
            img_run_detrend = detrend(img_run);
            avg_img = img_run_detrend;
            for idx_img = 1:size(img_run_detrend,1)-2
                avg_img(idx_img + 1, :) = mean(img_run_detrend(idx_img:(idx_img+2),:),1);
            end
            Ys{roiIdx, runidx} = avg_img(:, :);
            if runidx <10
            % Load X for each Run from struct
                runX = fullfile(folder,sprintf('designMat_BFRun_new0%d.mat', runidx)); 
            else
                runX = fullfile(folder,sprintf('designMat_BFRun_new%d.mat', runidx)); 
            end
            Xs{runidx} = load(runX);
        end
    end
    
    
    EarlyRuns = [1 2 3 4 9 10 11 12];
    LateRuns  = [5 6 7 8 13 14 15 16 ];
%      EarlyRuns = 1:8;
%      LateRuns  = 9:16;
    
    RegionVCEarly  = Ys(2,EarlyRuns); % V1 Region 1
    RegionIpsEarly = Ys(1,EarlyRuns); % IPS1 Region 2
    RegionsPCSEarly = Ys(3,EarlyRuns); % sPCS Region 3

    RegionVCLate  = Ys(2,LateRuns); % V1 Region 1
    RegionIpsLate = Ys(1,LateRuns); % IPS1 Region 2
    RegionsPCSLate = Ys(3,LateRuns); % sPCS Region 3


    X_cell = cell(1, nRuns);
   
     for ic = 1:16
         
        X_cell{ic} = Xs{1, ic}.Xr;
    end
            
    modeledDataVCEarly   = ModeledData(RegionVCEarly, X_cell(EarlyRuns)); % Vc 
    modeledDataIPSEarly  = ModeledData(RegionIpsEarly, X_cell(EarlyRuns)); % IPs
    modeledDatasPCSEarly = ModeledData(RegionsPCSEarly, X_cell(EarlyRuns)); % sPCS

    modeledDataVCLate   = ModeledData(RegionVCLate, X_cell(LateRuns)); % Vc 
    modeledDataIPSLate  = ModeledData(RegionIpsLate, X_cell(LateRuns)); % IPs
    modeledDatasPCSLate = ModeledData(RegionsPCSLate, X_cell(LateRuns)); % sPCS
    

    
    ccmVcEarly   = CvCrossManova(modeledDataVCEarly, analyses);
    ccmIpsEarly  = CvCrossManova(modeledDataIPSEarly, analyses);
    ccmsPCSEarly = CvCrossManova(modeledDatasPCSEarly, analyses);

    ccmVcLate   = CvCrossManova(modeledDataVCLate, analyses);
    ccmIpsLate  = CvCrossManova(modeledDataIPSLate, analyses);
    ccmsPCSLate = CvCrossManova(modeledDatasPCSLate, analyses);

  % Will give you  Ds 
    DVcEarly   = ccmVcEarly.runAnalyses; % 25 Ds for V1-V3
    DIpsEarly  = ccmIpsEarly.runAnalyses; % 25 Ds for IPs
    DsPCSEarly = ccmsPCSEarly.runAnalyses; % 25 Ds for sPCS

    DVcLate  = ccmVcLate.runAnalyses; % 25 Ds for V1-V3
    DIpsLate  = ccmIpsLate.runAnalyses; % 25 Ds for IPS
    DsPCSLate = ccmsPCSLate.runAnalyses; % 25 Ds for sPCS

    ResultsEarly{sub} = [DVcEarly ,DIpsEarly, DsPCSEarly ];
    ResultsLate{sub} = [DVcLate ,DIpsLate, DsPCSLate ];
   

end
