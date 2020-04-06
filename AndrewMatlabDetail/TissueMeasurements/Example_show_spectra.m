% Example script for f_show_spectra.m function

% Plot transmittance of a single pixel [500,500] for Bladder_M13 sample
f_show_spectra ('D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\BiomaxOrgan10_Bladder_M13\Transmittance',[500,500],'Bladder')

% Plot transmittane of a row of samples [1:500,250] for Bladder_M13 sample
f_show_spectra ('D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\BiomaxOrgan10_Bladder_M13\Transmittance',[(1:500)', repmat(250,500,1)],'Bladder');
