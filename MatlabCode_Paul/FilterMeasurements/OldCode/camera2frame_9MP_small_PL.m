% 10-9-2015
% example: ol490 = OL490Class; camera2frame('dataout/1009-test1',1,ol490)
%
% 8-3-2015: hardware trigger; needs software reset!
% 7-23-2015: replace grasshopper function with camera_*
% usage: camera2frame('0723-7')
% 7-21-2015: revisit
% capture images with camera
% capture 41 images from 380 to 780
% output: vimarray(41,480,640)  

% Modified by Paul Lemaillet to allow multiple fram acquisition to compute
% mean value of intensity of each pixel + std deviation

% function camera2frame_9mp_small_PL (pathout, numberofshots, ol490, intensity)
function camera2frame_9mp_small_PL (pathout, numberofshots, ol490, intensity)
% capture an image with multispectral

    disp('Capturing frames with wavelength from 380 to 780 nm...')
    
    mkdir(pathout)
    fnout_m = sprintf('%s/vim_mean_array',pathout);
    fnout_s = sprintf('%s/vim_std_array',pathout);
    fnout_max = sprintf('%s/max_array',pathout);
    fnout_img_ms = sprintf('%s/img_ms',pathout);
    fnout_img_sptm = sprintf('%s/img_spatial_mean',pathout);
    
    % aqusition
    cam = CameraClass9MPSmall_PL
    
    % data
    vim_mean_array = zeros(41,676,844);
    vim_std_array = zeros(41,676,844);
    max_array = zeros(41, 1);
    img_m = zeros(676,844);
    img_spatial_mean = zeros(41, 2 + numberofshots);
    img_ms = zeros(41, 3);
    
    % prepare light
    bandwidth = 10;
    % intensity = 100;

    k = 1;
    for wl=380:10:780
        % prepare light    
        
%         ol490.setPeak(wl,bandwidth,intensity); 
        ol490.setPeak(wl,bandwidth,intensity(k, 1) );

        % focus
%        f_opt = myfocus(cam)
        
        % acqusition
        [img_m, vim_mean_array(k,:,:), vim_std_array(k,:,:)] = cam.snap(numberofshots, 'filter');
        
        % Store spatial mean at each wavelength
        img_spatial_mean(k, 1) = wl;
        img_spatial_mean(k, 2:numberofshots+1) = img_m;
        
        % Store temporal mean of spatial means at each wavelength
        img_ms(k, 1) = wl;
        img_ms(k, 2) = mean(img_m);
        img_ms(k, 3) = std(img_m)./sqrt(numberofshots);
        
        % Max of image to track saturation
         max_array(k, 1) = max(max(vim_mean_array(k,:,:)));
         
        % Does the light source waits before switching to another
        % wavelength?
        % pause(numberofshots/9); % 9fps, could remove that, the program waits for the camera
 
        k = k + 1;
    end
    
    % exit
    cam.close;

    beep
    
    % save data after closing devices
    disp('Saving captured frames in vimarray...');
    save(fnout_m,'vim_mean_array','-V7.3');
    save(fnout_s,'vim_std_array','-V7.3');
    
    disp('Saving the max array to check for saturation...');
    save(fnout_max,'max_array');
    
    disp('Saving the spatial mean for each shot...');
    save(fnout_img_sptm,'img_spatial_mean');
    
    disp('Saving the temporal mean of the spatial means...');
    save(fnout_img_ms,'img_ms');
    
    ol490.setPeak(550,10,100)

    % ring
    beep on
    beep

return

end
