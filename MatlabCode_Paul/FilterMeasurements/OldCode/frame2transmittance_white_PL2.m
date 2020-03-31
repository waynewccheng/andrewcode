% 08-19-19
% Measurements of the light background taken into account

% 7-30-2015
% convert frames (DDL) to transmittance by using reference white background
%

% function [transmittance_array, sizey, sizex] = frame2transmittance_white_PL (foldername_sample, foldername_white, nshots)
function [trans_ms, trans_array_m, trans_array_s, sizey, sizex] = frame2transmittance_white_PL2(foldername_sample, foldername_white, foldername_black, nshots)

    % Formulas
    % trans_mean = @(a_m, b_m) a_m ./ b_m;
    % trans_std = @(a_m, b_m, a_s, b_s) sqrt((1./b_m).^2.* a_s.^2 + (a_m./b_m.^2).^2.*b_s.^2);
    trans_mean = @(s_m, w_m, b_m) (s_m - b_m)./ (w_m - b_m);
    trans_std = @(s_m, w_m, b_m, s_s, w_s, b_s) ...
        sqrt((1./(w_m-b_m)).^2 .* s_s.^2 + ...
        ((s_m - w_m)./(w_m-b_m).^2).^2 .* b_s.^2 + ...
        ((b_m - s_m)./(w_m-b_m).^2).^2 .* w_s.^2);

    % Compute the spatial + temporal mean and std dev
    
    disp('Combining spatial + temporal mean and std dev into transmittance...')
    
    % 100% transmittance
    fnin = sprintf('%s/img_ms',foldername_white);
    load(fnin,'img_ms');
    
    % Copy
    img_ms_w = img_ms;
    
    % 0% transmittance
    fnin = sprintf('%s/img_ms',foldername_black);
    load(fnin,'img_ms');
    
    % Copy
    img_ms_b = img_ms;
    
    % Sample transmittance
    fnin = sprintf('%s/img_ms',foldername_sample);
    load(fnin,'img_ms');
    
    % Transmittance
    trans_ms(:, 1) = img_ms(:, 1);
%     trans_ms(:, 2) = trans_mean(img_ms(:, 2), img_ms_w(:, 2) );
%     trans_ms(:, 3) = trans_std(img_ms(:, 2), img_ms_w(:, 2) , img_ms(:, 3), img_ms_w(:, 3) );
    [trans_ms(:, 2), trans_ms(:, 3)] = f_transmittance(img_ms(:, 2), img_ms_w(:, 2), img_ms_b(:, 2), img_ms(:, 3), img_ms_w(:, 3), img_ms_b(:, 3));
    f_transmittance_PL2(s_m, w_m, b_m, s_bg_m, w_bg_m, s_s, w_s, b_s, s_bg_s, w_bg_s)
    
%     trans_ms(:, 2) = trans_mean(img_ms(:, 2), img_ms_w(:, 2), img_ms_b(:, 2));
%     trans_ms(:, 3) = trans_std(img_ms(:, 2), img_ms_w(:, 2), img_ms_b(:, 2), img_ms(:, 3), img_ms_w(:, 3), img_ms_b(:, 3));
    
    disp('Combining frames into transmittance...')

    % save(fnout_s,'vim_std_array','-V7.3')

    % Load images mean values for the 100% transmittance
    % fnin_m = sprintf('%s/vim_mean_array',foldername_white);
    % load(fnin_m,'vim_mean_array');

    fnin_m = sprintf('%s/vim_mean_array',foldername_white);
    load(fnin_m,'vim_mean_array');
    fnin_s = sprintf('%s/vim_std_array',foldername_white);
    load(fnin_s,'vim_std_array');

    % Copy to vim_mean_array_w, to save it and get dimensions
    vim_mean_array_w = vim_mean_array;
    vim_std_array_w = vim_std_array;

    [sizewl sizey sizex] = size(vim_mean_array_w);
    
    % Load images mean values for the 0% transmittance
    fnin_m = sprintf('%s/vim_mean_array',foldername_black);
    load(fnin_m,'vim_mean_array');
    fnin_s = sprintf('%s/vim_std_array',foldername_black);
    load(fnin_s,'vim_std_array');

    % Copy to vim_mean_array_b
    vim_mean_array_b = vim_mean_array;
    vim_std_array_b = vim_std_array;

    % Load images mean values for the sample
    fnin_m = sprintf('%s/vim_mean_array',foldername_sample);
    load(fnin_m,'vim_mean_array');
    fnin_s = sprintf('%s/vim_std_array',foldername_sample);
    load(fnin_s,'vim_std_array');

    %     % calculate the reflectance
    %     ddl_array = reshape(vim_mean_array,sizewl,sizey*sizex);
    %     ddl_white_array = reshape(vim_mean_array_w,sizewl,sizey*sizex);
    %
    %     transmittance_array = ddl_array ./ ddl_white_array;
    %

    % calculate the reflectance
    ddl_array_m = reshape(vim_mean_array, sizewl, sizey*sizex);
    ddl_white_array_m = reshape(vim_mean_array_w, sizewl, sizey*sizex);
    ddl_black_array_m = reshape(vim_mean_array_b, sizewl, sizey*sizex);
    
    ddl_array_s = reshape(vim_std_array, sizewl, sizey*sizex);
    ddl_white_array_s = reshape(vim_std_array_w, sizewl,sizey*sizex);
    ddl_black_array_s = reshape(vim_std_array_b, sizewl, sizey*sizex);
    
    % trans_array_m = trans_mean(ddl_array_m, ddl_white_array_m);
    % trans_array_s = trans_std(ddl_array_m, ddl_white_array_m, ddl_array_s, ddl_white_array_s);
%     trans_array_m = trans_mean(ddl_array_m, ddl_white_array_m, ddl_black_array_m);
%     trans_array_s = trans_std(ddl_array_m, ddl_white_array_m, ddl_black_array_m, ddl_array_s, ddl_white_array_s, ddl_black_array_s);
    [trans_array_m , trans_array_s] = f_transmittance(ddl_array_m, ddl_white_array_m, ddl_black_array_m, ddl_array_s, ddl_white_array_s, ddl_black_array_s)
    
    %     % This take the minimum element between transmittance_array and 1, i.e.
    %     % limits the max transmittance value to 1
    %     transmittance_array = min(transmittance_array,1);

    % ----------------------------------
    return
end
