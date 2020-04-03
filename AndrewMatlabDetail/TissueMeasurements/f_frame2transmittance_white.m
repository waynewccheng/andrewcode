% 112-14-19: Change name from frame2transmittance_white_PL5 to
% f_frame2transmittance_white

% 09-26-19: first implementation based on frame2transmittance_white_PL4 (in FilterMeasurements folder)
% Removes the computation of the spatial average on the images, irrelevant
% for tissues

function [trans_array_m, trans_array_s, sizey, sizex] = f_frame2transmittance_white(foldername_sample, foldername_white, nshots) %call your file locations and number of shots

    disp('Combining frames into transmittance...')

    % Load images mean values for the 100% transmittance
    fnin_m = sprintf('%s/vim_mean_array',foldername_white);
    load(fnin_m,'vim_mean_array'); %load data from mean intensity stack (white images)
    fnin_m = sprintf('%s/vim_background_mean_array',foldername_white);
    load(fnin_m,'vim_background_mean_array'); %load data from background mean intensity stack (white images)
    
    % Load images std values for the 100% transmittance
    if ~isequal(nshots, 1)
        fnin_s = sprintf('%s/vim_background_std_array',foldername_white);
        load(fnin_s,'vim_background_std_array'); %load data from background standard deviation stack (white images)
        fnin_s = sprintf('%s/vim_std_array',foldername_white);
        load(fnin_s,'vim_std_array'); %load data from standard deviation stack (white images)
    end
    
    % Copy to vim_mean_array_w, vim_background_mean_array_w to save them and get dimensions
    vim_mean_array_w = vim_mean_array;
    vim_background_mean_array_w = vim_background_mean_array;
    [sizewl sizey sizex] = size(vim_mean_array_w); %get the dimensions of the arrays -- wl, y, and x from the loaded images
    
    % Copy to vim_std_array_w, vim_background_std_array_w to save them 
    if ~isequal(nshots, 1) % if the number of shots is not equal to 1, copy the std arrays
        vim_std_array_w = vim_std_array;
        vim_background_std_array_w = vim_background_std_array;
    end
    
    % Load images mean values for the sample
    fnin_m = sprintf('%s/vim_mean_array',foldername_sample);
    load(fnin_m,'vim_mean_array'); %load data from mean intensity stack (sample images)
    fnin_m = sprintf('%s/vim_background_mean_array',foldername_sample);
    load(fnin_m,'vim_background_mean_array');  %load data from background mean intensity stack (sample images)
    
    % Load images std values for the sample
    if ~isequal(nshots, 1)
        fnin_s = sprintf('%s/vim_std_array',foldername_sample);
        load(fnin_s,'vim_std_array'); %load data from background standard deviation stack (sample images)
        fnin_s = sprintf('%s/vim_background_std_array',foldername_sample);
        load(fnin_s,'vim_background_std_array'); %load data from standard deviation stack (sample images)
    end

    % Calculate the reflectance
    % Mean
    %reshape 3D matrices into 2D (#wavelengths x pixelcount_x*pixelcount_y)
    ddl_array_m = reshape(vim_mean_array, sizewl, sizey*sizex); 
    ddl_white_array_m = reshape(vim_mean_array_w, sizewl, sizey*sizex);
    ddl_background_array_m = reshape(vim_background_mean_array, sizewl, sizey*sizex);
    ddl_background_white_array_m = reshape(vim_background_mean_array_w, sizewl, sizey*sizex);
    
    if ~isequal(nshots, 1)
        %if nshots is not equal to 1...
        %reshape 3D matrices into 2D (#wavelengths x pixelcount_x*pixelcount_y)
        % Std
        ddl_array_s = reshape(vim_std_array, sizewl, sizey*sizex);
        ddl_white_array_s = reshape(vim_std_array_w, sizewl,sizey*sizex);
        ddl_background_array_s = reshape(vim_background_std_array, sizewl, sizey*sizex);
        ddl_background_white_array_s = reshape(vim_background_std_array_w, sizewl,sizey*sizex);
        
        % Transmittance calculation -- call f_transmittance function
        % Write mean and std dev into trans_array_m and trans_array_s
        [trans_array_m , trans_array_s] = f_transmittance(ddl_array_m, ddl_white_array_m,...
            ddl_background_array_m, ddl_background_white_array_m,...
            ddl_array_s, ddl_white_array_s,...
            ddl_background_array_s, ddl_background_white_array_s);
    
    else %(if nshots is equal to 1, there is no stdev)
        % Transmittance, mean (std dev is empty)
        [trans_array_m , trans_array_s] = f_transmittance(ddl_array_m, ddl_white_array_m,...
            ddl_background_array_m, ddl_background_white_array_m);
    end
 
    return
    

end
