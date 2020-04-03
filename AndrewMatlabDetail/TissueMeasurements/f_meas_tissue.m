% 12-06-19: correction for potential Inf values in the Transmittance that
% appear at 780nm due to a division by 0
% this corrects for the NaN values that appeared in the rgb images, no
% interpolation using nearest neighbor values of [R, G, B] needed

% 09-27-19: no more cd, using direct paths instead

% 09-26-19: first implementation based on main_filters (in FilterMeasurements folder)
% The spectrometer measurements and storage of data were removed compared
% to main_filters

function f_meas_tissue(name_of_sample, ol490, ludl, n_meas, ROI)

    close all;

%     %% 1: Initialization
% 
    % Gathers and stores the measurements informations, creates the folders
%     [p_sample, p_white, p_trans, p_cie, p_er, p_st]  = f_init_tissues(name_of_sample);
%     p_sw = {p_sample, p_white};
% 
%     %% 2: Camera: Get the maximum shutter time, spanning the wavelengths; Set the OL490 max intensities 
%     bandwidth = 10;
% 
%     % Move to 100% ttranmittance area
%     ludl.setXY(ROI(2, :));
%     
%     % Camera settings
%     [shutter_tbl, gain_tbl] = f_camera_settings(ol490, bandwidth, p_st, 'r');
%     
%     % OL490 intensity estimation
%     intensities = f_intensity_ol490(ol490, bandwidth, shutter_tbl(:, 2), gain_tbl(:, 2) );
% 
%     %% 3: Camera: Measurements
% 
%     % Slightly reduce the intensity to avoid saturation
%     intensities(:, 2) = 0.9 * intensities(:, 2);
% 
%     % Measurements with the camera
%     numberofshots = n_meas;
%     Meas_Comments = {'Sample', '100% transmittance'};
% 
%     for j = 1:2 % 1 is sample, 2 is 100% transmittance
% 
%         % Which measurement?
%         disp([Meas_Comments{j}, ' measurement'])
% 
%         % Move platform
%         ludl.setXY(ROI(j, :));
% 
%         % Pauses until the stage is not moving anymore
%         while ludl.getStatus ~= 'N'
%             pause(0.01);
%         end
% 
%         f_camera2frame_9MP_small(p_sw{j}, numberofshots, ol490, intensities(:, 2), bandwidth, shutter_tbl(:, 2), gain_tbl(:, 2) );
% 
%     end

    %% 4: Camera: Calculate transmittance
    % Compute the tranmittance based on the temporal mean/std dev over numberofshots
    
    % Declare Paths to collect Raw Data from and write Processed Data to
    name_of_sample = 'Camelyon16_T13-15492_Tag3' %name of the sample
    p_rdata = ['D:\DigitalPathology\ColorDetail\ImageData\031320\RawData\' name_of_sample]; %path for the raw data
    p_pdata = ['D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\' name_of_sample]; %path for the processed data
    
    p_sample = [p_rdata '\' name_of_sample '_sample']; %where to find the raw data for the sample
    p_white = [p_rdata '\' name_of_sample '_white']; %where to find the raw data for the white image
    p_trans = [p_pdata '\Transmittance']; %where the transmittance data will go
    p_cie = [p_pdata '\CIE_Coord']; %where the CIE data will go
    p_er = [p_pdata '\EndResults']; %where the End Results will go
    
    %Create the processed data folders
    mkdir(p_pdata); %Processed data larger folder
    mkdir(p_trans); %Processed data sub-folders
    mkdir(p_cie);
    mkdir(p_er);

    numberofshots = 41;
    
    % Compute Transmittance value from raw data
    [trans_array_m, trans_array_s, sizey, sizex] = f_frame2transmittance_white(p_sample, p_white, numberofshots); 
    
    % Corrects for potential Inf values in the transmittance
    [trans_array_m, trans_array_s] = f_interp_infTval(trans_array_m, trans_array_s);
    
    %% 5: Camera: Calculate LAB

    % Prepares the illuminant
    cd('D:\DigitalPathology\ColorDetail\Matlab_Color\Scripts\Data Illuminants'); % Change Directory to 'Data Illuminants' folder
    load ('spec_cied65','spec'); % Load specs for D65
    ls = spec(1:10:401,2); % Load light source information from specs

    cd('D:\DigitalPathology\ColorDetail\Matlab_Color\Scripts\TissueMeasurements') % Change Directory back to 'Tissue Measurements' folder
    % Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)
    [LAB_array, CovLAB_array, XYZ_array, CovXYZ_array] = f_transmittance2LAB(trans_array_m, trans_array_s, sizey, sizex, ls, 'y'); % 'y' top trim the max tranmsittance to 1

    % Save transmittance values and the CIELAB/CIEXYZ values by pixel
    save([p_trans '\trans_mean_camera'],'trans_array_m','sizey','sizex','-v7.3');
    save([p_cie '\LAB_array'],'LAB_array');
    save([p_cie '\XYZ_array'],'XYZ_array');
   
    if ~isequal(numberofshots, 1)
        save([p_trans '\trans_std_camera'],'trans_array_s','sizey','sizex','-v7.3');
        save([p_cie '\CovLAB_array'],'CovLAB_array');
        save([p_cie '\CovXYZ_array'],'CovXYZ_array');
    end

    %% 6: Reconstruct sRGB image

    % Rescale XYZ so that Y of D65 illuminant is 1
    Y0 = 100;

    % Convert to sRGB and save
    rgb = f_XYZ2sRGB(XYZ_array/Y0);
    save([p_er '\rgb'],'rgb')

    % Create tiff from sRGB values
    im = reshape(rgb,sizey,sizex,3);
    imwrite(im,[p_er '\truth.tif'])

    % Visualize image
    figure
    image(im);
    axis image

    % Check if some pixels are still NaN
    nan_test = find(isnan(im) ~=0);

%     if ~isempty(mask)
%         im_nonan(mask) = 0;
%         k=[1 1 1; 1 0 1; 1 1 1]/8;
% 
%         % Average of 8 neighbor pixels
%         for i = 1:3
%             im_conv_avg = conv2(im_nonan(:, :, i) ,k,'same');
%             tmp_conv = im_nonan(:, :, i);
%             tmp_conv(mask(:, :, i)) = im_conv_avg(mask(:, :, i));
%             im_nonan(:, :, i) = tmp_conv;
%         end
% 
%         % Save
%         imwrite(im_nonan,[p_er '\truth_nonan.tif'])
% 
%         % sRGB
%         rgb_nonan = reshape(im_nonan, sizey*sizex, 3);
%         save([p_er '\rgb_nonan'],'rgb_nonan')
% 
%         % Graphic
%         figure
%         image(im_nonan);
%         axis image
%     end

    %% 7: Graphics

%     % Camera setting: Intensity parameter vs wavelength
%     figure;
%     plot(intensities(:, 1) , intensities(:, 2) );

    % CIELAB space
    figure;
    step = 100;
    c = double(lab2rgb(LAB_array,'OutputType','uint8'))/255; % Convert LAB values to RGB values as 'double' class type
    scatter3(LAB_array(1:step:end, 3), LAB_array(1:step:end, 2), LAB_array(1:step:end, 1), 5, c(1:step:end, :), 'filled'); %create 3D scatterplot of L*, a*, b* values (color of the points specified by c)
    xlabel('b^*'); ylabel('a^*'); zlabel('L^*');
    legend('Pixels');

    % Beam profile 
    RMS = @(img) sqrt(sum(sum((img-mean2(img)).^2))/(size(img, 1)*size(img, 2)));
    CRMS = @(img) RMS(img)/mean2(img);
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
        imagesc(im);
        axis off;
        axis image;
        colorbar;
%         title(sprintf('%d nm CRMS %0.2f',wl_array(wl), CRMS(im)))
        title(sprintf('%d nm',wl_array(wl)));
    end

    % Transmittance images (Plot mean transmittance at each wavelength)
    vt = reshape(trans_array_m, size(trans_array_m, 1), sizey, sizex);
    figure('units','normalized','outerposition',[0 0 1 1]);
    wl_array = 380:10:780;
    for wl = 1:41
        subplot(6,7,wl)

        vvname = sprintf('%s(wl,:,:)','vt');
        vv = eval(vvname);
        im = squeeze(vv);
        imagesc(im);
        axis off;
        axis image;
        colorbar;
%         title(sprintf('%d nm CRMS %0.2f',wl_array(wl), CRMS(im)))
        title(sprintf('%d nm',wl_array(wl)));
    end

end