% 11-12-19: First version

close all;
clearvars -except ol490 ludl pr

% Starts the clock
tic

%% 1: Initialization
% % Sample name
% name_of_sample = 'Filter_KW32BW10';

% Init ludl and PR730
ludl = LudlClass('COM14');
pr = pr730Class('COM17');

%% 2: ROI
ROI = f_findroi_simple(ol490, ludl, 'w'); % 'g' for green light, 'w' for broadband

%% 3: Measurements
% Number of repeated measurements
% n_meas = 1; 

% Call the measurements
% f_meas_filter(name_of_sample, ol490, ludl, pr, n_meas, ROI, 'on');
[lambda_pr, spectra_pr, spectra_backgound_pr, lambda_qe, spectra_qe, spectra_backgound_qe] = f_meas_OL490_bw(ol490, pr, ludl, ROI);

% Closes ludl and PR730
pr.close;
ludl.close;

%% 4 Graphics
figure('units','normalized','outerposition',[0 0 1 1]);
wl_array = 380:10:780;
for wl = 1:41
    subplot(6,7,wl)
    plot(lambda_pr, spectra_pr(wl, :), 'b'); hold on;
    plot(lambda_pr, spectra_backgound_pr(wl, :), 'r');
    
    ylabel('Intensity (counts)');
    xlabel('\lambda (nm)');
    title(sprintf('%d',wl_array(wl)))
end

figure('units','normalized','outerposition',[0 0 1 1]);
for wl = 1:41
    subplot(6,7,wl)
    plot(lambda_qe, spectra_qe(wl, :), 'b'); hold on;
    plot(lambda_qe, spectra_backgound_qe(wl, :), 'r');
    
    ylabel('Intensity (counts)');
    xlabel('\lambda (nm)');
    title(sprintf('%d',wl_array(wl)))
end

%% Save data
path = 'F:\Data_Paul\RawData\021420\OL490_Spectra';
mkdir(path);

save([path '\lambda_pr'],'lambda_pr');
save([path '\spectra_pr'],'spectra_pr');
save([path '\spectra_backgound_pr'],'spectra_backgound_pr');

save([path '\lambda_qe'],'lambda_qe');
save([path '\spectra_qe'],'spectra_qe');
save([path '\spectra_backgound_qe'],'spectra_backgound_qe');

% Stops the clock
toc