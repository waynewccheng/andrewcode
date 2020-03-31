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

function camera2frame_9mp_small (pathout, numberofshots, ol490)
% capture an image with multispectral

    disp('Capturing frames with wavelength from 380 to 780 nm...')
    
    mkdir(pathout)
    fnout = sprintf('%s/vimarray',pathout);

    % aqusition
%    cam = CameraClass
%    cam = CameraClassUSB3
    cam = CameraClass9MPSmall
    
    % data
%    vimarray = zeros(41,480,640);
%    vimarray = zeros(41,2192,2736);
    vimarray = zeros(41,676,844);

    % prepare light
    bandwidth = 10;
    intensity = 100;

    k = 1;
    for wl=380:10:780
        % prepare light    
        
        ol490.setPeak(wl,bandwidth,intensity); 

        % focus
%        f_opt = myfocus(cam)
        
        % acqusition
        vim = cam.snap(numberofshots);
        vimarray(k,:,:) = vim;

        k = k + 1;
    end

    % exit
    cam.close;

    beep
    
    % save data after closing devices
    disp('Saving captured frames in vimarray...')
    save(fnout,'vimarray','-V7.3')

    ol490.setPeak(550,10,100)

    % ring
    beep on
    beep

return

end
