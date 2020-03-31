%%
% Establishes the maximum intensity (camera setting), 
% using the white position and spanning the wavelengths

% 07-12-2019

function [shutter_tbl] = shutter_cam(ol490, ludl, ROI, numberofshots, bandwidth, shutter_input, mode)

    % Move to white measurement position
    ludl.setXY(ROI(2, :))

    intensity = 100;
    ol490.setPeak(550,10,intensity);

%     % Data storage
%     int_mean_array = zeros(676,844);
%     int_std_array = zeros(676,844);
%     intensities = zeros(41, 2);
    shutter_tbl = zeros(41, 2);

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

        % Mode 1, coarse, mode 2, 3 refined
        switch mode
            case 1
            % Jack up the shutter time
            shutter = 37; % 37.4 ms is the max value
            step = 1;
            min_shutter = 1;
 
            case 2
            shutter = shutter_input(k);
            step = 0.1;
            min_shutter = 0.1;
            
            case 3
            shutter = shutter_input(k);
            step = 0.01;
            min_shutter = 0.04;
        end
        
        cam.setShutter(shutter);
        pause(1);
        
        % Second image, needed otherwise uses first image that is not
        % saturated but should
        [tmp_stack, tmp, int_mean_array, int_std_array] = cam.snap(numberofshots, 'filter');        
        
        while max(max(tmp_stack)) == 255 && shutter > min_shutter
            shutter = shutter - step;
            disp(['Lambda = ' num2str(wl) ' Shutter = ' num2str(shutter) ' Max = ' num2str(max(max(tmp_stack)))])
            cam.setShutter(shutter);
            [tmp_stack, tmp, int_mean_array, int_std_array] = cam.snap(numberofshots, 'filter');
        end

        % Store intensity value
        shutter_tbl(k, 1) = wl;
        shutter_tbl(k, 2) = shutter;

        k = k + 1;
    end

    % exit
    cam.close;

end