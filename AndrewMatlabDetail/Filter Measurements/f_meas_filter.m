%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurements of the film filter using the spectro-radiometer %
% and the PointGrey camera                                     %
%%%

% 10-01-19: ROI is no more in f_meas_spectro

% 09-30-19: no more cd, using direct paths instead, main_filter is a
% function now

% 09-26-19: replace f_deltaE by f_deltaE_3 that does not estimate the
% uncertainty since deltaE is not normally distributed

% 08-20-19: transmittance with backgournd measurement, no black tape
% measurements now

% 08-16-19: added the measurements of the OL490 blackground (no intensity)

% New version, saves the spatial averages and corrects for the error in the
% Jacobian from spd2XYZ.m

function f_meas_filter(name_of_sample, ol490, ludl, pr, n_meas, ROI, gr_choice)

    close all;

    %% 1: Initialization
    % Gathers and stores the measurements informations, creates the folders
    [p_sample, p_white, p_spectro,...
        p_trans, p_cie, p_st] = f_init_filters(pr, name_of_sample);
    p_sw = {p_sample, p_white};

    %% 2: SpectroRadiometer: Measurements
    % Call of measurements by spectrometer
    [lambda, spectra, spectra_background] = f_meas_spectro(ol490, pr, ludl, n_meas, ROI);

    % Compute mean value and error with OL490 on
    s_filter = spectra(:, :, 1);
    s_white = spectra(:, :, 2);

    s_filter_m = mean(s_filter, 1);
    s_white_m = mean(s_white, 1);

    % Compute mean value and error with OL490 off (background)
    s_filter_background = spectra_background(:, :, 1);
    s_white_background = spectra_background(:, :, 2);
    s_filter_background_m = mean(s_filter_background);
    s_white_background_m = mean(s_white_background);

    if ~isequal(n_meas, 1)
        % Std
        s_filter_s = std(s_filter)./sqrt(n_meas);
        s_white_s = std(s_white)./sqrt(n_meas);
        s_filter_background_s = std(s_filter_background)./sqrt(n_meas);
        s_white_background_s = std(s_white_background)./sqrt(n_meas);
        
        % Compute the transmittance
        [t_mean_spectro, t_std_spectro] = f_transmittance(s_filter_m, s_white_m,...
            s_filter_background_m, s_white_background_m, s_filter_s, s_white_s,...
            s_filter_background_s, s_white_background_s);
    else
        s_filter_s = []; s_white_s = [];
        s_filter_background_s = []; s_white_background_s = [];
        
        % Compute the transmittance
        [t_mean_spectro, t_std_spectro] = f_transmittance(s_filter_m, s_white_m,...
            s_filter_background_m, s_white_background_m);
    end
    trans_spectro = [lambda; t_mean_spectro; t_std_spectro]';

    % Save the data
    save([p_spectro '\spectro_meas'],'spectra');
    save([p_spectro '\spectro_meas_background'],'spectra_background');
    save([p_trans '\trans_spectro'],'trans_spectro');

    %% 3: SpectroRadiometer: Calculate LAB: T -> XYZ -> LAB

    % Prepares the illuminant
    load ('C:\Users\wcc\Desktop\MatlabCode_Paul\DataIlluminants\spec_cied65','spec');
    ls = spec(1:10:401,2);

    % Compute LAB for the spectro
    if ~isequal(n_meas, 1)
        [LAB_spectro, CovLAB_spectro, XYZ_spectro, CovXYZ_spectro] = f_transmittance2LAB(t_mean_spectro(1:10:401)', t_std_spectro(1:10:401)', 1, 41, ls, 'n');
    else
        [LAB_spectro, CovLAB_spectro, XYZ_spectro, CovXYZ_spectro] = f_transmittance2LAB(t_mean_spectro(1:10:401)', [] , 1, 41, ls, 'n');
    end
    
    % Save the results
    save([p_cie '\LAB_Spectro'],'LAB_spectro');
    save([p_cie '\XYZ_Spectro'],'XYZ_spectro');
    
    if ~isequal(n_meas, 1)
        save([p_cie '\CovLAB_Spectro'],'CovLAB_spectro');
        save([p_cie '\CovXYZ_Spectro'],'CovXYZ_spectro');
    end

    %% 4: Camera: Establishes/get the maximum shutter time, spanning the wavelengths; Set the OL490 max intensities 
    numberofshots = 1;
    bandwidth = 10;

    % Move to 100% ttranmittance area
    ludl.setXY(ROI(2, :));
    
    % Camera settings
    [shutter_tbl, gain_tbl] = f_camera_settings(ol490, bandwidth, p_st, 'r');
    
    % OL490 intensity estimation
    intensities = f_intensity_ol490(ol490, bandwidth, shutter_tbl(:, 2), gain_tbl(:, 2) );

    %% 5: Camera: Measurements

    % Slightly reduce the intensity to avoid saturation
    intensities(:, 2) = 0.9 * intensities(:, 2);

    % Measurements with the camera
    numberofshots = n_meas;
    Meas_Comments = {'Filter', '100% transmittance'};

    for j = 1:2 % 1 is filter, 2 is 100% transmittance

        % Which measurement?
        disp([Meas_Comments{j}, ' measurement'])

        % Move platform
        ludl.setXY(ROI(j, :));

        % Pauses until the stage is not moving anymore
        while ludl.getStatus ~= 'N'
            pause(0.01);
        end

        f_camera2frame_9MP_small_filter(p_sw{j}, numberofshots, ol490, intensities(:, 2), bandwidth, shutter_tbl(:, 2), gain_tbl(:, 2), 'filter');

    end

    %% 6: Camera: Calculate transmittance
    % Compute the tranmittance based on the spatial average of numberofshots
    % images and the coreesponding stat stored in img_ms
    % , trans_ms is the spatial average with temporal mean and std
    % dev of the transmittance, trans_array_m and trans_array_s are pixel by
    % pixel values
    [trans_ms, trans_array_m, trans_array_s, sizey, sizex] = f_frame2transmittance_white_filter(p_sample, p_white, numberofshots, 'filter');

    %% 7: Camera: Calculate LAB
    % Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)
    if ~isequal(numberofshots, 1)
        [LAB_cam, CovLAB_cam, XYZ_cam, CovXYZ_cam] = f_transmittance2LAB(trans_ms(:, 2), trans_ms(:, 3), 1, 41, ls, 'n');
    else
        [LAB_cam, CovLAB_cam, XYZ_cam, CovXYZ_cam] = f_transmittance2LAB(trans_ms(:, 2), [], 1, 41, ls, 'n');
    end
    [LAB_array, CovLAB_array, XYZ_array, CovXYZ_array] = f_transmittance2LAB(trans_array_m, trans_array_s, sizey, sizex, ls, 'n');
    
    % Save transmittance values and the CIELAB/CIEXYZ
    save([p_trans '\trans_mean_camera'],'trans_array_m','sizey','sizex','-v7.3');
    save([p_cie '\LAB_cam'],'LAB_cam');
    save([p_cie '\XYZ_cam'],'XYZ_cam');
    save([p_cie '\LAB_array'],'LAB_array');
    save([p_cie '\XYZ_array'],'XYZ_array');
       
    if ~isequal(numberofshots, 1)
        save([p_trans '\trans_std_camera'],'trans_array_s','sizey','sizex','-v7.3');
        save([p_trans '\trans_ms'],'trans_ms');
        save([p_cie '\CovXYZ_cam'],'CovXYZ_cam');
        save([p_cie '\CovLAB_cam'],'CovLAB_cam');
        save([p_cie '\CovXYZ_array'],'CovXYZ_array');
        save([p_cie '\CovLAB_array'],'CovLAB_array');
    end

    %% 8: Graphics
    if isequal(gr_choice, 'on')
        
        % Camera setting: Intensity parameter vs wavelength
        figure(1);
        plot(intensities(:, 1) , intensities(:, 2) );
        
        if ~isequal(numberofshots, 1)
            
            % Signals
            figure(2);
            errorbar(lambda, s_filter_m, s_filter_s); hold on;
            errorbar(lambda, s_white_m, s_white_s);
            
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
            
        else
            
            % Signals
            figure(2);
            plot(lambda, s_filter_m); hold on;
            plot(lambda, s_white_m);
            
            % Tranmittance spectra
            figure(3);
            plot(trans_spectro(:, 1), trans_spectro(:, 2));
            title('Error bars at k = 2');
            
            figure(4);
            plot(trans_spectro(1:10:end, 1), trans_spectro(1:10:end, 2)); hold on;
            plot(trans_ms(:, 1), trans_ms(:, 2), 'k');
            axis([350 800 -0.1 1]);
            legend('Spectro', 'Whole img');
            title('Error bars at k = 2');
            
            figure(5);
            plot(trans_spectro(1:10:end, 1), trans_spectro(1:10:end, 2)); hold on;
            plot(trans_spectro(1:10:end, 1), trans_array_m(:, 1*1) , 'k');
            legend('Spectro', 'one pixel');
            title('Error bars at k = 2');
            
        end
        
        % CIELAB space
        figure(6);
        step = 500;
        DE = f_deltaE_3(LAB_spectro, LAB_cam);
        scatter3(LAB_array(1:step:end, 3), LAB_array(1:step:end, 2), LAB_array(1:step:end, 1), '.b'); hold on;
        scatter3(LAB_cam(3), LAB_cam(2), LAB_cam(1), 'r', 'Filled');
        scatter3(LAB_spectro(3), LAB_spectro(2), LAB_spectro(1), 'k', 'LineWidth', 2);
        xlabel('b^*'); ylabel('a^*'); zlabel('L^*');
        legend('Pixel', 'Img mean', 'Spectro');
        title(['\Delta E_{ab}^* = ' sprintf('%0.2f',DE)]);

        % Beam profile
        fnin_m = sprintf('%s/vim_mean_array',p_white);
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
    end

end