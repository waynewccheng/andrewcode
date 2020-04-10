% Example script to show images and calculate dE of circle and donut areas
close all;
clear,clc;

% Select your circular ROI
mask_circle = select_roi_circle('D65.png', [422,338], 100);

% Select your donut-shaped ROI
mask_donut = select_roi_donut('D65.png', [422,338], 95, 200);

% Calculate CIEXYZ, CIELAB, and sRGB, produce dE and images of ROIs
dE = f_processdata_roi('D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\BiomaxOrgan10_Bladder_M13\Transmittance', 'Data Illuminants', mask_circle, mask_donut);

% visualize
figure
imagesc(dE(:,:,1)) %dE with D65 illuminant
axis image 
axis off
caxis([0 100])
colormap parula
colorbar
title ('\DeltaE between pink and purple areas, D65')

figure
imagesc(dE(:,:,2)) %dE with D50 illuminant
axis image
axis off
caxis([0 100])
colormap parula
colorbar
title('\DeltaE between pink and purple areas, D50')

figure
imagesc(dE(:,:,3)) %dE with A illuminant
axis image
axis off
caxis([0 100])
colormap parula
colorbar
title('\DeltaE between pink and purple areas, A')