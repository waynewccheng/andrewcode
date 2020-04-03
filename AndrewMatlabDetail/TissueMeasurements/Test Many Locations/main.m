% 09-25-19: First version

close all;
clearvars -except ol490 ludl pr

% Starts the clock
tic

%% 1: Initialization
% Init ludl and PR730
ludl = LudlClass('COM14');
pr = pr730Class('COM15');

n_rows = 3; 
n_cols = 7;
pos_w = [2 5];

%% 2: ROI
% To get the corner of the rectangle sample area with the 10x objective
xy = f_find_corners(ol490, ludl);

% Computes the steps based on the corners coordinates
stepy = mean([(xy(2,2)-xy(1,2))/(n_rows-1) (xy(3,2)-xy(4,2))/(n_rows-1)])
stepx = mean([(xy(3,1)-xy(2,1))/(n_cols-1) (xy(4,1)-xy(1,1))/(n_cols-1)])

% Fill the patches coordinate table
xy_roi = zeros(n_rows*n_cols, 2);
z_focus =  zeros(n_rows*n_cols-1, 2);

k = 1;
for i = 1:n_rows
    for j = 1:n_cols
        xy_roi(k, :) = [xy(1, 1)+(j-1)*stepx xy(1, 2)+(i-1)*stepy];
        k = k+1;
    end
end

% xy values are subtituted to computed ones
xy_roi(1, :) = xy(1, :);
xy_roi(n_cols, :) = xy(4, :);
xy_roi(2*n_cols+1, :) = xy(2, :);
xy_roi(n_rows*n_cols, :) = xy(3, :);

% Remove the position of the empty patch
xy_roi((pos_w(1)-1)*n_cols+pos_w(2), :) = [];

%% 3: Test try the position + adjust position and focus with the 20X objective (not yet)  

% Turn on the light
% ol490.setWhite

% Sets the camera
vid = videoinput('pointgrey', 1, 'F7_Mono8_844x676_Mode5');
vid.FramesPerTrigger = 1;

% Camera on
preview(vid);

for i = 1:n_rows*n_cols-1

    % Move to sample ROI
    ludl.setXY(xy_roi(i, :));
    
    % Pauses until the stage is not moving anymore
    while ludl.getStatus ~= 'N'
        pause(0.01);
    end
    
    % Adjuct focus
    input('Press Enter to save focus z height:')
    z_focus(i, :) = ludl.getZ;

    % Position
    input('Press Enter to save location:')
    xy_roi(i, :) = ludl.getXY;
    
%     pause(1);
   
end

% Camera off
delete(vid);

%% Measurements
sample_list = {'Filter_Rosco97BW10', 'Filter_Rosco68BW10', 'Filter_Rosco356BW10', 'Filter_Rosco51BW10', 'Filter_Rosco34BW10', 'Filter_Rosco337BW10', 'Filter_Rosco24BW10', ...
    'Filter_Rosco398BW10', 'Filter_Rosco56BW10', 'Filter_Rosco347BW10', 'Filter_Rosco52BW10', 'Filter_Rosco336BW10', 'Filter_Rosco342BW10', 'Filter_Rosco316BW10', ...
    'Filter_Rosco99BW10', 'Filter_Rosco59BW10', 'Filter_Rosco360BW10', 'Filter_Rosco48BW10', 'Filter_Rosco39BW10', 'Filter_Rosco43BW10', 'Filter_Rosco46BW10'};

% % Init ludl and PR730
% ludl = LudlClass('COM14');
% pr = pr730Class('COM15');

% Number of repeated measurements
n_meas = 10; 

% Call the measurements
for i = 1:size(xy_roi, 1)
    name_of_sample = sample_list{i};
    ludl.setZ(z_focus(i, :));
    xy_white = xy(5, :);
    ROI = [xy_roi(i, :); xy_white];
    meas_filter(name_of_sample, ol490, ludl, pr, n_meas, ROI, 'off');
end

% Closes ludl and PR730
pr.close;
ludl.close;

toc