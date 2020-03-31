%%
% Establishes the maximum intensity (camera setting), 
% using the white position and spanning the wavelengths

% 11-15-19: Change name from intensity_ol490 to f_intensity_ol490
% Added setting of gain value

% 07-12-2019

function intensities = f_intensity_ol490(ol490, bandwidth, shutter_tbl, gain_tbl)

    % Only one image
    numberofshots =  1;
    
    % Init of OL490 intensity
    intensity = 100;
    ol490.setPeak(550,10,intensity);

    % Data storage
    int_mean_array = zeros(676,844);
    int_std_array = zeros(676,844);
    intensities = zeros(41, 2);

    % Open camera
    cam = CameraClass9MPSmall_PL2

    % Span the wavelengths
    k = 1;
    for wl=380:10:780
        
        % prepare light
        intensity = 100;
        ol490.setPeak(wl,bandwidth,intensity);
        pause(1);

        % First image
        [tmp_stack, tmp, int_mean_array, int_std_array] = cam.snap(numberofshots, 'filter');
        
        % Set shutter time
        shutter = shutter_tbl(k);
        cam.setShutter(shutter);

        % Set gain
        gain = gain_tbl(k);
        cam.setGain(gain);
        
        % Loop decreasing the intensity
        while max(max(tmp_stack)) == 255
            intensity = intensity - 1;
            intensity
            ol490.setPeak(wl,bandwidth,intensity);

            [tmp_stack, tmp, int_mean_array, int_std_array] = cam.snap(numberofshots, 'filter');
        end

        % Store intensity value
        intensities(k, 1) = wl;
        intensities(k, 2) = intensity;

        k = k + 1;
    end

    % exit
    cam.close;

end