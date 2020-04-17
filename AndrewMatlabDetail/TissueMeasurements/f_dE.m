% 04-10-2020 -- Compute mean transmittance for given ROIs, convert to
% CIEXYZ and CIELAB coordinates, and compute the dE between the regions 
% for each of the three illuminants.

% fn -- specify the folder path that contains the transmittance data of 
% interest
% p_illum -- specify the name of the folder within your current directory 
% that contains the data for the three illuminants
% mask_c -- specify the circular mask (output from select_roi_circle)
% mask_d -- specify the donut-shaped mask (output from select_roi_donut)

% dE is output as 3 values, one for each illuminant (D65, D50, and A)

function dE = f_dE(fn,p_illum,mask_c,mask_d)
        %% 1: Load Transmittance Data
        
        % Load the transmittance data from your sample of interest
        load([fn '\trans_mean_camera'],'trans_array_m', 'sizex', 'sizey'); % Load mean transmittance data
        load([fn '\trans_std_camera'], 'trans_array_s'); % Load standard deviation transmittance data
        
        % Reshape to a 3D array so we can loop through it
        Tm = reshape(trans_array_m, size(trans_array_m,1), sizey, sizex);
        Ts = reshape(trans_array_s, size(trans_array_s,1), sizey, sizex);
        
        disp('Creating new ROI matrices...')
        
        %Create "blank" new matrices filled with zeros
        trans_m_roi_c = NaN(size(trans_array_m,1), sizey, sizex); % Mean transmittance, circle
        trans_s_roi_c = NaN(size(trans_array_s,1), sizey, sizex); % STD transmittance, circle
        
        trans_m_roi_d = NaN(size(trans_array_m,1), sizey, sizex); % Mean transmittance, donut
        trans_s_roi_d = NaN(size(trans_array_s,1), sizey, sizex); % STD transmittance, donut
       
        % Fill your blank matrix with the values from your ROI
        for i = 1:length(mask_c(:,1))
            trans_m_roi_c(:,mask_c(i,2),mask_c(i,1)) = Tm(:,mask_c(i,2),mask_c(i,1)); % Write values into mean trans, circle
            trans_s_roi_c(:,mask_c(i,2),mask_c(i,1)) = Ts(:,mask_c(i,2),mask_c(i,1)); % Write values into std trans, circle          
        end
        
        for j = 1:length(mask_d(:,1))           
            trans_m_roi_d(:,mask_d(j,2),mask_d(j,1)) = Tm(:,mask_d(j,2),mask_d(j,1)); % Write values into mean trans, circle
            trans_s_roi_d(:,mask_d(j,2),mask_d(j,1)) = Ts(:,mask_d(j,2),mask_d(j,1)); % Write values into std trans, circle          
        end
        
        %Reshape new transmittance back to 2D
        trans_m_roi_c = reshape(trans_m_roi_c, size(trans_m_roi_c,1), sizey*sizex);
        trans_s_roi_c = reshape(trans_s_roi_c, size(trans_s_roi_c,1), sizey*sizex);
        
        trans_m_roi_d = reshape(trans_m_roi_d, size(trans_m_roi_d,1), sizey*sizex);
        trans_s_roi_d = reshape(trans_s_roi_d, size(trans_s_roi_d,1), sizey*sizex);
        
        % Remove the NaN values from the matrix
        for i = 1:41
            ROI_mtrans_c(:,i) = rmmissing(trans_m_roi_c(i,:));
            ROI_strans_c(:,i) = rmmissing(trans_s_roi_c(i,:));
            ROI_mtrans_d(:,i) = rmmissing(trans_m_roi_d(i,:));
            ROI_strans_d(:,i) = rmmissing(trans_s_roi_d(i,:));
        end
        
        % Compute the mean transmittance value of the ROI
        for i = 1:41
            mean_mtrans_c(i,:) = mean(ROI_mtrans_c(:,i));
            mean_strans_c(i,:) = mean(ROI_strans_c(:,i));
            mean_mtrans_d(i,:) = mean(ROI_mtrans_d(:,i));
            mean_strans_d(i,:) = mean(ROI_strans_d(:,i));
        end
        
        %% 2: Calculate mean CIEXYZ and CIELAB values for each illuminant
        
        illuminant = ['D65';'D50';'-A-'];

        for i = 1:3
            %Save current directory path
            directory = cd();

            % Prepares the illuminant
            load ([directory '\' p_illum '\spec_cie' illuminant(i,:)],'spec'); % Load specs for illuminant
            ls = spec(1:10:401,2); % Load light source information from specs

            % Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)          
            [LAB_mean_c, CovLAB_mean_c, XYZ_mean_c, CovXYZ_mean_c] = f_transmittance2LAB(mean_mtrans_c, mean_strans_c, 1, 1, ls, 'y'); % 'y' top trim the max tranmsittance to 1
            
            [LAB_mean_d, CovLAB_mean_d, XYZ_mean_d, CovXYZ_mean_d] = f_transmittance2LAB(mean_mtrans_d, mean_strans_d, 1, 1, ls, 'y'); % 'y' top trim the max tranmsittance to 1
 
            %% 3: Calculate dE between circle and donut for each illuminant

            dE(i) = sum((LAB_mean_c-LAB_mean_d).^2).^0.5;
        end
end
            