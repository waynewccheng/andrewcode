% 02-13-2020: First version

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


% Measurement

lambda_qe = (invoke(spectrometerObj, 'getWavelengths', spectrometerIndex, channelIndex))';
spectra_qe_sum = 0;

n = 100;
for i = 1:n
    spectra_qe_sum = spectra_qe_sum + (invoke(spectrometerObj, 'getSpectrum', spectrometerIndex))';
end

spectra_qe = spectra_qe_sum / n;

% Disconnect QE-65
disconnect(spectrometerObj);
delete (spectrometerObj);

% plot
plot(lambda_qe,spectra_qe)

xlabel('Wavelength (nm)')
ylabel('SPD')

%% Save data
path = 'F:\Data_Paul\RawData\021420\OL490_Spectra';
mkdir(path);

% remove bad wave lengths
mask = spectra_qe < 5;

save([path '\qe65pro_dark'],'spectra_qe','lambda_qe','mask');


saveas(gcf,[path '\qe65pro_dark.png'])