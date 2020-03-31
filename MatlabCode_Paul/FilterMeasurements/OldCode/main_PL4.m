%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurements of the film filters using the spectro-radiometer %
% and the PointGrey camera                                      %
%%%

% 08-16-19: added the measurements of the OL490 blackground (no intensity)

% New version, saves the spatial averages and corrects for the error in the
% Jacobian from spd2XYZ.m

close all;
clearvars -except ol490 ludl pr

% Starts the clock
tic

%% 1: Initialization
% Open remote control for PR730 and ludl
if exist('ludl') == 0
   ludl = LudlClass('COM14'); 
end

if exist('pr') == 0
   pr = pr730Class('COM15'); 
end

% Filter informations
name_of_filter = 'Filter_KW25BW10'

% Gathers and stores the measurements informations, creates the folders
[foldername_sample, foldername_white, foldername_black,...
    foldername_spectro, foldername_transmittance, foldername_CIE,...
    path_to_rdata, path_to_pdata, path_to_prog] = init(pr, name_of_filter);

folders = {foldername_sample, foldername_white, foldername_black};

%% 2: Spectrophotometer measurements
% Number of repeated measurements
n_meas = 10; 

% Call of measurements by spectrometer
[lambda, spectra, spectra_background, ROI] = f_meas_spectro_PL2(ol490, pr, ludl, n_meas, 0);

% Close remote control for PR730
pr.close;
clear pr;

% Compute mean value and error with OL490 on
s_filter = spectra(:, :, 1);
s_white = spectra(:, :, 2);
s_black = spectra(:, :, 3);

s_filter_m = mean(s_filter);
s_white_m = mean(s_white);
s_black_m = mean(s_black);
s_filter_s = std(s_filter)./sqrt(n_meas);
s_white_s = std(s_white)./sqrt(n_meas);
s_black_s = std(s_black)./sqrt(n_meas);

% Compute mean value and error with OL490 off (background)
s_filter_background = spectra_background(:, :, 1);
s_white_background = spectra_background(:, :, 2);
% s_black_background = spectra_background(:, :, 3);

s_filter_background_m = mean(s_filter_background);
s_white_background_m = mean(s_white_background);
% s_black_background_m = mean(s_black_background);
s_filter_background_s = std(s_filter_background)./sqrt(n_meas);
s_white_background_s = std(s_white_background)./sqrt(n_meas);
% s_black_background_s = std(s_black_background)./sqrt(n_meas);

% Compute the transmittance
% [t_mean_spectro, t_std_spectro] = f_transmittance(s_filter_m, s_white_m, s_black_m, s_filter_s, s_white_s, s_black_s);
% [t_mean_spectro, t_std_spectro] = f_transmittance_PL2(s_filter_m, s_white_m, s_black_m,...
%     s_filter_background_m, s_white_background_m, s_black_background_m, s_filter_s, s_white_s, s_black_s,...
%     s_filter_background_s, s_white_background_s, s_black_background_s);

% [t_mean_spectro, t_std_spectro] = f_transmittance_PL2(s_filter_m, s_white_m, s_black_m,...
%     s_filter_background_m, s_white_background_m, s_filter_s, s_white_s, s_black_s,...
%     s_filter_background_s, s_white_background_s);

% TEST
[t_mean_spectro, t_std_spectro] = f_transmittance_PL3(s_filter_m, s_white_m,...
    s_filter_background_m, s_white_background_m, s_filter_s, s_white_s,...
    s_filter_background_s, s_white_background_s);
% TEST

trans_spectro = [lambda; t_mean_spectro; t_std_spectro]';

% Save the data
cd(path_to_rdata);
save([foldername_spectro '\spectro_meas'],'spectra');
save([foldername_spectro '\spectro_meas_background'],'spectra_background');

cd(path_to_pdata);
save([foldername_transmittance '\trans_spectro'],'trans_spectro');

%% 3: Calculate LAB: T -> XYZ -> LAB

% Returns to this code folder to get the illuminant
cd(path_to_prog);

% Prepares the illuminant
cd('../DataIlluminants')
load ('spec_cied65','spec');
ls = spec(1:10:401,2);

% Compute LAB for the spectro
[LAB_spectro, CovLAB_spectro, XYZ_spectro, CovXYZ_spectro] = transmittance2LAB_PL2(t_mean_spectro(1:10:401)', t_std_spectro(1:10:401)', 1, 41, ls);

% Save the results
cd(path_to_pdata);
save([foldername_CIE '\LAB_Spectro'],'LAB_spectro');
save([foldername_CIE '\CovLAB_Spectro'],'CovLAB_spectro');
save([foldername_CIE '\XYZ_Spectro'],'XYZ_spectro');
save([foldername_CIE '\CovXYZ_Spectro'],'CovXYZ_spectro');

%% 4: Establishes the maximum shutter time in steps of 1sec (mode = 1), spanning the wavelengths 
numberofshots = 1;
bandwidth = 10;
% shutter_tbl = shutter_cam(ol490, ludl, ROI, numberofshots, bandwidth, 0, 1);  
% intensities = intensity_ol490(ol490, ludl, ROI, numberofshots, bandwidth);  

%% Refine step 0.1sec (mode = 2)
% shutter_tbl = shutter_cam(ol490, ludl, ROI, numberofshots, bandwidth, shutter_tbl(:, 2), 2); 

%% Refine step 0.01sec (mode = 3)
% shutter_tbl = shutter_cam(ol490, ludl, ROI, numberofshots, bandwidth, shutter_tbl(:, 2), 3); 

% % Returns to this code folder to save the shutter times
% cd(path_to_prog);
% cd('../PointGreySpec');
% save('Shutter_tbl','shutter_tbl');

%% On with the intensities optimization
cd(path_to_prog);

% Get the shutter values
cd('../PointGreySpec');
load('Shutter_tbl','shutter_tbl');

intensities = intensity_ol490(ol490, ludl, ROI, numberofshots, bandwidth, shutter_tbl(:, 2)); 
%% 5: Measurements with the camera

% Slightly reduce the intensity to avoid saturation
intensities(:, 2) = 0.95 * intensities(:, 2);
% exposure =  2.413;

% Measurements with the camera
numberofshots = 10;
Meas_Comments = {'Filter', '100% transmittance', '0% transmittance'};

for j = 1:3 % 1 is filter, 2 is 100% transmittance, 3 is 0% transmittance
    
    % Which measurement?
    disp([Meas_Comments{j}, ' measurement'])
    
    % Move platform
    ludl.setXY(ROI(j, :));
    
    % Pauses until the stage is not moving anymore
    while ludl.getStatus ~= 'N'
        pause(0.01);
    end
        
    % Acquire data
    % Not saving measurements of the )0% transmittance sample (black tape) with light intensity set at 0
    if j ~= 3 
        bg_save = 1;
    else
        bg_save = 0;
    end
    
    camera2frame_9MP_small_PL3([path_to_rdata '\' folders{j}], numberofshots, ol490, int8(intensities(:, 2)), bandwidth, shutter_tbl(:, 2), bg_save);
    
end

% Close remote control for ludl
ludl.close;
clear ludl;
   
%% 6: Calculate transmittance for the camera measurements
% Compute the tranmittance based on the spatial average of numberofshots
% images and the coreesponding stat stored in img_ms
% , trans_ms is the spatial average with temporal mean and std
% dev of the transmittance, trans_array_m and trans_array_s are pixel by
% pixel values
cd(path_to_rdata);
% [trans_ms, trans_array_m, trans_array_s, sizey, sizex] = frame2transmittance_white_PL2(foldername_sample, foldername_white, foldername_black, numberofshots);
[trans_ms, trans_array_m, trans_array_s, sizey, sizex] = frame2transmittance_white_PL3(foldername_sample, foldername_white, foldername_black, numberofshots);

% Save the results
cd(path_to_pdata);
save([foldername_transmittance '\trans_mean_camera'],'trans_array_m','sizey','sizex','-v7.3');
save([foldername_transmittance '\trans_std_camera'],'trans_array_s','sizey','sizex','-v7.3');
save([foldername_transmittance '\trans_ms'],'trans_ms');

%% 7: Calculate LAB for the camera measurements
% Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)
[LAB_cam, CovLAB_cam, XYZ_cam, CovXYZ_cam] = transmittance2LAB_PL2(trans_ms(:, 2), trans_ms(:, 3), 1, 41, ls);
[LAB_array, CovLAB_array, XYZ_array, CovXYZ_array] = transmittance2LAB_PL2(trans_array_m, trans_array_s, sizey, sizex, ls);

% Save the results
cd(path_to_pdata);

% Save spatial + temporal means and std dev
save([foldername_CIE '\LAB_cam'],'LAB_cam');
save([foldername_CIE '\CovLAB_cam'],'CovLAB_cam');
save([foldername_CIE '\XYZ_cam'],'XYZ_cam');
save([foldername_CIE '\CovXYZ_cam'],'CovXYZ_cam');

% Save values by pixel
save([foldername_CIE '\LAB_array'],'LAB_array');
save([foldername_CIE '\CovLAB_array'],'CovLAB_array');
save([foldername_CIE '\XYZ_array'],'XYZ_array');
save([foldername_CIE '\CovXYZ_array'],'CovXYZ_array');

%% Graphics

% Signals
figure(1);
errorbar(lambda, s_filter_m, s_filter_s); hold on;
errorbar(lambda, s_white_m, s_white_s);
errorbar(lambda, s_black_m, s_black_s);

% Camera setting: Intensity parameter vs wavelength
figure(2);
plot(intensities(:, 1) , intensities(:, 2) );

% Tranmittance spectra
figure(3);
errorbar(trans_spectro(:, 1), trans_spectro(:, 2), 2 * trans_spectro(:, 3));
title('Error bars at k = 2');

figure(4);
errorbar(trans_spectro(1:10:end, 1), trans_spectro(1:10:end, 2), 2 * trans_spectro(1:10:end, 3)); hold on;
errorbar(trans_ms(:, 1), trans_ms(:, 2) , 2 * trans_ms(:, 3) , 'k');
axis([350 800 -0.1 1]);
legend('Spectro', 'Whole img');
title('Error bars at k = 2');

figure(5);
errorbar(trans_spectro(1:10:end, 1), trans_spectro(1:10:end, 2), 2 * trans_spectro(1:10:end, 3)); hold on;
errorbar(trans_spectro(1:10:end, 1), trans_array_m(:, 1*1) , 2 * trans_array_s(:, 1*1) , 'k');
legend('Spectro', 'one pixel');
title('Error bars at k = 2');

% CIELAB space
figure(6);
step = 500;
[DE, s_DE] = f_deltaE(LAB_spectro, LAB_cam, CovLAB_spectro, CovLAB_cam);
scatter3(LAB_array(1:step:end, 3), LAB_array(1:step:end, 2), LAB_array(1:step:end, 1), '.b'); hold on;
scatter3(LAB_cam(3), LAB_cam(2), LAB_cam(1), 'r', 'Filled');
scatter3(LAB_spectro(3), LAB_spectro(2), LAB_spectro(1), 'k', 'LineWidth', 2);
xlabel('b'); ylabel('a'); zlabel('L');
legend('Pixel', 'Img mean', 'Spectro');
title(['\Delta E = ' num2str(DE) ' \sigma_{\Delta E} = ' num2str(s_DE)]);

% Beam profile
cd(path_to_rdata);
fnin_m = sprintf('%s/vim_mean_array',foldername_white);
load(fnin_m,'vim_mean_array');
    
vt = vim_mean_array;
figure('units','normalized','outerposition',[0 0 1 1]);
wl_array = 380:10:780;
for wl = 1:41
    subplot(6,7,wl)
    
    vvname = sprintf('%s(wl,:,:)','vt');
    vv = eval(vvname);
    im = squeeze(vv);
    imagesc(im)
    axis off
    axis image
    colorbar
    title(sprintf('%d',wl_array(wl)))
end

% Tranmittance images
vt = reshape(trans_array_m, size(trans_array_m, 1), sizey, sizex);
figure('units','normalized','outerposition',[0 0 1 1]);
wl_array = 380:10:780;
for wl = 1:41
    subplot(6,7,wl)
    
    vvname = sprintf('%s(wl,:,:)','vt');
    vv = eval(vvname);
    im = squeeze(vv);
    imagesc(im)
    axis off
    axis image
    colorbar
    title(sprintf('%d',wl_array(wl)))
end

% Returns to this code folder
cd(path_to_prog);

%%
% Stops the clock
toc

% end
