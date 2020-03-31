%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurements of the tissue slides

% 11-14-19: First version 

close all;
clearvars -except ol490 ludl

% Starts the clock
tic

%% 1: Initialization
% Open remote control for PR730 and ludl
if exist('ludl') == 0
   ludl = LudlClass('COM14'); 
end

% Filter informations
name_of_sample = 'BioMax_T069_B073'

% Gathers and stores the measurements informations, creates the folders
[p_sample, p_white, p_trans, p_cie, p_er, p_st]  = init_tissues(name_of_sample);
p_sw = {p_sample, p_white};

%% 2: ROI
[xy, xy_white] = findroi_PL3(ol490, ludl, 'g'); % 'g' for green light
ROI = [xy; xy_white];

%% 3: Camera: Establishes/get the maximum shutter time, spanning the wavelengths; Set the OL490 max intensities 
numberofshots = 1;
bandwidth = 10;

% Camera Shutter time
shutter_tbl = f_shutter_time(ol490, ludl, ROI, numberofshots, bandwidth, p_st, 0); % 0 just loads the shutter times established previously, set 1 to establish them

% OL490 intensity estimation
intensities = intensity_ol490(ol490, ludl, ROI, numberofshots, bandwidth, shutter_tbl(:, 2)); 

%% 4: Camera: Measurements

% Slightly reduce the intensity to avoid saturation
intensities(:, 2) = 0.95 * intensities(:, 2);

% Measurements with the camera
numberofshots = 10;
Meas_Comments = {'Sample', '100% transmittance'};

for j = 1:2 % 1 is sample, 2 is 100% transmittance
    
    % Which measurement?
    disp([Meas_Comments{j}, ' measurement'])
    
    % Move platform
    ludl.setXY(ROI(j, :));
    
    % Pauses until the stage is not moving anymore
    while ludl.getStatus ~= 'N'
        pause(0.01);
    end
    
    camera2frame_9MP_small_PL4(p_sw{j}, numberofshots, ol490, int8(intensities(:, 2)), bandwidth, shutter_tbl(:, 2));
   
end

% Close remote control for ludl
ludl.close;
clear ludl;
   
%% 5: Camera: Calculate transmittance
% Compute the tranmittance based on the temporal mean/std dev over numberofshots
% trans_array_m and trans_array_s are pixel by pixel values
[trans_array_m, trans_array_s, sizey, sizex] = frame2transmittance_white_PL5(p_sample, p_white, numberofshots);

% Save the results
save([p_trans '\trans_mean_camera'],'trans_array_m','sizey','sizex','-v7.3');
save([p_trans '\trans_std_camera'],'trans_array_s','sizey','sizex','-v7.3');

%% 6: Camera: Calculate LAB

% Prepares the illuminant
cd('C:\Users\wcc\Desktop\MatlabCode_Paul\DataIlluminants')
load ('spec_cied65','spec');
ls = spec(1:10:401,2);

% Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)
[LAB_array, CovLAB_array, XYZ_array, CovXYZ_array] = transmittance2LAB_PL2(trans_array_m, trans_array_s, sizey, sizex, ls, 'y'); % 'y' top trim the max tranmsittance to 1

% Save values by pixel
save([p_cie '\LAB_array'],'LAB_array');
save([p_cie '\CovLAB_array'],'CovLAB_array');
save([p_cie '\XYZ_array'],'XYZ_array');
save([p_cie '\CovXYZ_array'],'CovXYZ_array');

%% 4: Reconstruct sRGB image

% Rescale XYZ so that Y of D65 illuminant is 1
Y0 = 100;

% Convert to sRGB and save
rgb = XYZ2sRGB(XYZ_array/Y0);
save([p_er '\rgb'],'rgb')

% Tiff
im = reshape(rgb,sizey,sizex,3);
imwrite(im,[p_er '\truth.tif'])

% Visualize
figure
image(im);
axis image

% If some pixels are NaN
im_nonan = im;
mask = isnan(im_nonan);

if ~isempty(mask)
    im_nonan(mask) = 0;
    k=[1 1 1; 1 0 1; 1 1 1]/8;
    
    % Average of 8 neighbor pixels
    for i = 1:3
        im_conv_avg = conv2(im_nonan(:, :, i) ,k,'same');
        tmp_conv = im_nonan(:, :, i);
        tmp_conv(mask(:, :, i)) = im_conv_avg(mask(:, :, i));
        im_nonan(:, :, i) = tmp_conv;
    end
    
    % Save
    imwrite(im_nonan,[p_er '\truth_nonan.tif'])
    
    % sRGB
    rgb_nonan = reshape(im_nonan, sizey*sizex, 3);
    save([p_er '\rgb_nonan'],'rgb_nonan')
    
    % Graphic
    figure
    image(im_nonan);
    axis image
end

%% Graphics

% Camera setting: Intensity parameter vs wavelength
figure;
plot(intensities(:, 1) , intensities(:, 2) );

% CIELAB space
figure;
step = 100;
c = double(lab2rgb(LAB_array,'OutputType','uint8'))/255;
scatter3(LAB_array(1:step:end, 3), LAB_array(1:step:end, 2), LAB_array(1:step:end, 1), 5, c(1:step:end, :), 'filled');
xlabel('b^*'); ylabel('a^*'); zlabel('L^*');
legend('Pixels');

% Beam profile
fnin_m = sprintf('%s/vim_mean_array', p_white);
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

%%
% Stops the clock
toc

% end
