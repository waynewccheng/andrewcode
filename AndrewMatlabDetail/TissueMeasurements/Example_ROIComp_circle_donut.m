% Example script to show images and calculate dE of circle and donut areas
close all;
clear,clc;

% Select your circular ROI
mask_circle = select_roi_circle('D65.png', [590,335], 10);

% Select your donut-shaped ROI
mask_donut = select_roi_donut('D65.png', [590,335], 10, 25);

% Calculate CIEXYZ, CIELAB, and sRGB coordinates, produce images of ROIs, 
% plot pixels in LAB space, and assess pixel uniformity
f_processdata_roi('D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\BiomaxOrgan10_Bladder_M13\Transmittance', 'Data Illuminants', mask_circle, mask_donut);

% Compute dE from mean transmittance
f_dE('D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\BiomaxOrgan10_Bladder_M13\Transmittance', 'Data Illuminants', mask_circle, mask_donut);