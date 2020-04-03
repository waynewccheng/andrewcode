%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sets the ROI of sample, 100% and 0% transmittance regions %
%%%

% 11-15-19: change name from findroi_PL3 to f_findroi

% 09-26-19: chose color of light, Green or White

% 08-20-19: No tape measurements

% 07-12-2019: turn it as a function

% 4-10-2018


function [xy, xy_white] = f_findroi(ol490, ludl, l)

    % Turn on the light
    switch l
        case 'w'
            ol490.setWhite;
        case 'g'
            ol490.setGreen;
    end

    % Sets the camera
    vid = videoinput('pointgrey', 1, 'F7_Mono8_844x676_Mode5');
%     src = getselectedsource(vid);

    vid.FramesPerTrigger = 1;

    preview(vid);

    % ROI of sample
    input('Press Enter to save location of ROI:')

    xy = ludl.getXY;

    % ROI of 100% transmittance
    input('Press Enter to save location of white (100% transmittance):')

    xy_white = ludl.getXY;

%     % ROI of 0% transmittance
%     a = input('Press Enter to save location of black (0% transmittance):')
% 
%     xy_black = ludl.getXY

    delete(vid);
end