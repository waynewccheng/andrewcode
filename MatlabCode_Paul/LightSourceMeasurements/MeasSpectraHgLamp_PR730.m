%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measure Hg lamp of Ol490 light source %
% to check for second order spectrum

close all;
clearvars -except ol490 pr

% Starts the clock
tic

% Meas informations
name_of_file = 'Spectra_HgLamp_Meas_PR730_Lens';

% Date
formatOut = 'mm/dd/yy';
date = datestr(now,formatOut);
date_strp = strrep(date, '/', '');

% Path
p_data = ['F:\Data_Paul\RawData\' date_strp '\' name_of_file];

% Open remote control for PR730
if exist('pr') == 0
   pr = pr730Class('COM15'); 
end

% Nb measurements
n_meas = 10;

% Store results
spectra = zeros(n_meas, 401);
spectra_m = zeros(1, 401);
spectra_s = zeros(1, 401);

% Loops to get n_meas measurements, using the 8x speed on PR730
for i = 1:n_meas
    tmp = pr.measure;
%     if (i == 1)
%         lambda = (tmp.wavelength)';
%     end
    spectra(i, :) = (tmp.amplitude)';
end
lambda = (tmp.wavelength)';

% Spectra stats
spectra_m(1, :) = mean(spectra)';
spectra_s(1, :) = (std(spectra)./sqrt(n_meas))';

pr.close;
clear pr;

% Graphics
figure;
plot(lambda, spectra_m(1, :));

figure;
errorbar(lambda, spectra_m(1, :), spectra_s(1, :))

% Creates folder to rawdata
mkdir(p_data);

% Save the data
cd(p_data);
save('lambda','lambda');
save('spectra','spectra');
save('spectra_m','spectra_m');
save('spectra_s','spectra_s');

% Stops the clock
toc