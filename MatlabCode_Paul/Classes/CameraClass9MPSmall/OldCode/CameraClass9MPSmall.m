classdef CameraClass9MPSmall
    properties
        vid
        src
    end
    
    methods
        %%
        function obj = CameraClass9MPSmall
            
            % open the device
%            obj.vid = videoinput('pointgrey', 1, 'Mono16_640x480');
%            obj.vid = videoinput('pointgrey', 1, 'F7_Raw16_3376x2704_Mode7');
            obj.vid = videoinput('pointgrey', 1, 'F7_Mono8_844x676_Mode5');

            obj.src = getselectedsource(obj.vid);
            
            %load('lightsetting','src')
            %obj.src = src;
            
            % fix the camera settings
            obj.src.ExposureMode = 'Manual';
            obj.src.FrameRatePercentageMode = 'Manual';
            obj.src.GainMode = 'Manual';
            obj.src.ShutterMode = 'Manual';
            obj.src.SharpnessMode = 'Manual';
            
            % grap the camera settings
            % load('cameravstruth.mat','myBrightness','myExposure','myShutter','myGain')
            myBrightness = 0;
            myExposure = 1.65;
            myShutter = 0.68;
            myGain = 0;            

            %% set the exposure time
            % for skin setup
            obj.src.Brightness = myBrightness;
            obj.src.Exposure = myExposure;
            obj.src.Shutter = myShutter;
            obj.src.Gain = myGain;
            obj.src.Gamma = 1;
            obj.src.FrameRatePercentage = 100;
            obj.src.Sharpness = 1532;
            
            % open preview window
            preview(obj.vid);
        end
        
        %%
        function close (obj)
            
            % close the device
            closepreview;
            delete(obj.vid);
            
        end
        
        %%
        function [vim, vim_std] = snap(obj, nround)
            
            % initialize the sum matrix
            % imsum = zeros(676,844,'double');
            im_pl = zeros(676, 844, nround, 'double');
            
            for r = 1:nround
                imtemp = getsnapshot(obj.vid);
                im_pl(:, :, r) = double(imtemp);
                % imsum = imsum + double(imtemp);
            end
            
            % mean and std dev of all frame
            vim = mean(im_pl, 3);
            vim_std = std(im_pl, 0, 3)./sqrt(nround);
            
            %vim = imsum / (nround);
           
        end
    end
end
