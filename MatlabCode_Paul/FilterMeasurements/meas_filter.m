% 11-12-19: First version

close all;
clearvars -except ol490 ludl pr

% Starts the clock
tic

%% 1: Initialization
% Sample name
name_of_sample = 'Filter_KW32BW10';

% Init ludl and PR730
ludl = LudlClass('COM14');
pr = pr730Class('COM17');

%% 2: ROI
[xy, xy_white] = f_findroi(ol490, ludl, 'w'); % 'g' for green light, 'w' for broadband
ROI = [xy; xy_white];

%% 3: Measurements
% Number of repeated measurements
n_meas = 10; 

% Call the measurements
f_meas_filter(name_of_sample, ol490, ludl, pr, n_meas, ROI, 'on');

% Closes ludl and PR730
pr.close;
ludl.close;

% Stops the clock
toc