%% run decoding analysis for 
clear all;

addpath('/disco/emma/matlabscripts/MC01/pSVR')
  
if isunix
     s.homeDIR = fullfile('disco','emma');
     cd /disco/emma
elseif ispc
     s.homeDIR = fullfile('Z:','emma');
     cd Z:\emma
end

addpath(genpath(fullfile(s.homeDIR,'matlabscripts','MC01','pSVR')))


%addpath(fullfile('spm12'))
addpath(genpath(fullfile('tdt_3.999F')));

%% Options:
s.analysis.name = 'pSVR_MC01';

%% Parameters
s.subjNR   = 1:38;
s.tr       = 1.225;
s.preproc.n_voxel    = {1000,1000,1000,1000,1000};
s.preproc.average_TR = 0;
s.preproc.n_nodes    = 24;
s.preproc.n_fir      = 28;                                                    
       
% Analysis
s.analysis.n_fir  = 28;                                                    
s.analysis.ROI       = {'wVisual_Cortex_Mask','wIPS_Mask','wFEF_Mask'};            

                                                                    
% Results
s.results.folder_name  = ['res_', s.analysis.name];

% Get data parameters 
s.scratchDataDir =  fullfile('scratchData','MC01',['DETREND_', num2str(s.preproc.n_nodes)], ['TEMP_SMOOTHING_', num2str(s.preproc.average_TR),'TR']);
 
%% get ROI
% parfor SUB = 1:numel(s.subjNR)
%     if SUB == 14 || SUB == 20 
%         continue
%     else
%         i_SUB = SUB;
%         [data,regs] = get_ROI_data(i_SUB,s);
%     end
% end
%% Run analysis

if strcmp(s.analysis.name, "pSVR_mc01")
   

    % Main analysis
    for SUB = 1:numel(s.subjNR)
         if SUB == 14 || SUB == 20
        continue
     else
        i_SUB =  SUB;
        %pSVRmc01(i_SUB,s);
        pSVRmc01m(i_SUB,s);
         end
        
    end
    clear SUB
   


end


