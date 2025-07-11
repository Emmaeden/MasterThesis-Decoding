%% run decoding analysis for 
clear all; close all;clc;

% add toolox and script folder

addpath('/disco/emma/matlabscripts/SeqWm/pSVR')
  
if isunix
     s.homeDIR = fullfile('disco','emma');
     cd /disco/emma
elseif ispc
     s.homeDIR = fullfile('Z:','emma');
     cd Z:\emma
end

%addpath(fullfile('matlabscripts','SeqWmRes')) % Data Dir



%% Options:
s.analysis.name = 'pSVR_SeqWm_New';

%% Parameters
s.subjNR   = 1:24;
s.tr       = 0.8;
s.preproc.n_voxel    = {1000,1000,1000,1000,1000};
s.preproc.average_TR = 5;
s.preproc.n_nodes    = 24;
s.preproc.n_fir      = 25;                                                    
       
% Analysis
s.analysis.n_fir  = 25;                                                    
s.analysis.ROI       = {'wV1-V3_Mask','wIPS_Mask','wsPCS_Mask'}; 

                                                                    
% Results
s.results.folder_name  = ['resR_', s.analysis.name];
       

% Get data
% Get data parameters 
 s.scratchDataDir =  fullfile('scratchData','SeqWM',['DETREND_', num2str(s.preproc.n_nodes)], ['TEMP_SMOOTHING_', num2str(s.preproc.average_TR),'TR']);
%s.scratchDataDir= fullfile('/disco/vivien/SeqWM/02_data/E_TMP/detrended_5TR_baseline');
%% get ROI
% parfor SUB = 1:numel(s.subjNR)
%     if SUB == 9
%         continue
%     else
%         i_SUB = SUB;
%         [data,regs] = get_ROI_dataupdatedEm(i_SUB,s);
%     end
% end
%% Run analysis


if strcmp(s.analysis.name, "pSVR_SeqWm_New")
   

    % Main analysis
    parfor SUB = 1:numel(s.subjNR)
         if SUB == 9
        continue
     else
        i_SUB =  SUB;
        pSVRSeqWmSep(i_SUB,s);
         end
        
    end
    clear SUB
   


end


