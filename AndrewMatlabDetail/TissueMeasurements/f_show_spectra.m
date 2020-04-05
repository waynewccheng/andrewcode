% 04-03-20: Plot the transmittance values of pixel(s) across the 380-780 nm
% spectrum of wavelengths. 

% Plot title (line 38) must be changed based on the origin of the sample.

% In the f_meas_tissue function, processed transmittance data is saved in:
% "Your Desired Location"\"Sample Name"\Transmittance
% Modify the code before "sample_name" in line 19 to specify "Your Desired
% Location" on your computer, and define "Sample Name" when calling the
% function. If your processed transmittance data is saved in a location
% that does not reference the sample name, replace the entire path in line
% 23 with your specific file path.

function f_show_spectra (sample_name, xy)
 
    lambda = [380:10:780].'; % Wavelengths
    
    % Declare path from which processed transmittance data can be loaded
    p_pdata = ['D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\' sample_name '\Transmittance'];

    % Load processed transmittance data
    cd(p_pdata); 
    load ('trans_mean_camera');
    
    % Return to the original directory where this function is saved
    % Note: This line isn't necessary to run the code, but makes life
    % easier if you are going to be running the function several times to
    % make multiple plots
    cd('D:\DigitalPathology\ColorDetail\Matlab_Color\Scripts\TissueMeasurements');
    
    % Reshape transmittance into 3D matrix
    Tlambda = reshape(trans_array_m, size(trans_array_m,1), sizex, sizey);
    
    figure
      %plot transmittance of pixels as a function of wavelength
      for i = 1:length(xy(:,1))
        plot(lambda,Tlambda(:,xy(i,1),xy(i,2)))
        title(['T({\lambda}) of Pixels, Bladder'], 'fontsize', 16, 'fontweight', 'bold')
        xlim([380 780]); ylim([0 1.5])
        xlabel('Wavelength ({\lambda})', 'fontsize', 16, 'fontweight', 'bold')
        ylabel('Transmittance (A.U.)','fontsize', 16, 'fontweight', 'bold')
        hold on
      end
      
end