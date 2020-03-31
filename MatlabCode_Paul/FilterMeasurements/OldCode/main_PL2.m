%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurements of the film filters using the spectro-radiometer %
% and the PointGrey camera                                      %
%%%

% Author: Paul Lemaillet, using Wei-Chung's code
% New version, saves the spatial averages and corrects for the error in the
% Jacobian from spd2XYZ.m

close all;
clearvars -except ol490 pr ludl

% Starts the clock
tic

%%
% Formulas
% trans_mean = @(s_m, w_m, b_m) (s_m - b_m)./ (w_m - b_m);
% trans_std = @(s_m, w_m, b_m, s_s, w_s, b_s) ...
%     sqrt((1./(w_m-b_m)).^2 .* s_s.^2 + ...
%     ((s_m - w_m)./(w_m-b_m).^2).^2 .* b_s.^2 + ...
%     ((b_m - s_m)./(w_m-b_m).^2).^2 .* w_s.^2);

% DeltaE = @(LAB_1, LAB_2) sqrt((LAB_1(1) - LAB_2(1)).^2 + ...    % L
%     (LAB_1(2) - LAB_2(2)).^2 + ...                              % a
%     (LAB_1(3) - LAB_2(3)).^2);                                  % b
% 
% Sigma_DeltaE = @(LAB_1, LAB_2, CovLAB_1, CovLAB_2) sqrt(...
%     1./DeltaE(LAB_1, LAB_2).^2*[(LAB_1(1) - LAB_2(1)) (LAB_1(2) - LAB_2(2)) (LAB_1(3) - LAB_2(3)) -(LAB_1(1) - LAB_2(1)) -(LAB_1(2) - LAB_2(2)) -(LAB_1(3) - LAB_2(3))]...
%     *blkdiag(CovLAB_1, CovLAB_2)*[(LAB_1(1) - LAB_2(1)) (LAB_1(2) - LAB_2(2)) (LAB_1(3) - LAB_2(3)) -(LAB_1(1) - LAB_2(1)) -(LAB_1(2) - LAB_2(2)) -(LAB_1(3) - LAB_2(3))]'...
%     );

%%
% Open remote control for PR730 and ludl
if exist('ludl') == 0
   ludl = LudlClass('COM14'); 
end

if exist('pr') == 0
   pr = pr730Class('COM15'); 
end

%% 1: Initialization
% Filter informations
name_of_filter = 'Filter_56'

% % Spectrophotometer information
% % Get the speed
% pr_status = pr.status;
% pos_comma = strfind(pr_status,',');
% speed = char((pr_status(pos_comma(9)+1: pos_comma(10)-1)));
% spectro_id = char((pr_status(pos_comma(1)+1: pos_comma(2)-1)));
% 
% % Camera information
% cam = CameraClass9MPSmall_PL2;
% [CamType, CamMode, CamParam] = cam.info;
% cam.close;
% 
% % Objective information
% obj_type = 'Zeiss 20x Plan-Apochromat';
% 
% % Other info
% formatOut = 'mm/dd/yy';
% date = datestr(now,formatOut);
% date = strrep(date, '/', '')
% time = datestr(now, 'HH:MM:SS');
% 
% % Paths
% path_to_rdata = ['D:\Data_Paul\RawData\' date '\' name_of_filter];
% path_to_pdata = ['D:\Data_Paul\ProcessedData\' date '\' name_of_filter];
% path_to_prog = 'C:\Users\wcc\Desktop\MatlabCode_Paul\FilterMeasurements'; 
% 
% % Folders for camera measurements
% foldername_sample = [name_of_filter '_sample'];  % For the filter spectra
% foldername_white = [name_of_filter '_white'];    % For the 100% tranmittance
% foldername_black = [name_of_filter '_black'];    % For the 0% tranmittance
% 
% folders = {foldername_sample, foldername_white, foldername_black};
% 
% % Folder for spectro-radiometer measurements
% foldername_spectro = [name_of_filter '_spectro_' speed]; 
% 
% % Folder for transmittance results
% foldername_transmittance = 'Transmittance'; 
% 
% % Folder for CIE coordonates results
% foldername_CIE = 'CIE_Coord'; 

% Gathers and stores the measurements informations, creates the folders
[foldername_sample, foldername_white, foldername_black,...
    foldername_spectro, foldername_transmittance, foldername_CIE,...
    path_to_rdata, path_to_pdata, path_to_prog] = init(pr, name_of_filter);

folders = {foldername_sample, foldername_white, foldername_black};

% % Creates folder to rawdata and processed data
% mkdir(path_to_rdata);
% mkdir(path_to_pdata);
% 
% % Create subfolders
% cd(path_to_rdata);
% mkdir(foldername_spectro);
% 
% cd(path_to_pdata);
% mkdir(foldername_transmittance);
% mkdir(foldername_CIE);

%% 2: Spectrophotometer measurements

% % Measurements with the spectro-radiometer PR730
% disp('Measurement with the spectro-radiometer...');
% 
% % Turn on the light
% ol490.setWhite
% 
% % Find ROI on the filter then the ROI for the 100% transmittance
% [xy, xy_white, xy_black] = findroi_PL2(ol490, ludl);
% ROI = [xy; xy_white; xy_black];
% Meas_Comments = {'Filter', '100% transmittance', '0% transmittance'};

% Measure a spectrum with the spectro-radiometer
n_meas = 10; % Number of repeated measurements
% n_meas = 2; % Number of repeated measurements

% lambda = zeros(1, 401);
% spectra = zeros(n_meas, 401, 3); % 3 for filter, white and black
% 
% % Loops through filter, white and black measurements
% for j = 1:3 % 1 is filter, 2 is 100% transmittance, 3 is 0% transmittance
%     
%     % Move to sample ROI
%     ludl.setXY(ROI(j, :))
%     
%     % Pauses until the stage is not moving anymore
%     waitfor(ludl.getStatus == 'B'); 
%     
%     % Which measurement?
%     disp([Meas_Comments{j}, ' measurement'])
%     
%     % Loops to get n_meas measurements, using the 8x speed on PR730
%     for i = 1:n_meas
%         tmp = pr.measure;
%         if (i == 1) && (j == 1)
%             lambda = (tmp.wavelength)';
%         end
%         spectra(i, :, j) = (tmp.amplitude)';
%     end
%     
% end
% 
% clear tmp;

[lambda, spectra, ROI] = f_meas_spectro(ol490, pr, ludl, n_meas);

% Compute mean value and error
s_filter = spectra(:, :, 1);
s_white = spectra(:, :, 2);
s_black = spectra(:, :, 3);

s_filter_m = mean(s_filter);
s_white_m = mean(s_white);
s_black_m = mean(s_black);
s_filter_s = std(s_filter)./sqrt(n_meas);
s_white_s = std(s_white)./sqrt(n_meas);
s_black_s = std(s_black)./sqrt(n_meas);

% Compute the transmittance
[t_mean_spectro, t_std_spectro] = f_transmittance(s_filter_m, s_white_m, s_black_m, s_filter_s, s_white_s, s_black_s);

% t_mean_spectro = trans_mean(s_filter_m, s_white_m, s_black_m);
% t_std_spectro = trans_std(s_filter_m, s_white_m, s_black_m, s_filter_s, s_white_s, s_black_s);
trans_spectro = [lambda; t_mean_spectro; t_std_spectro]';

% Save the data
cd(path_to_rdata);
save([foldername_spectro '\spectro_meas'],'spectra');

cd(path_to_pdata);
save([foldername_transmittance '\trans_spectro'],'trans_spectro');

% Close remote control for PR730
pr.close;
clear pr;

% Returns to this code folder
cd(path_to_prog);

%% 
% Calculate LAB: T -> XYZ -> LAB

% Prepares the illuminant
cd('../DataIlluminants')
load ('spec_cied65','spec');
ls = spec(1:10:401,2);

% Compute LAB for the spectro
[LAB_spectro, CovLAB_spectro, XYZ_spectro, CovXYZ_spectro] = transmittance2LAB_PL2(t_mean_spectro(1:10:401)', t_std_spectro(1:10:401)', 1, 41, ls);

% Save the results
% Change folder to processed data
cd(path_to_pdata);

% Save
save([foldername_CIE '\LAB_Spectro'],'LAB_spectro');
save([foldername_CIE '\CovLAB_Spectro'],'CovLAB_spectro');
save([foldername_CIE '\XYZ_Spectro'],'XYZ_spectro');
save([foldername_CIE '\CovXYZ_Spectro'],'CovXYZ_spectro');

% Returns to this code folder
cd(path_to_prog);

%%
% % Establishes the maximum intensities, spanning the wavelengths, 
% % Move to white measurement position
% ludl.setXY(ROI(2, :))
% 
% intensity = 100;
% ol490.setPeak(550,10,intensity);
% 
% % Data storage
% int_mean_array = zeros(676,844);
% int_std_array = zeros(676,844);
% intensities = zeros(41, 2);
% 
% % Open camera
% cam = CameraClass9MPSmall_PL2
% 
% % Span the wavelengths
% k = 1;
% for wl=380:10:780
%     
%     % prepare light
%     intensity = 100;
%     ol490.setPeak(wl,10,intensity);
%     pause(1);
%     
%     % First image
%     [tmp, int_mean_array, int_std_array] = cam.snap(1, 'filter');
%     
%     % Loop decreasing the intensity
%     while max(max(int_mean_array)) == 255
%         intensity = intensity - 1;
%         intensity
%         ol490.setPeak(wl,10,intensity);
%         % pause(1);
%         
%         [tmp, int_mean_array, int_std_array] = cam.snap(1, 'filter');
%     end
%     
%     % Store intensity value
%     intensities(k, 1) = wl;
%     intensities(k, 2) = intensity;
%     
%     k = k + 1;
% end
%     
% % exit
% cam.close;

% % Plot the results
% figure(3);
% plot(intensities(:, 1) , intensities(:, 2) );

% intensities = intensity_cam(ol490, ludl, ROI, 2);   % numberofshots = 2 because cam.snap remove the first measurment that was always saturating the camera at 380 nm for the white measurment (and I don;t know why)
%                                                     % put back to 1 if the
%                                                     % bug is fixed

intensities = intensity_cam(ol490, ludl, ROI, 1);  
                                                    
%%
% Measurements with the camera

% Slightly reduce the intensity to avoid saturation
intensities(:, 2) = 0.95 * intensities(:, 2);

% Measurements with the camera
numberofshots = 10;
Meas_Comments = {'Filter', '100% transmittance', '0% transmittance'};

for j = 1:3 % 1 is filter, 2 is 100% transmittance, 3 is 0% transmittance
    
    % Which measurement?
    disp([Meas_Comments{j}, ' measurement'])
    
    % Move platform
    ludl.setXY(ROI(j, :));
    
    % Acquire data
    camera2frame_9MP_small_PL2([path_to_rdata '\' folders{j}], numberofshots, ol490, int8(intensities(:, 2)) );
    
end

% Returns to this code folder
cd(path_to_prog)

% Close remote control for ludl
ludl.close;

clear ludl;
   
%% 2: Calculate transmittance
% Change folder to rawdata
cd(path_to_rdata);

% Compute the tranmittance based on the spatial average of numberofshots
% images and the coreesponding stat stored in img_ms
% , trans_ms is the spatial average with temporal mean and std
% dev of the transmittance, trans_array_m and trans_array_s are pixel by
% pixel values
[trans_ms, trans_array_m, trans_array_s, sizey, sizex] = frame2transmittance_white_PL2(foldername_sample, foldername_white, foldername_black, numberofshots);

% Change folder to processed data
cd(path_to_pdata);

% Save the results
save([foldername_transmittance '\trans_mean_camera'],'trans_array_m','sizey','sizex','-v7.3');
save([foldername_transmittance '\trans_std_camera'],'trans_array_s','sizey','sizex','-v7.3');
save([foldername_transmittance '\trans_ms'],'trans_ms');

% Returns to this code folder
cd(path_to_prog);

%% 3: calculate LAB
% Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)
[LAB_cam, CovLAB_cam, XYZ_cam, CovXYZ_cam] = transmittance2LAB_PL2(trans_ms(:, 2), trans_ms(:, 3), 1, 41, ls);
[LAB_array, CovLAB_array, XYZ_array, CovXYZ_array] = transmittance2LAB_PL2(trans_array_m, trans_array_s, sizey, sizex, ls);

% Save the results
% Change folder to processed data
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
figure(3);
plot(intensities(:, 1) , intensities(:, 2) );

% Tranmittance spectra
figure(2);
% errorbar(lambda, t_mean_spectro, 2 * t_std_spectro);
errorbar(trans_spectro(:, 1), trans_spectro(:, 2), 2 * trans_spectro(:, 3));
title('Error bars at k = 2');

figure(4);
% errorbar(lambda(1:10:end), t_mean_spectro(1:10:end),  2 * t_std_spectro(1:10:end)); hold on;
errorbar(trans_spectro(1:10:end, 1), trans_spectro(1:10:end, 2), 2 * trans_spectro(1:10:end, 3)); hold on;
errorbar(trans_ms(:, 1), trans_ms(:, 2) , 2 * trans_ms(:, 3) , 'k');
legend('Spectro', 'Whole img');
title('Error bars at k = 2');

figure(5);
% errorbar(lambda(1:10:end), t_mean_spectro(1:10:end),  2 * t_std_spectro(1:10:end)); hold on;
errorbar(trans_spectro(1:10:end, 1), trans_spectro(1:10:end, 2), 2 * trans_spectro(1:10:end, 3)); hold on;
errorbar(trans_spectro(1:10:end, 1), trans_array_m(:, 1*1) , 2 * trans_array_s(:, 1*1) , 'k');
legend('Spectro', 'one pixel');
title('Error bars at k = 2');

% CIELAB space
figure(6);
step = 500;
% DE = DeltaE(LAB_spectro, LAB_cam);
% s_DE = Sigma_DeltaE(LAB_spectro, LAB_cam, CovLAB_spectro, CovLAB_cam);
[DE, s_DE] = f_deltaE(LAB_spectro, LAB_cam, CovLAB_spectro, CovLAB_cam);
scatter3(LAB_array(1:step:end, 3), LAB_array(1:step:end, 2), LAB_array(1:step:end, 1), '.b'); hold on;
scatter3(LAB_cam(3), LAB_cam(2), LAB_cam(1), 'r', 'Filled');
scatter3(LAB_spectro(3), LAB_spectro(2), LAB_spectro(1), 'k', 'LineWidth', 2);
xlabel('b'); ylabel('a'); zlabel('L');
legend('Pixel', 'Img mean', 'Spectro');
title(['\Delta E = ' num2str(DE) ' \sigma_{\Delta E} = ' num2str(s_DE)]);

% Returns to this code folder
cd(path_to_prog);

%%
% Stops the clock
toc

% end
