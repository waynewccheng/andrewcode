% 02-13-2020: First version

function [lambda_pr, spectra_pr, spectra_backgound_pr, lambda_qe, spectra_qe, spectra_backgound_qe] = f_meas_OL490_bw(ol490, pr, ludl, ROI)

    % Connect QE-65
    spectrometerObj = icdevice('OceanOptics_OmniDriver.mdd');
    connect(spectrometerObj);
    disp(spectrometerObj)

    % QE-65 parameters
    integrationTime = 100000; % integration time for sensor (micro sec), can put value to 3sec.
    spectrometerIndex = 0; % Spectrometer index to use (first spectrometer by default).
    channelIndex = 0; % Channel index to use (first channel by default).
    enable = 1; % Enable flag.

    % Set QE-65 parameters
    invoke(spectrometerObj, 'setIntegrationTime', spectrometerIndex, channelIndex, integrationTime);
    invoke(spectrometerObj, 'setCorrectForDetectorNonlinearity', spectrometerIndex, channelIndex, enable);
    invoke(spectrometerObj, 'setCorrectForElectricalDark', spectrometerIndex, channelIndex, enable);

    % OL490 parameters
    intensity = 100;
    bandwidth = 10;
    wl=380:10:780;
    
    % Data storage
    lambda_pr = zeros(1, 401);
    spectra_pr = zeros(size(wl, 2), 401);
    spectra_backgound_pr = zeros(size(wl, 2), 401);
    
    % Move to sample ROI
    ludl.setXY(ROI)
    
    % Pauses until the stage is not moving anymore
    while ludl.getStatus ~= 'N'
        pause(0.01);
    end
    
    % Loop throught the wavelengths
    for k = 1: size(wl, 2)
           
        % Prepare light
        disp(['Lambda = ' num2str(wl(k)) ' On']);
        ol490.setPeak(wl(k),bandwidth,intensity);
        pause(1); % This deals with 07-1-2019 potential bug

        % Spectroradiometer mesurements, light on
        disp('Measurement with the spectro-radiometer...');
       
        tmp = pr.measure;
        spectra_pr(k, :) = (tmp.amplitude)';
        lambda_pr = (tmp.wavelength)';
        
        % Spectrometer mesurements, light on
        disp('Measurement with the spectrometer...');
        
        spectra_qe(k, :) = (invoke(spectrometerObj, 'getSpectrum', spectrometerIndex))';
        lambda_qe = (invoke(spectrometerObj, 'getWavelengths', spectrometerIndex, channelIndex))';
        
        % Turn off the light
        disp(['Lambda = ' num2str(wl(k)) ' Off']);
        ol490.setPeak(wl(k),bandwidth,0 );
        pause(1);

        % Spectroradiometer mesurements, light on
        disp('Measurement with the spectro-radiometer...');

        tmp = pr.measure;
        spectra_backgound_pr(k, :) = (tmp.amplitude)';
        
        % Spectrometer mesurements, light on
        disp('Measurement with the spectrometer...');
        
        spectra_backgound_qe(k, :) = (invoke(spectrometerObj, 'getSpectrum', spectrometerIndex))';
        
    end
    
    ol490.setWhite;
    
    % Disconnect QE-65
    disconnect(spectrometerObj);
    delete (spectrometerObj);
    
end