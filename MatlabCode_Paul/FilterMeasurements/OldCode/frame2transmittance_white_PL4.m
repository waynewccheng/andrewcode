% 11-19-19: change name from frame2transmittance_white_PL4 to
% f_frame2transmittance_white_filter

% 08-20-19
% No black tape measurements

% 08-19-19
% Measurements of the light background taken into account

% 7-30-2015
% convert frames (DDL) to transmittance by using reference white background
%

% function [trans_ms, trans_array_m, trans_array_s, sizey, sizex] = frame2transmittance_white_PL4(foldername_sample, foldername_white, nshots)
function [trans_ms, trans_array_m, trans_array_s, sizey, sizex] = frame2transmittance_white_PL4(foldername_sample, foldername_white, nshots, splt_type)
    
    if strcmp(splt_type, 'filter')
        % Compute the spatial + temporal mean and std dev

        disp('Combining spatial + temporal mean and std dev into transmittance...')

        % 100% transmittance
        fnin = sprintf('%s/img_ms',foldername_white);
        load(fnin,'img_ms');
        fnin = sprintf('%s/img_background_ms',foldername_white);
        load(fnin,'img_background_ms');

        % Copy
        img_ms_w = img_ms;
        img_background_ms_w = img_background_ms;

        % Sample transmittance
        fnin = sprintf('%s/img_ms',foldername_sample);
        load(fnin,'img_ms');
        fnin = sprintf('%s/img_background_ms',foldername_sample);
        load(fnin,'img_background_ms');


        % Transmittance
        trans_ms(:, 1) = img_ms(:, 1);
        if ~isequal(nshots, 1)
            %         [trans_ms(:, 2), trans_ms(:, 3)] = f_transmittance_PL3(img_ms(:, 2), img_ms_w(:, 2), ...
            %             img_background_ms(:, 2), img_background_ms_w(:, 2),...
            %             img_ms(:, 3), img_ms_w(:, 3),...
            %             img_background_ms(:, 3), img_background_ms_w(:, 3));
            [trans_ms(:, 2), trans_ms(:, 3)] = f_transmittance(img_ms(:, 2), img_ms_w(:, 2), ...
                img_background_ms(:, 2), img_background_ms_w(:, 2),...
                img_ms(:, 3), img_ms_w(:, 3),...
                img_background_ms(:, 3), img_background_ms_w(:, 3));
        else
            [trans_ms(:, 2), ~ ] = f_transmittance(img_ms(:, 2), img_ms_w(:, 2), ...
                img_background_ms(:, 2), img_background_ms_w(:, 2));
        end
    else
        trans_ms = [];
    end

    disp('Combining frames into transmittance...')

    % Load images mean values for the 100% transmittance
    fnin_m = sprintf('%s/vim_mean_array',foldername_white);
    load(fnin_m,'vim_mean_array');
    fnin_m = sprintf('%s/vim_background_mean_array',foldername_white);
    load(fnin_m,'vim_background_mean_array');
    
    % Load images std values for the 100% transmittance
    if ~isequal(nshots, 1)
        fnin_s = sprintf('%s/vim_std_array',foldername_white);
        load(fnin_s,'vim_std_array');
        fnin_s = sprintf('%s/vim_background_std_array',foldername_white);
        load(fnin_s,'vim_background_std_array');
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
        
        %     [trans_array_m , trans_array_s] = f_transmittance_PL3(ddl_array_m, ddl_white_array_m,...
        %         ddl_background_array_m, ddl_background_white_array_m,...
        %         ddl_array_s, ddl_white_array_s,...
        %         ddl_background_array_s, ddl_background_white_array_s);
        [trans_array_m , trans_array_s] = f_transmittance(ddl_array_m, ddl_white_array_m,...
            ddl_background_array_m, ddl_background_white_array_m,...
            ddl_array_s, ddl_white_array_s,...
            ddl_background_array_s, ddl_background_white_array_s);
    else
        [trans_array_m , trans_array_s] = f_transmittance(ddl_array_m, ddl_white_array_m,...
            ddl_background_array_m, ddl_background_white_array_m);
    end
    
    %     % This take the minimum element between transmittance_array and 1, i.e.
    %     % limits the max transmittance value to 1
    %     transmittance_array = min(transmittance_array,1);

    % ----------------------------------
    return
end
