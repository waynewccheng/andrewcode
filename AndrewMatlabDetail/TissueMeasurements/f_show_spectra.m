% 04-03-20: Plot the transmittance values of pixel(s) across the 380-780 nm
% spectrum of wavelengths. 

% To plot multiple pixels, use lines 39-48
% To plot a single pixel, use lines 50-55

% In the f_processdata_illuminants function, data is written to:
% (Your Desired Location)\(Illuminant Name)\(Sample Name)...
% Modify Line 23 to specify (Your Desired Location)
% Define Sample & Illuminant names when calling the function.

% If processed transmittance data is saved in a different loactino that does
% not reference the Sample &/or Illuminant names, specify the location in
% line 23

function Tlambda = f_show_spectra (name_of_sample, illuminant, x, y)

    close all;
  
    lambda = [380:10:780].'; % Wavelengths
    
    % Declare path from which processed transmittance data can be loaded
    p_pdata = ['D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\' illuminant '\' name_of_sample '\Transmittance'];

    % Load processed transmittance data
    cd(p_pdata); 
    load ('trans_mean_camera');
    
    % Return to the original directory where this function is saved
    cd('D:\DigitalPathology\ColorDetail\Matlab_Color\Scripts\TissueMeasurements');
    
    % Reshape transmittance into 3D matrix
    T = reshape(trans_array_m, size(trans_array_m,1), sizex, sizey);
    
    % Isolate transmittance values at the desired pixel location(s)
    Tlambda = T(:,x,y); 
    
    figure
      %plot multiple pixels
      % Change for loop to 1:length(y) if plotting a row of pixels in y
      for i = 1:length(x)
        plot(lambda,Tlambda(:,i))
        title(['T({\lambda}) of Pixels, Bladder, ' illuminant], 'fontsize', 16, 'fontweight', 'bold')
        xlim([380 780]); ylim([0 1.5])
        xlabel('Wavelength ({\lambda})', 'fontsize', 16, 'fontweight', 'bold')
        ylabel('Transmittance (A.U.)','fontsize', 16, 'fontweight', 'bold')
        hold on
      end
      
%       %plot a single pixel
%       plot(lambda,Tlambda)
%       title(['T({\lambda}) of a Single Pixel, Bladder, ' illuminant], 'fontsize', 16, 'fontweight', 'bold')
%       xlim([380 780]); ylim([0 1.5])
%       xlabel('Wavelength ({\lambda})', 'fontsize', 16, 'fontweight', 'bold')
%       ylabel('Transmittance (A.U.)','fontsize', 16, 'fontweight', 'bold')
    
end