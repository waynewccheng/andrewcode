% 04-03-20: Plot the transmittance values of pixel(s) across the 380-780 nm
% spectrum of wavelengths. 

% fn -- specify the folder path that contains the transmittance data of 
% interest
% xy -- specify a k x 2 matrix containing the x and y coordinates of
% pixels to be plotted
% sample_organ -- specify the organ the sample came from (to be used in the
% plot title)

function f_show_spectra (fn, xy, sample_organ)

    % Wavelengths
    lambda = [380:10:780].'; 
    
    % Load mean transmittance data and x and y dimensions of the image
    load ([fn '\trans_mean_camera.mat'],'trans_array_m','sizex','sizey');
    
    % Reshape transmittance into 3D matrix
    Tlambda = reshape(trans_array_m, size(trans_array_m,1), sizex, sizey);
    
    figure
      %plot transmittance of pixels as a function of wavelength
      for i = 1:length(xy(:,1))
        plot(lambda,Tlambda(:,xy(i,1),xy(i,2)))
        title(['T({\lambda}) of Pixels, ' sample_organ], 'fontsize', 16, 'fontweight', 'bold')
        xlim([380 780]); ylim([0 1.5])
        xlabel('Wavelength ({\lambda})', 'fontsize', 16, 'fontweight', 'bold')
        ylabel('Transmittance (A.U.)','fontsize', 16, 'fontweight', 'bold')
        hold on
      end
      
end