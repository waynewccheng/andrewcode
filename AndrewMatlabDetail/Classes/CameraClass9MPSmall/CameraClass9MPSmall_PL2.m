%%
% 11-15-19: add function setGain

% 08-06-2019: Output the whole image stack, add function setShutter

% 07-12-2019: Add the info method


classdef CameraClass9MPSmall_PL2
    properties
        vid
        src
        caminfo
    end
    
    methods
        %%
        function obj = CameraClass9MPSmall_PL2
            
            % open the device
%            obj.vid = videoinput('pointgrey', 1, 'Mono16_640x480');
%            obj.vid = videoinput('pointgrey', 1, 'F7_Raw16_3376x2704_Mode7');
            obj.caminfo.adaptorname = 'pointgrey';
            obj.caminfo.deviceID = 1;
            obj.caminfo.format = 'F7_Mono8_844x676_Mode5';
            
            obj.vid = videoinput(obj.caminfo.adaptorname, obj.caminfo.deviceID, obj.caminfo.format);

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
        % Computes the spatial average of each image as well
        function [img, img_m, vim, vim_std] = snap(obj, nround, spl_type)
            
            % initialize the matrices
            img = zeros(676, 844, nround, 'double');
            img_m = zeros(1, nround);
            
            for r = 1:nround
                imtemp = getsnapshot(obj.vid);
                img(:, :, r) = double(imtemp);
                
                if strcmp(spl_type, 'filter')
                    img_m(1, r) = mean2(img(:, :, r));
                end
                
            end
            
            % mean and std dev of all frames
            vim = mean(img, 3);
            vim_std = std(img, 0, 3)./sqrt(nround);
                       
            %vim = imsum / (nround);
           
        end
        
        function setShutter(obj, myShutter)
           obj.src.Shutter = myShutter;
        end
        
        function setGain(obj, myGain)
           obj.src.Gain = myGain;
        end
        
        function [type, mode, parameters] = info(obj)
            
            type = {'Adaptorname', 'DeviceID', 'Format';...
                obj.caminfo.adaptorname, obj.caminfo.deviceID, obj.caminfo.format};
            
            mode = {'ExposureMode', 'FrameRatePercentageMode', 'GainMode',...
                'ShutterMode', 'SharpnessMode'; ...
                obj.src.ExposureMode, obj.src.FrameRatePercentageMode,...
                obj.src.GainMode, obj.src.ShutterMode, obj.src.SharpnessMode};
            
            parameters = {'Brightness', 'Exposure', 'Shutter', 'Gain', 'Gamma',...
                'FrameRatePercentage', 'Sharpness'; ....
                obj.src.Brightness, obj.src.Exposure, obj.src.Shutter,...
                obj.src.Gain, obj.src.Gamma,...
                obj.src.FrameRatePercentage, obj.src.Sharpness};
           
        end
    end
end