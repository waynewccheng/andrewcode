% 08-06-2019: Save whole imag stack, compute max count using the whole
% stack

% 07-12-2019: Potential bug:
% in img_m, for the white measurement at 380, the image is saturated for the first snap but
% not for the other ones; neither is it for the sample or black measurement
% I put a pause(1) to deal with this

% 07-12-2019: Modified to allow multiple frame acquisition to compute
% mean value of intensity of each pixel + std deviation
% output:   vim_mean_array(41, 676, 844)
%           vim_std_array(41, 676, 844)
%           max_array(41, 1)
%           img_spatial_mean(41, 12)
%           img_ms(41, 3)

% 10-9-2015
% example: ol490 = OL490Class; camera2frame('dataout/1009-test1',1,ol490)

% 8-3-2015: hardware trigger; needs software reset!

% 7-23-2015: replace grasshopper function with camera_*
% usage: camera2frame('0723-7')

% 7-21-2015: revisit
% capture images with camera
% capture 41 images from 380 to 780
% output: vimarray(41,480,640)  

% function camera2frame_9mp_small_PL3 (pathout, numberofshots, ol490, intensity, bandwidth, shutter_tbl)
function camera2frame_9mp_small_PL3 (pathout, numberofshots, ol490, intensity, bandwidth, shutter_tbl, gain_tbl, spl_type)
% capture an image with multispectral

    disp('Capturing frames with wavelength from 380 to 780 nm...')
    
    mkdir(pathout)
    fnout_stack = sprintf('%s/img_stack',pathout);
    fnout_m = sprintf('%s/vim_mean_array',pathout);
    fnout_s = sprintf('%s/vim_std_array',pathout);
    fnout_max = sprintf('%s/max_array',pathout);

    fnout_bg_stack = sprintf('%s/img_background_stack',pathout);
    fnout_bg_m = sprintf('%s/vim_background_mean_array',pathout);
    fnout_bg_s = sprintf('%s/vim_background_std_array',pathout);
    
    if strcmp(splt_type, 'filter')
        fnout_img_ms = sprintf('%s/img_ms',pathout);
        fnout_img_sptm = sprintf('%s/img_spatial_mean',pathout);
        fnout_bg_img_ms = sprintf('%s/img_background_ms',pathout);
        fnout_bg_img_sptm = sprintf('%s/img_background_spatial_mean',pathout);
    end
    
    % acquisition
    cam = CameraClass9MPSmall_PL2
    
    % data storage
    vim_mean_array = zeros(41,676,844);
    vim_std_array = zeros(41,676,844);
    max_array = zeros(41, 1);
    img_stack = zeros(41, 676, 844, numberofshots);
    
    vim_background_mean_array = zeros(41,676,844);
    vim_background_std_array = zeros(41,676,844);
    max_background_array = zeros(41, 1);
    img_background_stack = zeros(41, 676, 844, numberofshots);
    
    if strcmp(splt_type, 'filter')
        img_spatial_mean = zeros(41, 1 + numberofshots);
        img_ms = zeros(41, 3);
        img_background_spatial_mean = zeros(41, 1 + numberofshots);
        img_background_ms = zeros(41, 3);
    end
    
    k = 1;
    for wl=380:10:780
            
%         % Set the shutter time
%         cam.setShutter(shutter_tbl(k));
%         
        % Set the shutter time and gain
        cam.setShutter(shutter_tbl(k) );
        cam.setGain(gain_tbl(k) );
     
        % Prepare light
        disp(['Lambda = ' num2str(wl) ' On']);
        ol490.setPeak(wl,bandwidth,intensity(k, 1) );
        pause(1); % This deals with 07-1-2019 potential bug
        
        % acquisition
%         [img_stack(k, :, :, :), img_m, vim_mean_array(k,:,:), vim_std_array(k,:,:)] = cam.snap(numberofshots, 'filter');
        [img_stack(k, :, :, :), img_m, vim_mean_array(k,:,:), vim_std_array(k,:,:)] = cam.snap(numberofshots, spl_type);
        
        % Max of image to track saturation
        max_array(k, 1) = max(max(max(img_stack(k, :, :, :))));
        disp(['Max count = ' num2str(max_array(k, 1))]);
        
        if strcmp(splt_type, 'filter')
            % Store spatial mean at each wavelength
            img_spatial_mean(k, 1) = wl;
            img_spatial_mean(k, 2:numberofshots+1) = img_m;
            
            % Store temporal mean of spatial means at each wavelength
            img_ms(k, 1) = wl;
            img_ms(k, 2) = mean(img_m);
            img_ms(k, 3) = std(img_m)./sqrt(numberofshots);
        end
        
        % Prepare light
        disp(['Lambda = ' num2str(wl) ' Off']);
        ol490.setPeak(wl,bandwidth,0 );
        pause(1); % This deals with 07-1-2019 potential bug
        
        % acquisition
%         [img_background_stack(k, :, :, :), img_background_m, vim_background_mean_array(k,:,:), vim_background_std_array(k,:,:)] = cam.snap(numberofshots, 'filter');
        [img_background_stack(k, :, :, :), img_background_m, vim_background_mean_array(k,:,:), vim_background_std_array(k,:,:)] = cam.snap(numberofshots, spl_type);
        
        % Max of image to track saturation
        max_background_array(k, 1) = max(max(max(img_background_stack(k, :, :, :))));
        disp(['Max background count = ' num2str(max_background_array(k, 1))]);
        
        if strcmp(splt_type, 'filter')
            % Store spatial mean at each wavelength
            img_background_spatial_mean(k, 1) = wl;
            img_background_spatial_mean(k, 2:numberofshots+1) = img_background_m;
            
            % Store temporal mean of spatial means at each wavelength
            img_background_ms(k, 1) = wl;
            img_background_ms(k, 2) = mean(img_background_m);
            img_background_ms(k, 3) = std(img_background_m)./sqrt(numberofshots);
        end
        
        k = k + 1;
    end
    
    % exit
    cam.close;

    beep
    
    % Save data after closing devices
    % Normal
    disp('Saving images stack...');
    save(fnout_stack,'img_stack','-V7.3');
    
%     disp('Saving captured frames in vim_mean_array and vim_std_array...');
    disp('Saving captured frames in vim_mean_array...');
    save(fnout_m,'vim_mean_array','-V7.3');
%     save(fnout_s,'vim_std_array','-V7.3');
    
    disp('Saving the max array to check for saturation...');
    save(fnout_max,'max_array');
    
%     disp('Saving the spatial average for each snapshot...');
%     save(fnout_img_sptm,'img_spatial_mean');
    
%     disp('Saving the temporal mean and std dev of the spatial averages...');
%     save(fnout_img_ms,'img_ms');
    
    disp(['Max count total = ' num2str(max(max_array))]);
    
    % Background
    disp('Saving background images stack...');
    save(fnout_bg_stack,'img_background_stack','-V7.3');
    
%     disp('Saving captured frames in vim_background_mean_array and vim_background_std_array...');
    disp('Saving captured frames in vim_background_mean_array...');
    save(fnout_bg_m,'vim_background_mean_array','-V7.3');
%     save(fnout_bg_s,'vim_background_std_array','-V7.3');
    
%     disp('Saving the spatial average of background for each snapshot...');
%     save(fnout_bg_img_sptm,'img_background_spatial_mean');
%     
%     disp('Saving the temporal mean and std dev of the spatial averages, background...');
%     save(fnout_bg_img_ms,'img_background_ms');
   
    % If uncertainty analysis, i.e. numberofshots not 1
    if ~isequal(numberofshots, 1)
        disp('Saving captured frames in vim_std_array...');
        save(fnout_s,'vim_std_array','-V7.3');
        disp('Saving captured frames in vim_background_std_array...');
        save(fnout_bg_s,'vim_background_std_array','-V7.3');
    end

    % If the sample is spatially uniform, i.e. a filter
    if strcmp(splt_type, 'filter')
        disp('Saving the spatial average for each snapshot...');
        save(fnout_img_sptm,'img_spatial_mean');
        
        disp('Saving the temporal mean and std dev of the spatial averages...');
        save(fnout_img_ms,'img_ms');
        
        disp('Saving the spatial average of background for each snapshot...');
        save(fnout_bg_img_sptm,'img_background_spatial_mean');
        
        disp('Saving the temporal mean and std dev of the spatial averages, background...');
        save(fnout_bg_img_ms,'img_background_ms');
    end
    
    % Back to 550nm, full intensity
    ol490.setPeak(550,bandwidth,100)

    % ring
    beep on
    beep

return

end
