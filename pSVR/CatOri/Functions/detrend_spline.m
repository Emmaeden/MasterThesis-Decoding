function data = detrend_spline(data, n_nodes, par)

% spline-detrending of data
% INPUT:
%   data: [n_tr,n_vox,n_run] array with data
%   n_nodes: number of nodes for spline fitting (recommended: trials/2)


n_tr = size(data,1);
n_vox = size(data,2);
n_run = size(data,3);

x_n = round(linspace(1,n_tr,n_nodes));
edge = floor(max(diff(x_n))/2);

for i_run = 1:n_run
    
    fprintf('Detrending voxels of run %d/%d ...\n', i_run, n_run);
    
    if exist('par','var') && par == 1
        parfor i_vox = 1:n_vox
            
            v = data(:,i_vox,i_run);
            
            y_n = zeros(1,n_nodes);
            
            for i_n = 1:n_nodes
                i_neg = x_n(i_n)-edge;
                i_pos = x_n(i_n)+edge;
                
                if i_neg<1, i_neg=1; end
                if i_pos>n_tr, i_pos=n_tr; end
                
                y_n(i_n) = mean(v(i_neg:i_pos));
            end
            
            y = spline(x_n,y_n,1:n_tr);
            
            v_new = v-y';
            
            data(:,i_vox,i_run) = v_new;
        end
    else
        for i_vox = 1:n_vox
            v = data(:,i_vox,i_run);
            y_n = zeros(1,n_nodes);
            for i_n = 1:n_nodes
                i_neg = x_n(i_n)-edge;
                i_pos = x_n(i_n)+edge;
                if i_neg<1, i_neg=1; end
                if i_pos>n_tr, i_pos=n_tr; end
                y_n(i_n) = mean(v(i_neg:i_pos));
            end
            y = spline(x_n,y_n,1:n_tr);
            v_new = v-y';
            data(:,i_vox,i_run) = v_new;
        end
    end
    
end