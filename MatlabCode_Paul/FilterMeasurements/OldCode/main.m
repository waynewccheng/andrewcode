%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurements of the film filters using the spectro-radiometer %
% and the PointGrey camera                                      %
%%%

% Author: Paul Lemaillet, using Wei-Chung's code

close all;

%%
% Formulas
% trans_mean = @(a_m, b_m) a_m ./ b_m;
% trans_std = @(a_m, b_m, a_s, b_s) sqrt((1./b_m).^2.* a_s.^2 + (a_m./b_m.^2).^2.*b_s.^2);

trans_mean = @(s_m, w_m, b_m) (s_m - b_m)./ (w_m - b_m);
trans_std = @(s_m, w_m, b_m, s_s, w_s, b_s) ...
    sqrt((1./(w_m-b_m)).^2 .* s_s.^2 + ...
    ((s_m - w_m)./(w_m-b_m).^2).^2 .* b_s.^2 + ...
    ((b_m - s_m)./(w_m-b_m).^2).^2 .* w_s.^2);

DeltaE = @(L1, a1, b1, L2, a2, b2) sqrt((L1 - L2).^2 + (a1 - a2).^2 + (b1 - b2).^2);

%%
% Open remote control for PR730 and ludl
if exist('ludl') == 0
   ludl = LudlClass('COM14'); 
end

if exist('pr') == 0
   pr = pr730Class('COM15'); 
end

%% 
% Filter informations
name_of_filter = 'Filter_59-b'

% Spectrophotometer information
% Get the speed
pr_status = pr.status;
pos_comma = strfind(pr_status,',');
speed = char((pr_status(pos_comma(9)+1: pos_comma(10)-1)));
spectro_id = char((pr_status(pos_comma(1)+1: pos_comma(2)-1)));

% Camera information
cam = CameraClass9MPSmall_PL;
[CamType, CamMode, CamParam] = cam.info;
cam.close;

% Objective information
obj_type = 'Zeiss 20x Plan-Apochromat';

% Other info
formatOut = 'mm/dd/yy';
date = datestr(now,formatOut);
date = strrep(date, '/', '')
time = datestr(now, 'HH:MM:SS');

% Paths
path_to_rdata = ['C:\Users\wcc\Desktop\MatlabCode_Paul\Data\RawData\' date '\' name_of_filter];
path_to_pdata = ['C:\Users\wcc\Desktop\MatlabCode_Paul\Data\ProcessedData\' date '\' name_of_filter];
path_to_prog = 'C:\Users\wcc\Desktop\MatlabCode_Paul\FilterMeasurements'; 

% Folders for camera measurements
foldername_sample = [name_of_filter '_sample'];  % For the filter spectra
foldername_white = [name_of_filter '_white'];    % For the 100% tranmittance
foldername_black = [name_of_filter '_black'];    % For the 0% tranmittance

folders = {foldername_sample, foldername_white, foldername_black};

% Folder for spectro-radiometer measurements
foldername_spectro = [name_of_filter '_spectro_' speed]; 

% Folder for transmittance results
foldername_transmittance = 'Transmittance'; 

% Folder for CIE coordonates results
foldername_CIE = 'CIE_Coord'; 

% Creates folder to rawdata and processed data
mkdir(path_to_rdata);
mkdir(path_to_pdata);

% Create subfolders
cd(path_to_rdata);
mkdir(foldername_spectro);

cd(path_to_pdata);
mkdir(foldername_transmittance);
mkdir(foldername_CIE);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurements with the spectro-radiometer %
%%%%%%

% Starts the clock
tic

% Measurements with the spectro-radiometer PR730
disp('Measurement with the spectro-radiometer...');

% Turn on the light
ol490.setWhite

% Find ROI on the filter then the ROI for the 100% transmittance
findroi
ROI = [xy; xy_white; xy_black];
Meas_Comments = {'Filter', '100% transmittance', '0% transmittance'};

% Measure a spectrum with the spectro-radiometer
n_meas = 10; % Number of repeated measurements

lambda = zeros(1, 401);
spectra = zeros(n_meas, 401, 3); % 3 for filter, white and black

% Loops through filter, white and black measurements
for j = 1:3 % 1 is filter, 2 is 100% transmittance, 3 is 0% transmittance
    
    % Move to sample ROI
    ludl.setXY(ROI(j, :))
    
    % MODIFY THIS, ASK WEI-CHUNG!!!!
    waitfor(ludl.getStatus == 'B'); % Pauses until the stage is not moving anymore
    
    % Which measurement?
    disp([Meas_Comments{j}, ' measurement'])
    
    % Loops to get n_meas measurments, using the 8x speed on PR730
    for i = 1:n_meas
        tmp = pr.measure;
        if (i == 1) && (j == 1)
            lambda = (tmp.wavelength)';
        end
        spectra(i, :, j) = (tmp.amplitude)';
    end
    
end

clear tmp;

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

% figure(1);
% errorbar(lambda, mean(s_filter), std(s_filter)/sqrt(n_meas) ); hold on;
% errorbar(lambda, mean(s_white), std(s_white)/sqrt(n_meas) );
figure(1);
errorbar(lambda, s_filter_m, s_filter_s); hold on;
errorbar(lambda, s_white_m, s_white_s);
errorbar(lambda, s_black_m, s_black_s);

% Compute the transmittance
t_mean_spectro = trans_mean(s_filter_m, s_white_m, s_black_m);
t_std_spectro = trans_std(s_filter_m, s_white_m, s_black_m, s_filter_s, s_white_s, s_black_s);
trans_spectro = [lambda; t_mean_spectro; t_std_spectro]';

figure(2);
errorbar(lambda, t_mean_spectro, 2 * t_std_spectro);
title('Error bars at k = 2');

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
[LAB, CovLAB, XYZ, CovXYZ] = transmittance2LAB(t_mean_spectro(1:10:401)', t_std_spectro(1:10:401)', 1, 41, ls);

% Uncertainty vectors
SigXYZ = sqrt(diag(CovXYZ))';
SigLAB = sqrt(diag(CovLAB))';

% Save the results
% Change folder to processed data
cd(path_to_pdata);

% Save
save([foldername_CIE '\LAB_Spectro'],'LAB');
save([foldername_CIE '\CovLAB_Spectro'],'CovLAB');
save([foldername_CIE '\XYZ_Spectro'],'XYZ');
save([foldername_CIE '\CovXYZ_Spectro'],'CovXYZ');

% Returns to this code folder
cd(path_to_prog);

%%
% Establishes the maximum intensities, spanning the wavelengths, 
% Move to white measurement position
ludl.setXY(ROI(2, :))

intensity = 100;
ol490.setPeak(550,10,intensity);

% Data storage
int_mean_array = zeros(676,844);
int_std_array = zeros(676,844);
intensities = zeros(41, 2);

% Open camera
cam = CameraClass9MPSmall_PL

% Span the wavelengths
k = 1;
for wl=380:10:780
    
    % prepare light
    intensity = 100;
    ol490.setPeak(wl,10,intensity);
    pause(1);
    
    % First image
    [tmp, int_mean_array, int_std_array] = cam.snap(1, 'filter');
    
    % Loop decreasing the intensity
    while max(max(int_mean_array)) == 255
        intensity = intensity - 1;
        intensity
        ol490.setPeak(wl,10,intensity);
        % pause(1);
        
        [tmp, int_mean_array, int_std_array] = cam.snap(1, 'filter');
    end
    
    % Store intensity value
    intensities(k, 1) = wl;
    intensities(k, 2) = intensity;
    
    k = k + 1;
end
    
% exit
cam.close;

% Plot the results
figure(3);
plot(intensities(:, 1) , intensities(:, 2) );

%%
% Measurements with the camera

% Slightly reduce the intensity
% intensity = 0.95 * intensity; 
intensities(:, 2) = 0.95 * intensities(:, 2);

% Measurements with the camera
numberofshots = 10;

for j = 1:3 % 1 is filter, 2 is 100% transmittance, 3 is 0% transmittance
    
    % Which measurement?
    disp([Meas_Comments{j}, ' measurement'])
    
    % Move platform
    ludl.setXY(ROI(j, :));
    
%     camera2frame_9MP_small_PL([path_to_data '\' folders{j}], numberofshots, ol490, intensity);
camera2frame_9MP_small_PL([path_to_rdata '\' folders{j}], numberofshots, ol490, intensities(:, 2) );
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
[trans_ms, trans_array_m, trans_array_s, sizey, sizex] = frame2transmittance_white_PL(foldername_sample, foldername_white, foldername_black, numberofshots);

% Change folder to processed data
cd(path_to_pdata);

% Save the results
save([foldername_transmittance '\trans_mean_camera'],'trans_array_m','sizey','sizex','-v7.3');
save([foldername_transmittance '\trans_std_camera'],'trans_array_s','sizey','sizex','-v7.3');
save([foldername_transmittance '\trans_ms'],'trans_ms');

% Returns to this code folder
cd(path_to_prog);

% Graphics
figure(4);
errorbar(lambda(1:10:end), t_mean_spectro(1:10:end),  2 * t_std_spectro(1:10:end)); hold on;
errorbar(trans_ms(:, 1), trans_ms(:, 2) , 2 * trans_ms(:, 3) , 'k');
legend('Spectro', 'Whole img');
title('Error bars at k = 2');

figure(5);
errorbar(lambda(1:10:end), t_mean_spectro(1:10:end),  2 * t_std_spectro(1:10:end)); hold on;
errorbar(lambda(1:10:end), trans_array_m(:, 1*1) , 2 * trans_array_s(:, 1*1) , 'k');
legend('Spectro', 'one pixel');
title('Error bars at k = 2');

%% 3: calculate LAB
% Prepares the illuminant
cd('../DataIlluminants')
load ('spec_cied65','spec');
ls = spec(1:10:401,2);

% Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)
[LAB_ms, CovLAB_ms, XYZ_ms, CovXYZ_ms] = transmittance2LAB(trans_ms(:, 2), trans_ms(:, 3), 1, 41, ls);
[LAB_array, CovLAB_array, XYZ_array, CovXYZ_array] = transmittance2LAB(trans_array_m, trans_array_s, sizey, sizex, ls);

% Save the results
% Change folder to processed data
cd(path_to_pdata);

% Save spatial + temporal means and std dev
save([foldername_CIE '\LAB_ms'],'LAB_ms');
save([foldername_CIE '\CovLAB_ms'],'CovLAB_ms');
save([foldername_CIE '\XYZ_ms'],'XYZ_ms');
save([foldername_CIE '\CovXYZ_ms'],'CovXYZ_ms');

% Save values by pixel
save([foldername_CIE '\LAB_array'],'LAB_array');
save([foldername_CIE '\CovLAB_array'],'CovLAB_array');
save([foldername_CIE '\XYZ_array'],'XYZ_array');
save([foldername_CIE '\CovXYZ_array'],'CovXYZ_array');

% Graphics
figure(6);
step = 500;
scatter3(LAB_array(1:step:end, 3), LAB_array(1:step:end, 2), LAB_array(1:step:end, 1), '.b'); hold on;
scatter3(LAB_ms(3), LAB_ms(2), LAB_ms(1), 'r', 'Filled');
scatter3(LAB(3), LAB(2), LAB(1), 'k', 'LineWidth', 2);
xlabel('b'); ylabel('a'); zlabel('L');
legend('Pixel', 'Img mean', 'Spectro');
title(['\Delta E = ' num2str(DeltaE(LAB(1), LAB(2), LAB(3), LAB_ms(1), LAB_ms(2), LAB_ms(3))) ]);

% Returns to this code folder
cd(path_to_prog);

% BEWARE, LAB_array is nb_pix x 3, CovLAB_array is 3 x 3x nb_pixels


% 
% %% 4: reconstruct sRGB image
% rgb = XYZ2sRGB(XYZ);
% save([foldername '\rgb'],'rgb')
% 
% im = reshape(rgb,sizey,sizex,3);
% imwrite(im,[foldername '\truth.tif'])
% 
% % visualize
% clf
% image(im)
% axis image

%%
% Stops the clock
toc

% end
