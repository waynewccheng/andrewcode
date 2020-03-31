% Adjust the camera parameters
% Position the sample (glass slise) in blank region (no features)
close all;
clearvars -except ol490

% Where camera estting table are saved
p_st = 'C:\Users\wcc\Desktop\MatlabCode_Paul\PointGreySpec';

% Camera settings
mode = 'w';
bandwidth = 10;
[shutter_tbl, gain_tbl] = f_camera_settings(ol490, bandwidth, p_st, mode);