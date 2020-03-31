% 112-14-19: Change name from frame2transmittance_white_PL5 to
% f_frame2transmittance_white

% 09-26-19: first implementation based on frame2transmittance_white_PL4 (in FilterMeasurements folder)
% Removes the computation of the spatial average on the images, irrelevant
% for tissues

function [trans_array_m, trans_array_s, sizey, sizex] = f_frame2transmittance_white(foldername_sample, foldername_white, nshots)

    disp('Combining frames into transmittance...')

    % Load images mean values for the 100% transmittance
    fnin_m = sprintf('%s/vim_mean_array',foldername_white);
    load(fnin_m,'vim_mean_array');
    fnin_m = sprintf('%s/vim_background_mean_array',foldername_white);
    load(fnin_m,'vim_background_mean_array');
    
    % Load images std values for the 100% transmittance
    if ~isequal(nshots, 1)
        fnin_s = sprintf('%s/vim_background_std_array',foldername_white);
        load(fnin_s,'vim_background_std_array');
        fnin_s = sprintf('%s/vim_std_array',foldername_white);
        load(fnin_s,'vim_std_array');
    end
    
    % Copy to vim_mean_array_w, vim_background_mean_array_w to save them and get dimensions
    vim_mean_array_w = vim_mean_array;
    vim_background_mean_array_w = vim_background_mean_array;
    [sizewl sizey sizex] = size(vim_mean_array_w);
    
    % Copy to vim_std_array_w, vim_background_std_array_w to save them 
    if ~isequal(nshots, 1)
        vim_std_array_w = vim_std_array;
        vim_background_std_array_w = vim_background_std_array;
    end
    
    % Load images mean values for the sample
    fnin_m = sprintf('%s/vim_mean_array',foldername_sample);
    load(fnin_m,'vim_mean_array');
    fnin_m = sprintf('%s/vim_background_mean_array',foldername_sample);
    load(fnin_m,'vim_background_mean_array');
    
    % Load images std values for the sample
    if ~isequal(nshots, 1)
        fnin_s = sprintf('%s/vim_std_array',foldername_sample);
        load(fnin_s,'vim_std_array');
        fnin_s = sprintf('%s/vim_background_std_array',foldername_sample);
        load(fnin_s,'vim_background_std_array');
    end

    % Calculate the reflectance
    % Mean
    ddl_array_m = reshape(vim_mean_array, sizewl, sizey*sizex);
    ddl_white_array_m = reshape(vim_mean_array_w, sizewl, sizey*sizex);
    ddl_background_array_m = reshape(vim_background_mean_array, sizewl, sizey*sizex);
    ddl_background_white_array_m = reshape(vim_background_mean_array_w, sizewl, sizey*sizex);
    
    if ~isequal(nshots, 1)
        % Std
        ddl_array_s = reshape(vim_std_array, sizewl, sizey*sizex);
        ddl_white_array_s = reshape(vim_std_array_w, sizewl,sizey*sizex);
        ddl_background_array_s = reshape(vim_background_std_array, sizewl, sizey*sizex);
        ddl_background_white_array_s = reshape(vim_background_std_array_w, sizewl,sizey*sizex);
        
        % Transmittance, mean and std dev
        [trans_array_m , trans_array_s] = f_transmittance(ddl_array_m, ddl_white_array_m,...
            ddl_background_array_m, ddl_background_white_array_m,...
            ddl_array_s, ddl_white_array_s,...
            ddl_background_array_s, ddl_background_white_array_s);
    else
        % Transmittance, mean (std dev is empty)
        [trans_array_m , trans_array_s] = f_transmittance(ddl_array_m, ddl_white_array_m,...
            ddl_background_array_m, ddl_background_white_array_m);
    end
    
    return
    
end
