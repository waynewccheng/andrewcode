% 112-14-19: Change name from frame2transmittance_white_PL5 to
% f_frame2transmittance_white

% 09-26-19: first implementation based on frame2transmittance_white_PL4 (in FilterMeasurements folder)
% Removes the computation of the spatial average on the images, irrelevant
% for tissues

function [trans_array_m, trans_array_s, sizey, sizex] = frame2transmittance_white_PL5(foldername_sample, foldername_white, nshots)

    disp('Combining frames into transmittance...')

    % Load images mean values for the 100% transmittance
    fnin_m = sprintf('%s/vim_mean_array',foldername_white);
    load(fnin_m,'vim_mean_array');
    fnin_s = sprintf('%s/vim_std_array',foldername_white);
    load(fnin_s,'vim_std_array');

    fnin_m = sprintf('%s/vim_background_mean_array',foldername_white);
    load(fnin_m,'vim_background_mean_array');
    fnin_s = sprintf('%s/vim_background_std_array',foldername_white);
    load(fnin_s,'vim_background_std_array');
    
    % Copy to vim_mean_array_w, to save it and get dimensions
    vim_mean_array_w = vim_mean_array;
    vim_std_array_w = vim_std_array;
    vim_background_mean_array_w = vim_background_mean_array;
    vim_background_std_array_w = vim_background_std_array;
    [sizewl sizey sizex] = size(vim_mean_array_w);
    
    % Load images mean values for the sample
    fnin_m = sprintf('%s/vim_mean_array',foldername_sample);
    load(fnin_m,'vim_mean_array');
    fnin_s = sprintf('%s/vim_std_array',foldername_sample);
    load(fnin_s,'vim_std_array');

    fnin_m = sprintf('%s/vim_background_mean_array',foldername_sample);
    load(fnin_m,'vim_background_mean_array');
    fnin_s = sprintf('%s/vim_background_std_array',foldername_sample);
    load(fnin_s,'vim_background_std_array');

    % Calculate the reflectance
    ddl_array_m = reshape(vim_mean_array, sizewl, sizey*sizex);
    ddl_white_array_m = reshape(vim_mean_array_w, sizewl, sizey*sizex);

    ddl_background_array_m = reshape(vim_background_mean_array, sizewl, sizey*sizex);
    ddl_background_white_array_m = reshape(vim_background_mean_array_w, sizewl, sizey*sizex);
    
    ddl_array_s = reshape(vim_std_array, sizewl, sizey*sizex);
    ddl_white_array_s = reshape(vim_std_array_w, sizewl,sizey*sizex);
    ddl_background_array_s = reshape(vim_background_std_array, sizewl, sizey*sizex);
    ddl_background_white_array_s = reshape(vim_background_std_array_w, sizewl,sizey*sizex);
    
    [trans_array_m , trans_array_s] = f_transmittance_PL3(ddl_array_m, ddl_white_array_m,...
        ddl_background_array_m, ddl_background_white_array_m,...
        ddl_array_s, ddl_white_array_s,...
        ddl_background_array_s, ddl_background_white_array_s);
    
    %     % This take the minimum element between transmittance_array and 1, i.e.
    %     % limits the max transmittance value to 1
    %     transmittance_array = min(transmittance_array,1);

    % ----------------------------------
    return
end
