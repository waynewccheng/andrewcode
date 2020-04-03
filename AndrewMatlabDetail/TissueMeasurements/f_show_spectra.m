%04-03-20: Plot the transmittance values of pixel(s) across the 380-780 nm
%spectrum of wavelengths. 

function f_show_spectra(Tlambda, xy, name_of_sample, illuminant)

    close all;

    % Declare Paths to collect processed data
    name_of_sample = 'BiomaxOrgan10_Bladder_M13'; % name of the sample
    illuminant = 'D65'; % name of the illuminant
    xy = [1:500,250]; % pixel location(s) to be plotted
    lambda = [380:10:780].'; % wavelengths
    
    p_pdata = ['D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\' illuminant '\' name_of_sample '\Transmittance']; % path for the processed transmittance data

    % Load processed transmittance data
    cd(p_pdata); 
    load ('trans_mean_camera');
    
    cd('D:\DigitalPathology\ColorDetail\Matlab_Color\Scripts\TissueMeasurements');
    T = reshape(trans_array_m, size(trans_array_m,1), sizex, sizey); % reshape transmittance into 3D matrix
    Tlambda = T(:,xy(1:500),xy(501)); % Isolate T(lambda) values at the desired pixel location(s)
    
    figure
      %plot multiple pixels
      for i = 1:500
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
%       hold on
    
end
