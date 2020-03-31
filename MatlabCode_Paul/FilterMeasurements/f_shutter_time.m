function shutter_tbl = f_shutter_time(ol490, bandwidth, p_val, mode)
    % Establishes/get the maximum shutter time, spanning the wavelengths
    
    if mode ~=0
        % Steps 1sec (mode = 1)
        shutter_tbl = f_shutter_cam(ol490, bandwidth, 0, 1);
        
        % Refine step 0.1sec (mode = 2)
        shutter_tbl = f_shutter_cam(ol490, bandwidth, shutter_tbl(:, 2), 2);
        
        % Refine step 0.01sec (mode = 3)
        shutter_tbl = f_shutter_cam(ol490, bandwidth, shutter_tbl(:, 2), 3);
        
        % Returns to this code folder to save the shutter times
        save([p_val '\Shutter_tbl'] ,'shutter_tbl');
    else
        % Get the shutter values
        load([p_val '\Shutter_tbl'],'shutter_tbl');
    end

end

