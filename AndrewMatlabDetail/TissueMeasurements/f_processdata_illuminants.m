% 04-03-20: Process raw image data to compute transmittance, CIEXYX,
% CIELAB, and sRGB coordinates, and output a .png image for each
% illuminant(D65, D50, and A). 

function f_processdata_illuminants(name_of_sample, illuminants)

    close all;

    %% 1: Camera: Calculate transmittance
    % Compute the tranmittance based on the temporal mean/std dev over numberofshots
    
    % Declare Paths to collect raw dData from and write processed data to
    name_of_sample = 'Camelyon16_T13-15492_Tag3'; % Name of the sample
    I = {'d65','d50','-a-'}; % Name of the illuminants
    illuminants = char(I); % Convert cells to characters
    numberofshots = 41;
    
    p_rdata = ['D:\DigitalPathology\ColorDetail\ImageData\031320\RawData\' name_of_sample]; % Path with the raw data
    p_sample = [p_rdata '\' name_of_sample '_sample']; % Path with raw data for the sample
    p_white = [p_rdata '\' name_of_sample '_white']; % Path with raw data for the white image
    
    for i = 1:3
        p_pdata = ['D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\' illuminants(i,:) '\' name_of_sample]; % Path for the processed data
        p_trans = [p_pdata '\Transmittance']; % Path for the processed transmittance data
        p_cie = [p_pdata '\CIE_Coord']; % Path for the processed CIE data
        p_er = [p_pdata '\EndResults']; % Path for the processed End Results
    
        %Create the processed data folders
        mkdir(p_pdata); % Create processed data larger folder
        mkdir(p_trans); % Create processed data sub-folders
        mkdir(p_cie);
        mkdir(p_er);
    
        % Compute Transmittance value from raw data
        [trans_array_m, trans_array_s, sizey, sizex] = f_frame2transmittance_white(p_sample, p_white, numberofshots); 

        % Corrects for potential Inf values in the transmittance
        [trans_array_m, trans_array_s] = f_interp_infTval(trans_array_m, trans_array_s);

        %% 2: Camera: Calculate LAB

        % Prepares the illuminant
        cd('D:\DigitalPathology\ColorDetail\Matlab_Color\Scripts\Data Illuminants'); % Change Directory to 'Data Illuminants' folder
        load (['spec_cie' illuminants(i,:)],'spec'); % Load specs for illuminant
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

        %% 3: Reconstruct sRGB image

        % Rescale XYZ so that Y of illuminant is 1
        Y0 = 100;

        % Convert to sRGB and save
        rgb = f_XYZ2sRGB(XYZ_array/Y0);
        save([p_er '\rgb'],'rgb')

        % Create png from sRGB values
        im = reshape(rgb,sizey,sizex,3);
        imwrite(im,[p_er '\truth.png'])

        % Visualize image
        figure
        image(im);
        axis image

        % Check if some pixels are still NaN
        nan_test = find(isnan(im) ~=0);
    end
    

    %% 8: Graphics

%     % Camera setting: Intensity parameter vs wavelength
%     figure;
%     plot(intensities(:, 1) , intensities(:, 2) );

%     % CIELAB space
%     figure;
%     step = 100;
%     c = double(lab2rgb(LAB_array,'OutputType','uint8'))/255; % Convert LAB values to RGB values as 'double' class type
%     scatter3(LAB_array(1:step:end, 3), LAB_array(1:step:end, 2), LAB_array(1:step:end, 1), 5, c(1:step:end, :), 'filled'); %create 3D scatterplot of L*, a*, b* values (color of the points specified by c)
%     xlabel('b^*'); ylabel('a^*'); zlabel('L^*');
%     legend('Pixels');
% 
%     % Beam profile 
%     RMS = @(img) sqrt(sum(sum((img-mean2(img)).^2))/(size(img, 1)*size(img, 2)));
%     CRMS = @(img) RMS(img)/mean2(img);
%     fnin_m = sprintf('%s/vim_mean_array', p_white);
%     load(fnin_m,'vim_mean_array');
% 
%     vt = vim_mean_array;
%     figure('units','normalized','outerposition',[0 0 1 1]);
%     wl_array = 380:10:780;
%     for wl = 1:41
%         subplot(6,7,wl)
% 
%         vvname = sprintf('%s(wl,:,:)','vt');
%         vv = eval(vvname);
%         im = squeeze(vv);
%         imagesc(im);
%         axis off;
%         axis image;
%         colorbar;
% %         title(sprintf('%d nm CRMS %0.2f',wl_array(wl), CRMS(im)))
%         title(sprintf('%d nm',wl_array(wl)));
%     end
% 
%     % Transmittance images (Plot mean transmittance at each wavelength)
%     vt = reshape(trans_array_m, size(trans_array_m, 1), sizey, sizex);
%     figure('units','normalized','outerposition',[0 0 1 1]);
%     wl_array = 380:10:780;
%     for wl = 1:41
%         subplot(6,7,wl)
% 
%         vvname = sprintf('%s(wl,:,:)','vt');
%         vv = eval(vvname);
%         im = squeeze(vv);
%         imagesc(im);
%         axis off;
%         axis image;
%         colorbar;
% %         title(sprintf('%d nm CRMS %0.2f',wl_array(wl), CRMS(im)))
%         title(sprintf('%d nm',wl_array(wl)));
%     end

end