% 04-03-20: Plot the transmittance values of pixel(s) across the 380-780 nm
% spectrum of wavelengths. 

% Plot title (line 36) must be changed based on the origin of the sample.

% In the f_meas_tissue.m function, processed data is written to:
% Your Desired Location\Sample Name\Transmittance
% Modify Line 23 to specify "Your Desired Location" for your computer and
% define "Sample Name" when calling the function.If your processed 
% transmittance data is saved in a different loaction that does not 
% reference the sample name, replace the path in line 23 with your 
% specific file path.

function f_show_spectra (name_of_sample, xy)
 
    lambda = [380:10:780].'; % Wavelengths
    
    % Declare path from which processed transmittance data can be loaded
    p_pdata = ['D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\' name_of_sample '\Transmittance'];

    % Load processed transmittance data
    cd(p_pdata); 
    load ('trans_mean_camera');
    
    % Return to the original directory where this function is saved
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