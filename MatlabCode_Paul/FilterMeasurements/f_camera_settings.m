function [shutter_tbl, gain_tbl] = f_camera_settings(ol490, bandwidth, p_val, mode)
    % Establishes/get the maximum shutter time, spanning the wavelengths
    
    if strcmp(mode, 'w')
        % Steps 1sec (mode = 1)
        [shutter_tbl, gain_tbl] = f_shutter_gain_cam(ol490, bandwidth, 0, 0, 1);
        
        % Refine step 0.1sec (mode = 2)
        [shutter_tbl, gain_tbl] = f_shutter_gain_cam(ol490, bandwidth, shutter_tbl(:, 2), gain_tbl(:, 2), 2);
        
        % Refine step 0.01sec (mode = 3)
        [shutter_tbl, gain_tbl] = f_shutter_gain_cam(ol490, bandwidth, shutter_tbl(:, 2), gain_tbl(:, 2), 3);
        
        % Returns to this code folder to save the shutter times and gain
        % value
        save([p_val '\Shutter_tbl'] ,'shutter_tbl');
        save([p_val '\Gain_tbl'] ,'gain_tbl');
        
    elseif strcmp(mode, 'r')
        % Get the shutter time and gain values
        load([p_val '\Shutter_tbl'],'shutter_tbl');
        load([p_val '\Gain_tbl'],'gain_tbl');
    end

end

