% 11-14-19: change name from camera2frame_9mp_small_PL4 to f_camera2frame_9mp_small

% 09-26-19: first implementation based on camera2frame_9MP_small_PL3 (in FilterMeasurements folder)

function f_camera2frame_9mp_small (pathout, numberofshots, ol490, intensity, bandwidth, shutter_tbl, gain_tbl)

    % Capture an image with multispectral

    disp('Capturing frames with wavelength from 380 to 780 nm...')
    
    mkdir(pathout) %makes a new directory
    fnout_stack = sprintf('%s/img_stack',pathout); %stack output as "img_stack"
    fnout_m = sprintf('%s/vim_mean_array',pathout); %mean intensity output as "vim_mean_array"
    fnout_s = sprintf('%s/vim_std_array',pathout); %stdev of mean intensity output as "vim_std_array"
    fnout_max = sprintf('%s/max_array',pathout); %maximum intensity for each wavelength output as "max_array"
   
    fnout_bg_stack = sprintf('%s/img_background_stack',pathout); %background stack output as "img_background_stack"
    fnout_bg_m = sprintf('%s/vim_background_mean_array',pathout); %mean intensity background output as "vim_background_mean_array"
    fnout_bg_s = sprintf('%s/vim_background_std_array',pathout); %stdev of mean intensity background output as "vim_background_mean_array"
    
    % aqusition
    cam = CameraClass9MPSmall_PL2;
    
    % data storage -- initialize sizes of output arrays w/ zeros
    vim_mean_array = zeros(41,676,844);
    vim_std_array = zeros(41,676,844);
    max_array = zeros(41, 1);
    img_stack = zeros(41, 676, 844, numberofshots);
    
    vim_background_mean_array = zeros(41,676,844);
    vim_background_std_array = zeros(41,676,844);
    max_background_array = zeros(41, 1);
    img_background_stack = zeros(41, 676, 844, numberofshots);
    
    k = 1;
    for wl=380:10:780
            
        % Set the shutter time and gain
        cam.setShutter(shutter_tbl(k) );
        cam.setGain(gain_tbl(k) );
        
        % Prepare light
        disp(['Lambda = ' num2str(wl) ' On']);
        ol490.setPeak(wl,bandwidth,intensity(k, 1) );
        pause(1); % This deals with 07-1-2019 potential bug
        
        % acquisition
        [img_stack(k, :, :, :), ~, vim_mean_array(k,:,:), vim_std_array(k,:,:)] = cam.snap(numberofshots, 'tissue'); % With tissue option img_m = 0 x numberofshots, replaced by ~
        
        % Max of image to track saturation
        max_array(k, 1) = max(max(max(img_stack(k, :, :, :))));
        disp(['Max count = ' num2str(max_array(k, 1))]);
        
        % Prepare light
        disp(['Lambda = ' num2str(wl) ' Off']);
        ol490.setPeak(wl,bandwidth,0 );
        pause(1); % This deals with 07-1-2019 potential bug
        
        % acquisition
        [img_background_stack(k, :, :, :), ~, vim_background_mean_array(k,:,:), vim_background_std_array(k,:,:)] = cam.snap(numberofshots, 'tissue');  % With tissue option img_m = 0 x numberofshots, replaced by ~
        
        % Max of image to track saturation
        max_background_array(k, 1) = max(max(max(img_background_stack(k, :, :, :))));
        disp(['Max background count = ' num2str(max_background_array(k, 1))]);
        k = k + 1;
    end
    
    % exit
    cam.close;
    
    % Save data after closing devices
    % Normal
    disp('Saving images stack...');
    save(fnout_stack,'img_stack','-V7.3');
    
    disp('Saving captured frames in vim_mean_array...');
    save(fnout_m,'vim_mean_array','-V7.3');
    
    disp('Saving the max array to check for saturation...');
    save(fnout_max,'max_array');
    
    disp(['Max count total = ' num2str(max(max_array))]);
    
    % Background
    disp('Saving background images stack...');
    save(fnout_bg_stack,'img_background_stack','-V7.3');
    
    disp('Saving captured frames in vim_background_mean_array...');
    save(fnout_bg_m,'vim_background_mean_array','-V7.3');
    
    % If uncertainty analysis, i.e. numberofshots not 1
    if ~isequal(numberofshots, 1)
        disp('Saving captured frames in vim_std_array...');
        save(fnout_s,'vim_std_array','-V7.3');
        disp('Saving captured frames in vim_background_std_array...');
        save(fnout_bg_s,'vim_background_std_array','-V7.3');
    end
   
    % Back to 550nm, full intensity
    ol490.setPeak(550,bandwidth,100)

return

end