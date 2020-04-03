%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurements of the tissue slides

% 11-14-19: First version 

close all;
clearvars -except ol490 ludl

% Starts the clock
tic

%% 1: Initialization
% Sample name
name_of_sample = 'Camelyon16_T12-17823_Tag1'

% Open remote control for ludl
ludl = LudlClass('COM14');

%% 2: ROI
[xy, xy_white] = f_findroi(ol490, ludl, 'g'); % 'g' for green light, 'w' for white light
ROI = [xy; xy_white];

%% 3: Measurements
% Number of repeated measurements
n_meas = 10; 

% Call the measurements
f_meas_tissue(name_of_sample, ol490, ludl, n_meas, ROI);

% Closes ludl
ludl.close;

% Stops the clock
toc