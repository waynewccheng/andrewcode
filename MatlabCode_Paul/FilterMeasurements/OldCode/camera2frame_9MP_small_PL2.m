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

function camera2frame_9mp_small_PL2 (pathout, numberofshots, ol490, intensity, bandwidth, shutter_tbl)
% capture an image with multispectral

    disp('Capturing frames with wavelength from 380 to 780 nm...')
    
    mkdir(pathout)
    fnout_stack = sprintf('%s/img_stack',pathout);
    fnout_m = sprintf('%s/vim_mean_array',pathout);
    fnout_s = sprintf('%s/vim_std_array',pathout);
    fnout_max = sprintf('%s/max_array',pathout);
    fnout_img_ms = sprintf('%s/img_ms',pathout);
    fnout_img_sptm = sprintf('%s/img_spatial_mean',pathout);
    
    % aqusition
    cam = CameraClass9MPSmall_PL2
    
%     % Set the shutter time
%     cam.setShutter(shutter);
    
    % data
    vim_mean_array = zeros(41,676,844);
    vim_std_array = zeros(41,676,844);
    max_array = zeros(41, 1);
%     img_m = zeros(676,844);
    img_stack = zeros(41, 676, 844, numberofshots);
    img_spatial_mean = zeros(41, 1 + numberofshots);
    img_ms = zeros(41, 3);
    
    % prepare light
%     bandwidth = 5;
    % intensity = 100;

    k = 1;
    for wl=380:10:780
            
        % Set the shutter time
        cam.setShutter(shutter_tbl(k));
    
        % prepare light    
        ol490.setPeak(wl,bandwidth,intensity(k, 1) );
        pause(1); % This deals with 07-1-2019 potential bug
        
        % acquisition
        [img, img_m, vim_mean_array(k,:,:), vim_std_array(k,:,:)] = cam.snap(numberofshots, 'filter');
        
        % Store the whole image stack
        img_stack(k, :, :, :) = img;
        
        % Store spatial mean at each wavelength
        img_spatial_mean(k, 1) = wl;
        img_spatial_mean(k, 2:numberofshots+1) = img_m;
        
        % Store temporal mean of spatial means at each wavelength
        img_ms(k, 1) = wl;
        img_ms(k, 2) = mean(img_m);
        img_ms(k, 3) = std(img_m)./sqrt(numberofshots);
        
        % Max of image to track saturation
        % max_array(k, 1) = max(max(vim_mean_array(k,:,:)));
        max_array(k, 1) = max(max(max(img_stack(k, :, :, :))));
        disp(['Max count = ' num2str(max_array(k, 1))]);
 
        k = k + 1;
    end
    
    % exit
    cam.close;

    beep
    
    % save data after closing devices
    disp('Saving image stack...');
    save(fnout_stack,'img_stack','-V7.3');
    
    disp('Saving captured frames in vim_mean_array and vim_std_array...');
    save(fnout_m,'vim_mean_array','-V7.3');
    save(fnout_s,'vim_std_array','-V7.3');
    
    disp('Saving the max array to check for saturation...');
    save(fnout_max,'max_array');
    
    disp('Saving the spatial average for each snapshot...');
    save(fnout_img_sptm,'img_spatial_mean');
    
    disp('Saving the temporal mean and std dev of the spatial averages...');
    save(fnout_img_ms,'img_ms');
    
    disp(['Max count total = ' num2str(max(max_array))]);
    
    ol490.setPeak(550,bandwidth,100)

    % ring
    beep on
    beep

return

end
