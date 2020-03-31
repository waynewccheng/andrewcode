%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sets the ROI of sample, 100% and 0% transmittance regions %
%%%

% 4-10-2018

% Author: Wei-Chung

function[] = 
% Turn on the light
ol490.setWhite
   
% Sets the camera
vid = videoinput('pointgrey', 1, 'F7_Mono8_844x676_Mode5');
src = getselectedsource(vid);

vid.FramesPerTrigger = 1;

preview(vid);

% ROI of sample
a = input('Press Enter to save location of ROI:')

xy = ludl.getXY

% ROI of 100% transmittance
a = input('Press Enter to save location of white (100% transmittance):')

xy_white = ludl.getXY

% ROI of 0% transmittance
a = input('Press Enter to save location of black (0% transmittance):')

xy_black = ludl.getXY

delete(vid)
end