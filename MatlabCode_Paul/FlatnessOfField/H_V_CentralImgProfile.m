close all; 
clearvars -except ol490;

% Open camera
cam = CameraClass9MPSmall_PL2

% % Set Shutter Time
% 
% % OL490
% intensity = 100;
% ol490.setPeak(550,10,intensity);
% % ol490.setWhite
% pause(1);
% 
% % First image
% numberofshots = 1;
% [tmp_stack, ~, ~, ~] = cam.snap(numberofshots, 'filter');
% rows = size(tmp_stack, 1);
% cols = size(tmp_stack, 2);
% 
% % Shutter time
% shutter = 37; % 37.4 ms is the max value
% step = 1;
% min_shutter = 1;
% 
% cam.setShutter(shutter);
% pause(1);
% 
% % Second image, needed otherwise uses first image that is not
% % saturated but should
% [tmp_stack, ~, ~, ~] = cam.snap(numberofshots, 'filter');
% 
% while max(max(tmp_stack)) == 255 && shutter > min_shutter
%     shutter = shutter - step;
%     disp(['Shutter = ' num2str(shutter) ' Max = ' num2str(max(max(tmp_stack)))])
%     cam.setShutter(shutter);
%     [tmp_stack, ~, ~, ~] = cam.snap(numberofshots, 'filter');
% end

% Multiple images for mean profile value
numberofshots = 10;

% Green
intensity = 100;
ol490.setPeak(550,10,intensity);
cam.setShutter(21); %21

% Image stack
[green_stack, ~, int_mean_array_g, int_std_array_g] = cam.snap(numberofshots, 'filter');
pause(1);

% BB
ol490.setWhite;
cam.setShutter(6); %6

% Image stack
[white_stack, ~, int_mean_array_bb, int_std_array_bb] = cam.snap(numberofshots, 'filter');

% Metric
U = @(p) 100*(mean(p)-std(p))/(mean(p)+std(p));
CR = @(img) (max(max(img)) - min(min(img)))/(max(max(img)) + min(min(img)));
RMS = @(img) sqrt(sum(sum((img-mean2(img)).^2))/(size(img, 1)*size(img, 2)));
CRMS = @(img) RMS(img)/mean2(img);

% Profiles
rows = size(green_stack, 1);
cols = size(green_stack, 2);

figure('units','normalized','outerposition',[0 0 1 1]);
prof_h_g = int_mean_array_g(rows/2, :);
prof_v_g = int_mean_array_g(2:end, cols/2); %First row has out of range values
subplot(1, 3, 1);
imagesc(int_mean_array_g); hold on;
line([0 cols], [rows/2 rows/2], 'Color', [1 0 0]);
line([cols/2 cols/2], [0 rows], 'Color', [1 0 0]);
title(['CR = ' num2str(CR(int_mean_array_g)) ' CRMS = ' num2str(CRMS(int_mean_array_g))]);
subplot(1, 3, 2);
plot(prof_h_g);
title(['U = ' num2str(U(prof_h_g))]);
subplot(1, 3, 3);
plot(prof_v_g);
title(['U = ' num2str(U(prof_v_g))]);

figure('units','normalized','outerposition',[0 0 1 1]);
prof_h_bb = int_mean_array_bb(rows/2, :);
prof_v_bb = int_mean_array_bb(2:end, cols/2);
subplot(1, 3, 1);
imagesc(int_mean_array_bb); hold on;
line([0 cols], [rows/2 rows/2], 'Color', [1 0 0]);
line([cols/2 cols/2], [0 rows], 'Color', [1 0 0]);
title(['CR = ' num2str(CR(int_mean_array_bb)) ' CRMS = ' num2str(CRMS(int_mean_array_bb))]);
subplot(1, 3, 2);
plot(prof_h_bb);
title(['U = ' num2str(U(prof_h_bb))]);
subplot(1, 3, 3);
plot(prof_v_bb);
title(['U = ' num2str(U(prof_v_bb))]);

% Exit
cam.close;

% Save
p_rdata = 'F:\Data_Paul\RawData\111919\Flatness_Of_Field\Int_Sphere_Illum';
save([p_rdata '\int_mean_array_bb'],'int_mean_array_bb');

save([p_rdata '\int_mean_array_g'],'int_mean_array_g');
