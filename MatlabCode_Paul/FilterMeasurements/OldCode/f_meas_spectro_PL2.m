% 08-20-19: No tape measurements

function [lambda, spectra, spectra_backgound, ROI] = f_meas_spectro_PL2(ol490, pr, ludl, n_meas, input_ROI)

    % Spectra mesurements for samples, white and black
    disp('Measurement with the spectro-radiometer...');

    lambda = zeros(1, 401);
    spectra = zeros(n_meas, 401, 3); % 3 for filter, white and camera black
    spectra_backgound = zeros(n_meas, 401, 2); % 2 for filter, white
    
    % Turn on the light
    ol490.setWhite;

    % ROI
    switch input_ROI
        % Find ROI on the filter, the 100% transmittance and the black
        case 0
            [xy, xy_white, xy_black] = findroi_PL2(ol490, ludl);
            ROI = [xy; xy_white; xy_black];
        % The ROI is set as a parameter, useful for repeatability meas.
        otherwise
            ROI = input_ROI;
    end
    
    Meas_Comments = {'Filter', '100% transmittance', '0% transmittance'};
    e_xy = 20;
    
    % Loops through filter, white and black measurements
    for j = 1:3 % 1 is filter, 2 is 100% transmittance, 3 is 0% transmittance

        % Move to sample ROI
        ludl.setXY(ROI(j, :))

        % Pauses until the stage is not moving anymore
        % waitfor(ludl.getStatus == 'N');
%         while ~inpolygon(ludl.getX, ludl.getY, [ROI(j, 1)-e_xy, ROI(j, 1)+e_xy], [ROI(j, 2)-e_xy, ROI(j, 2)+e_xy])
%             pause(0.01); 
%         end
        while ludl.getStatus ~= 'N'
            pause(0.01); 
        end
        
        % Which measurement?
        disp([Meas_Comments{j}, ' measurement']);
        
        % Loops to get n_meas measurements, using the 8x speed on PR730
        for i = 1:n_meas
            tmp = pr.measure;
%             if (i == 1) && (j == 1)
%                 lambda = (tmp.wavelength)';
%             end
            spectra(i, :, j) = (tmp.amplitude)';
        end
        
        %TEST
        lambda = (tmp.wavelength)';
        %TEST
        % Background for sample and white
        
        if j ~=3
            % Turn off the light
            ol490.setBlack(550, 10);
            pause(1);
            
            % Loops to get n_meas black measurements of the OL490
            for i = 1:n_meas
                tmp = pr.measure;
%                 if (i == 1) && (j == 1)
%                     lambda = (tmp.wavelength)';
%                 end
                spectra_backgound(i, :, j) = (tmp.amplitude)';
            end
            
            % Turn on the light
            ol490.setWhite;
            pause(1);
        end

    end

    clear tmp;

end

