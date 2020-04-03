pectrometerObj = icdevice('OceanOptics_OmniDriver.mdd');

%% Connect to the instrument.

connect(spectrometerObj);
disp(spectrometerObj)

%% Set parameters for spectrum acquisition.

% integration time for sensor.
integrationTime = 1000000; % 1s
% Spectrometer index to use (first spectrometer by default).
spectrometerIndex = 0;
% Channel index to use (first channel by default).
channelIndex = 0;
% Enable flag.
enable = 1;

%% Identify the spectrometer connected.

% Get number of spectrometers connected.
numOfSpectrometers = invoke(spectrometerObj, 'getNumberOfSpectrometersFound');

disp(['Found ' num2str(numOfSpectrometers) ' Ocean Optics spectrometer(s).'])

% Get spectrometer name.
spectrometerName = invoke(spectrometerObj, 'getName', spectrometerIndex);
% Get spectrometer serial number.
spectrometerSerialNumber = invoke(spectrometerObj, 'getSerialNumber', spectrometerIndex);
disp(['Model Name : ' spectrometerName])
disp(['Model S/N  : ' spectrometerSerialNumber])

%% Set the parameters for spectrum acquisition.

% Set integration time.
invoke(spectrometerObj, 'setIntegrationTime', spectrometerIndex, channelIndex, integrationTime);
% Enable correct for detector non-linearity.
invoke(spectrometerObj, 'setCorrectForDetectorNonlinearity', spectrometerIndex, channelIndex, enable);
% Enable correct for electrical dark.
invoke(spectrometerObj, 'setCorrectForElectricalDark', spectrometerIndex, channelIndex, enable);

%% Acquire the spectrum.

wavelengths = invoke(spectrometerObj, 'getWavelengths', spectrometerIndex, channelIndex);
% Get the wavelengths of the first spectrometer and save them in a double
% array.
spectralData = invoke(spectrometerObj, 'getSpectrum', spectrometerIndex);

%% Plot the waveform.

plot(wavelengths, spectralData);
title('Optical Spectrum');
ylabel('Intensity (counts)');
xlabel('\lambda (nm)');
grid on
axis tight

%% Clean up.

disconnect(spectrometerObj);

delete (spectrometerObj);