%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurements of stability of OL490 %
%%%

% Author: Paul Lemaillet, using Wei-Chung Cheng's code

% 06/04/2019:

close all;

%% 
% Filter informations
date = '060519';
name_of_sample = 'OL490_normal'

path_to_data = ['C:\Users\wcc\Desktop\MatlabCode_Paul\Data\RawData\' date '\' name_of_sample];
path_to_prog = pwd; 

foldername_sample = [name_of_sample '_sample'];     % For the OL490 spectra

%%
% Open remote control for PR730
if exist('pr') == 0
   pr = pr730Class('COM15'); 
end

% Starts the clock
tic

%%
% Measurements with the spectro-radiometer PR730

% Turn on the light
ol490.setWhite

% Measure a spectrum with the spectro-radiometer
n_meas = 30; % Number of repeated mearurements
lambda = zeros(1, 401);
s_data = zeros(n_meas, 401);

% Loops through filter, white and black measurements

% Measurement alert
disp('Measurement');

% Loops to get n_meas measurments, using the 8x speed on PR730
for i = 1:n_meas
    tmp = pr.measure;
    if (i == 1)
        lambda = (tmp.wavelength)';
    end
    s_data(i, :) = (tmp.amplitude)';
end

clear tmp;

% Compute mean value and error
figure(1);
m_spectrum = mean(s_data);
std_spectrum =  std(s_data)/sqrt(n_meas);
errorbar(lambda, m_spectrum, std_spectrum );

figure(2);
plot(std_spectrum./m_spectrum*100);

% Stability at 550 nm (col 171)
figure(3);
plot(s_data(:, 171));
m_550nm = mean(s_data(:, 171))
std_550nm = std(s_data(:, 171))/sqrt(n_meas)
std_550nm / m_550nm * 100
range(s_data(:, 171))

%%
% Close remote control for PR730
pr.close;
clear pr;

%%
% Stops the clock
toc