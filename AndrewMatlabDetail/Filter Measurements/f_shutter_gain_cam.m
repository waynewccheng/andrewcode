%%
% Establishes the maximum intensity (camera setting), 
% using the white position and spanning the wavelengths

% 11-15-19: Added gain evaluation
% 
% function [shutter_tbl] = f_shutter_cam(ol490, ludl, ROI, bandwidth, shutter_input, mode)


function [shutter_tbl, gain_tbl] = f_shutter_gain_cam(ol490, bandwidth, shutter_input, gain_input, mode)
    % Initialization
%     ludl.setXY(ROI(2, :))

    intensity = 100;
    ol490.setPeak(550,10,intensity);
    numberofshots = 1;
    
%     % Data storage
%     int_mean_array = zeros(676,844);
%     int_std_array = zeros(676,844);
%     intensities = zeros(41, 2);
    shutter_tbl = zeros(41, 2);
    gain_tbl = zeros(41, 2);

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
        
        % Min gain values
        min_gain = 0;
        
        % Mode 1, coarse, mode 2, 3 refined
        switch mode
            case 1
                shutter = 37; % 37.4 ms is the max value
                step_s = 1;
                min_shutter = 1;
                
                gain = 24; % 24 dB is the max value
                step_g = 1;
            case 2
                shutter = shutter_input(k);
                step_s = 0.1;
                min_shutter = 0.1;
                
                gain = gain_input(k);
                step_g = 0.1;
            case 3
                shutter = shutter_input(k);
                step_s = 0.01;
                min_shutter = 0.04;

                gain = gain_input(k);
                step_g = 0.01;
        end
        
        cam.setShutter(shutter);
        pause(1);
        cam.setGain(min_gain);
        pause(1);
        
        % Second image, needed otherwise uses first image that is not
        % saturated but should
        [tmp_stack, tmp, int_mean_array, int_std_array] = cam.snap(numberofshots, 'filter');        
        
        while max(max(tmp_stack)) == 255 && shutter > min_shutter
            shutter = shutter - step_s;
            disp(['Lambda = ' num2str(wl) ' Shutter = ' num2str(shutter) ' Gain = ' num2str(min_gain) ' Max = ' num2str(max(max(tmp_stack)))])
            cam.setShutter(shutter);
%             pause(0.1);
            [tmp_stack, tmp, int_mean_array, int_std_array] = cam.snap(numberofshots, 'filter');
        end
        
        % Store shutter time values
        shutter_tbl(k, 1) = wl;
        shutter_tbl(k, 2) = shutter;
        
        % First col of gain values
        gain_tbl(k, 1) = wl;

        % Adjust the gain is the shutter time is max
        if shutter == 37
           
            cam.setGain(gain);
            pause(1);
            
            [tmp_stack, tmp, int_mean_array, int_std_array] = cam.snap(numberofshots, 'filter');
            
            while max(max(tmp_stack)) == 255 && gain > min_gain
                gain = gain - step_g;
                disp(['Lambda = ' num2str(wl) ' Shutter = ' num2str(shutter) ' Gain = ' num2str(gain) ' Max = ' num2str(max(max(tmp_stack)))])
                cam.setGain(gain);
%                 pause(0.1);
                [tmp_stack, tmp, int_mean_array, int_std_array] = cam.snap(numberofshots, 'filter');
            end
            
            % Store gain values
            gain_tbl(k, 2) = gain;
            
        end

        k = k + 1;
        
    end

    % exit
    cam.close;

end