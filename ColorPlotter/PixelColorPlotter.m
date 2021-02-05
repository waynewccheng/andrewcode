% ACL 2/3/2021
% This script plots the pixels of selected ROIs in sRGB, CIEXYZ, and CIELAB space
% Used to analyze a large color phantom with a matrix of ROIs
% Integrates f_sRGB2XYZ, f_spd2XYZ, and ColorConversionClass.XYZ2lab f'ns
% Computes XYZ reference white from Data Illuminant D65
%
% Instructions:
%   1) Input the name of the original image in line 17
%   2) Update the filepath of the image in line 18
%   3) Input the number rows and columns for the ROI matrix (lines 22-23)
%
% The plots are saved to the same folder as this script
% The numbering convention for all of the ROIs is up to the user
%
close all;
clear,clc;

% Declare the path and name of the image to analyze, read it into a matrix
pic_name = 'RoscoluxPhantom_Full_1-11-21';
if getenv('username') == 'wcc'
    filepath = (['' pic_name '.tif']);
else
    filepath = (['E:\DigitalPathology\WSI_Zeiss\DigiPath_RoscoluxPhantom\' pic_name '.tif']);
end
image = imread(filepath);

% Declare the number of rows and columns in the phantom
rows = 3;
columns = 8;

% Loop through each of the frames
for i = 1:(rows*columns)
    
    % Select a circular ROI (output a mask, center point, and radii)
    [mask,cent,rad] = select_roi_circle(filepath)
    
    % Use the mask to create a matrix only for the ROI
    for j = 1:length(mask(:,1))
        ROIsRGB(j,:) = image(mask(j,2),mask(j,1),:);
    end
    
    % Plot all pixels in the image in 3D sRGB space
    c_pixel = double(ROIsRGB)/255;
    figure;
    scatter3(ROIsRGB(:,1), ROIsRGB(:,2), ROIsRGB(:,3), 3, c_pixel(:,:), 'fill');
    xlabel('R'); ylabel('G'); zlabel('B');
    title(['RGB Pixel Colors for Section #' num2str(i)]);
    xlim ([0 255]); ylim([0 255]); zlim([0 255]);
    saveas(gcf,['Section' num2str(i) 'RGB.png']);
    
    % Convert sRGB data to XYZ data and plot
    ROIXYZ = f_sRGB2XYZ(ROIsRGB);
    figure;
    scatter3(ROIXYZ(:,1), ROIXYZ(:,2), ROIXYZ(:,3), 3, c_pixel(:,:), 'fill');
    xlabel('X'); ylabel('Y'); zlabel('Z');
    xlim ([0 1]); ylim([0 1]); zlim([0 1]);
    title(['CIEXYZ Pixel Colors for Section #' num2str(i)]);

    saveas(gcf,['Section' num2str(i) 'XYZ.png']);

    % Get D65 light source data
    illuminant = ['D65'];
    directory = cd();
    load([directory '\Data Illuminants\spec_cie' illuminant],'spec');
    ls = spec(1:10:401,2);
    
    % Compute reference white XYZ value
    XYZ0 = f_spd2XYZ(1,[],ls);
    
    % Convert CIEXYZ values to LAB values
    ROILAB = ColorConversionClass.XYZ2lab(ROIXYZ, XYZ0);
    figure;
    scatter3(ROILAB(:,3), ROILAB(:,2), ROILAB(:,1), 3, c_pixel(:,:), 'fill');
    xlabel('b*'); ylabel('a*'); zlabel('L*');
    title(['CIELAB Pixel Colors for Section #' num2str(i)]);
    xlim ([-75 25]); ylim([-25 75]); zlim([0 100]);
    saveas(gcf,['Section' num2str(i) 'LAB.png']);

    clear('mask','cent','rad','ROIsRGB','ROILAB','ROIXYZ')
    
end