% 04-10-2020 -- Use transmittance data to calculate CIEXYZ, CIELAB, and 
% sRGB coordinates for given ROIs and compute the dE between the regions 
% for each of the three illuminants.

% fn -- specify the folder path that contains the transmittance data of 
% interest
% p_illum -- specify the name of the folder within your current directory 
% that contains the data for the three illuminants
% mask_c -- specify the circular mask (output from select_roi_circle)
% mask_d -- specify the donut-shaped mask (output from select_roi_donut)

% dE is output as 3 values, one for each illuminant (D65, D50, and A)

function dE = f_processdata_roi(fn,p_illum,mask_c,mask_d)
        %% 1: Load Transmittance Data
        
        % Load the transmittance data from your sample of interest
        load([fn '\trans_mean_camera'],'trans_array_m', 'sizex', 'sizey'); % Load mean transmittance data
        load([fn '\trans_std_camera'], 'trans_array_s'); % Load standard deviation transmittance data
        
        % Reshape to a 3D array so we can loop through it
        Tm = reshape(trans_array_m, size(trans_array_m,1), sizey, sizex);
        Ts = reshape(trans_array_s, size(trans_array_s,1), sizey, sizex);
        
        disp('Creating new ROI matrices...')
        
        %Create "blank" new matrices filled with zeros
        trans_m_roi_c = zeros(size(trans_array_m,1), sizey, sizex); % Mean transmittance, circle
        trans_s_roi_c = zeros(size(trans_array_s,1), sizey, sizex); % STD transmittance, circle
        
        trans_m_roi_d = zeros(size(trans_array_m,1), sizey, sizex); % Mean transmittance, donut
        trans_s_roi_d = zeros(size(trans_array_s,1), sizey, sizex); % STD transmittance, donut
       
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
        
        %% 2: Calculate LAB
        
        illuminant = ['D65';'D50';'-A-'];

        for i = 1:3
        
            %Save current directory path
            directory = cd();

            % Prepares the illuminant
            load ([directory '\' p_illum '\spec_cie' illuminant(i,:)],'spec'); % Load specs for illuminant
            ls = spec(1:10:401,2); % Load light source information from specs

            % Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)
            [LAB_array_c, CovLAB_array_c, XYZ_array_c, CovXYZ_array_c] = f_transmittance2LAB(trans_m_roi_c, trans_s_roi_c, sizey, sizex, ls, 'y'); % 'y' top trim the max tranmsittance to 1
            
            [LAB_array_d, CovLAB_array_d, XYZ_array_d, CovXYZ_array_d] = f_transmittance2LAB(trans_m_roi_d, trans_s_roi_d, sizey, sizex, ls, 'y'); % 'y' top trim the max tranmsittance to 1
            
            %% 3: Calculate dE between circle and donut for each illuminant
            
            % Reconstruct the LAB arrays to only include pixels in the ROI
            LAB_c_recon = [nonzeros(LAB_array_c(:,1)),nonzeros(LAB_array_c(:,2)),nonzeros(LAB_array_c(:,3))];
            LAB_d_recon = [nonzeros(LAB_array_d(:,1)),nonzeros(LAB_array_d(:,2)),nonzeros(LAB_array_d(:,3))];
            
            % Compute the mean value of L*,a*,and b* for each ROI
            LAB_mean_c(:,i) = [mean(LAB_c_recon(:,1)); mean(LAB_c_recon(:,2)); mean(LAB_c_recon(:,3))];
            LAB_mean_d(:,i) = [mean(LAB_d_recon(:,1)); mean(LAB_d_recon(:,2)); mean(LAB_d_recon(:,3))];
            
            % Calculate dE between the two
            dE(i) = sum((LAB_mean_c(:,i)-LAB_mean_d(:,i)).^2).^0.5;
            
            %% 4: Reconstruct sRGB image

            % Rescale XYZ so that Y of illuminant is 1
            Y0 = 100;

            % Convert to sRGB
            rgb_c = f_XYZ2sRGB(XYZ_array_c/Y0);
            rgb_d = f_XYZ2sRGB(XYZ_array_d/Y0);

            % Reshape into 3D arrays that can be saved if desired
            im_circle= reshape(rgb_c,sizey,sizex,3);
            im_donut = reshape(rgb_d,sizey,sizex,3);

            % Visualize images
            figure
            subplot(2,1,1);
            image(im_circle);
            axis image
            subplot(2,1,2);
            image(im_donut);
            axis image
                    
            %% 5:Plot CIELAB pixel coordinates for each ROI
            
            % Convert LAB values to RGB values as 'double' class type
            c_circle = double(lab2rgb(LAB_c_recon,'OutputType','uint8'))/255; 
            c_donut = double(lab2rgb(LAB_d_recon,'OutputType','uint8'))/255;
            
            %Plot all pixels in 3D space for the circle
            figure;
            subplot(2,1,1);
            scatter3(LAB_c_recon(:,3), LAB_c_recon(:,2), LAB_c_recon(:,1), 3, c_circle(:,:), 'fill');
            xlabel('b^*'); ylabel('a^*'); zlabel('L^*');
            title(['Circle Pixels, ' illuminant(i,:)]);
            xlim ([-75 25]); ylim([-25 75]); zlim([40 100]);
            
            %2D projection of the 3D plot to show chromaticity distribution
            subplot(2,1,2);
            scatter(LAB_c_recon(:,3), LAB_c_recon(:,2), 3, c_circle(:,:), 'fill');
            xlabel('b^*'); ylabel('a^*');
            title(['Circle Chromaticity Distribution, ' illuminant(i,:)]);
            xlim ([-75 25]); ylim([-25 75]); 
            
            %Plot all pixels in 3D space for the donut
            figure;
            subplot(2,1,1);
            scatter3(LAB_d_recon(:,3), LAB_d_recon(:,2), LAB_d_recon(:,1), 3, c_donut(:,:), 'fill');
            xlabel('b^*'); ylabel('a^*'); zlabel('L^*');
            title(['Donut Pixels, ' illuminant(i,:)]);
            xlim ([-75 25]); ylim([-25 75]); zlim([40 100]);
            
            %2D projection of the 3D plot to show chromaticity distribution
            subplot(2,1,2);
            scatter(LAB_d_recon(:,3), LAB_d_recon(:,2), 3, c_donut(:,:), 'fill');
            xlabel('b^*'); ylabel('a^*');
            title(['Donut Chromaticity Distribution, ' illuminant(i,:)]);
            xlim ([-75 25]); ylim([-25 75]); 
            
            %% 6: Assess Pixel Uniformity
            
            % Matrix w/ avg values that is same length as LAB_c_recon
            c_LAB_avg(:,:,i) = repmat([LAB_mean_c(1,i),LAB_mean_c(2,i),LAB_mean_c(3,i)],length(LAB_c_recon(:,i)),1);
            d_LAB_avg(:,:,i) = repmat([LAB_mean_d(1,i),LAB_mean_d(2,i),LAB_mean_d(3,i)],length(LAB_d_recon(:,i)),1);
           
            % Compute distance of each pixel from LAB average
            for j = 1:length(LAB_c_recon(:,1))
                c_uni(j,i) = sum((c_LAB_avg(j,:,i)-LAB_c_recon(j,:)).^2).^0.5;
            end
            
            for j = 1:length(LAB_d_recon(:,1))
                d_uni(j,i) = sum((d_LAB_avg(j,:,i)-LAB_d_recon(j,:)).^2).^0.5;
            end
        end
        
    % Boxplot to show uniformity of the ROI for all illuminants
    figure;
    subplot(1,2,1);
    boxplot(c_uni,illuminant);
    title('Circle Uniformity');
    xlabel('Illuminant');
    ylabel('Distance from L*a*b* Average');
    
    subplot(1,2,2);
    boxplot(d_uni,illuminant);
    title('Donut Uniformity');
    xlabel('Illuminant');
    ylabel('Distance from L*a*b* Average');
end