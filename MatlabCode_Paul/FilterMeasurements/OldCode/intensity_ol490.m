%%
% Establishes the maximum intensity (camera setting), 
% using the white position and spanning the wavelengths

% 07-12-2019

function intensities = intensity_ol490(ol490, ludl, ROI, numberofshots, bandwidth, shutter_tbl)

    % Move to white measurement position
    ludl.setXY(ROI(2, :));
    
    % Pauses until the stage is not moving anymore
    while ludl.getStatus ~= 'N'
        pause(0.01);
    end
        
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

        % Loop decreasing the intensity
%         while max(max(int_mean_array)) == 255
        while max(max(tmp_stack)) == 255
            intensity = intensity - 1;
            intensity
            ol490.setPeak(wl,bandwidth,intensity);
            % pause(1);

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