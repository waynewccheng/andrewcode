% Example script to plot the spectra of circle and donut areas

% Select your circular ROI
mask_circle = select_roi_circle('D65.png', [422,338], 5);

% Plot the spectra for pixels within the circular ROI
f_show_spectra ('D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\BiomaxOrgan10_Bladder_M13\Transmittance', mask_circle, 'Bladder');

% Select your donut-shaped ROI
mask_donut = select_roi_donut('D65.png', [422,338], 5, 15);

% Plot the spectra for the pixels within the donut ROI
f_show_spectra ('D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\BiomaxOrgan10_Bladder_M13\Transmittance', mask_donut, 'Bladder');