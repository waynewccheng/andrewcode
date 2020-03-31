% 10-01-19: ROI is not in this function anymore

% 08-20-19: No tape measurements

function [lambda, spectra, spectra_backgound] = f_meas_spectro_PL3(ol490, pr, ludl, n_meas, ROI)

    % Spectra mesurements for samples, white and black
    disp('Measurement with the spectro-radiometer...');

    lambda = zeros(1, 401);
    spectra = zeros(n_meas, 401, 2); % 3 for filter, white
    spectra_backgound = zeros(n_meas, 401, 2); % 2 for filter, white

    % Turn on the light
    ol490.setWhite;

    Meas_Comments = {'Filter', '100% transmittance'};

    % Loops through filter, white and black measurements
    for j = 1:2 % 1 is filter, 2 is 100% transmittance

        % Move to sample ROI
        ludl.setXY(ROI(j, :))

        % Pauses until the stage is not moving anymore
        while ludl.getStatus ~= 'N'
            pause(0.01);
        end

        % Which measurement?
        disp([Meas_Comments{j}, ' measurement']);

        % Loops to get n_meas measurements, using the 8x speed on PR730
        for i = 1:n_meas
            tmp = pr.measure;
            spectra(i, :, j) = (tmp.amplitude)';
        end
        lambda = (tmp.wavelength)';

        % Background light measurement

        % Turn off the light
        ol490.setBlack(550, 10);
        pause(1);

        % Which measurement?
        disp([Meas_Comments{j}, ' background measurement']);
        
        % Loops to get n_meas black measurements of the OL490
        for i = 1:n_meas
            tmp = pr.measure;
            spectra_backgound(i, :, j) = (tmp.amplitude)';
        end

        % Turn on the light
        ol490.setWhite;
        pause(1);

    end

    clear tmp;

end

