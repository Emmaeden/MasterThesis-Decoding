%% run decoding analysis for 
clear all; close all;clc;

% add toolox and script folder

addpath('/disco/emma/matlabscripts/CatOri/pSVR')
  
if isunix
     s.homeDIR = fullfile('disco','emma');
     cd /disco/emma
elseif ispc
     s.homeDIR = fullfile('Z:','emma');
     cd Z:\emma
end

addpath(fullfile('CvmRes_CatOri')) % Data Dir



%% Options:
s.analysis.name = 'pSVR_CatOri';

%% Parameters
s.subjNR   = 1:45;
s.tr       = 0.8;
s.preproc.n_voxel    = {1000,1000,1000,1000,1000};
s.preproc.average_TR = 5;
s.preproc.n_nodes    = 24;
s.preproc.n_fir      = 26;                                                    
       
% Analysis
s.analysis.n_fir  = 26;                                                    
s.analysis.ROI       = {'wVisual_Cortex_Mask','wIPS_Mask','wFEF_Mask'};            

                                                                    
% Results
s.results.folder_name  = ['res_', s.analysis.name];

% Get data parameters 
s.scratchDataDir =  fullfile('scratchData','Cat_Ori',['DETREND_', num2str(s.preproc.n_nodes)], ['TEMP_SMOOTHING_', num2str(s.preproc.average_TR),'TR']);
 
% % get ROI
% parfor SUB = 1:numel(s.subjNR)
%     if SUB == 14 || SUB == 15 || SUB == 20 || SUB == 25 || SUB == 36
%         continue
%     else
%         i_SUB = SUB;
%         [data,regs] = get_ROI_data(i_SUB,s);
%     end
% end
%% Run analysis

if strcmp(s.analysis.name, "pSVR_CatOri")
   

    % Main analysis
    for SUB =1: numel(s.subjNR)
         if SUB == 14 || SUB == 15 || SUB == 20 || SUB == 25 || SUB == 28 || SUB == 36
        continue
     else
        i_SUB =  SUB;  
        pSVRcatOri(i_SUB,s);
         end
        
    end
    clear SUB
   


end


