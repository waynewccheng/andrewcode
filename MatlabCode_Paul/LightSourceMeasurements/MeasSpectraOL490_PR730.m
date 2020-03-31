%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measure spectrum of Ol490 light source %
% to check for second order spectrum

close all;
clearvars -except ol490 pr

% Starts the clock
tic

% Meas informations
name_of_file = 'Spectra_OL490_Meas_PR730_2InchesTube';

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

% OL490 banswidth and range
bandwidth = 10;
% wl_range = 380:10:780;
wl_range = 380:390;
n_lambda = size(wl_range, 2);

% Store results
spectra = zeros(n_meas, 401);
spectra_m = zeros(size(wl_range, 2), 401);
spectra_s = zeros(size(wl_range, 2), 401);

% Span wavelength and measure spectra
k = 1;

for wl=wl_range
   
    disp(['Lambda = ' num2str(wl)]);
    
    % prepare light
    ol490.setPeak(wl,bandwidth, 100);
    pause(1); % This deals with 07-1-2019 potential bug
    
    % Loops to get n_meas measurements, using the 8x speed on PR730
    for i = 1:n_meas
        tmp = pr.measure;
        if (i == 1)
            lambda = (tmp.wavelength)';
        end
        spectra(i, :) = (tmp.amplitude)';
    end
    
    % Spectra stats
    spectra_m(k, :) = mean(spectra)';
    spectra_s(k, :) = (std(spectra)./sqrt(n_meas))';

    k = k + 1;
end

pr.close;
clear pr;

% Graphics
n_rows = double(uint8(sqrt(n_lambda)));
n_cols = double(uint8(n_lambda/floor(sqrt(n_lambda))));
figure('units','normalized','outerposition',[0 0 1 1]);
for i = 1:n_lambda
    subplot(n_rows,n_cols,i)
    plot(lambda, spectra_m(i, :))
    title(sprintf('%d',wl_range(i)))
end

figure('units','normalized','outerposition',[0 0 1 1]);
for i = 1:n_lambda
    subplot(n_rows,n_cols,i)
    errorbar(lambda, spectra_m(i, :), spectra_s(i, :))
    title(sprintf('%d',wl_range(i)))
end

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