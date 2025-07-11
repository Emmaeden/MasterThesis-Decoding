function data = moving_average(data, winsize)

% computes moving average across TRs. 
% INPUT:
%   data: [n_tr,n_vox,n_run] array with data
%   winsize: number of subsequent TRs to average (default: 3)

if ~exist('winsize','var') || isempty(winsize)
    winsize = 3;
end

step = winsize-1;

n_tr = size(data,1);

fprintf('Running moving average of size %d across %d TRs ...\n', winsize, n_tr);

for i_tr = 1:n_tr-step
    data(i_tr,:,:) = nanmean(data(i_tr:i_tr+step,:,:));
end
% remove unused last TRs
data(end-(step-1):end,:,:) = [];