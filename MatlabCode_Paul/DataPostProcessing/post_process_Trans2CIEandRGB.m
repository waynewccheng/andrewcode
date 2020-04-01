%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Post processing of the WSI image transmittance measurements %
%%%%%%%%%%%%%%%%%%%%%%%

% input: trans_array_m, trans_array_s
% ouput: LAB, CovLAB, XYZ, CovXYZ, rgb, im

% The functions used here are in <Your folder>\FilterMeasurements and <Your
% folder>\TissueMeasurements, put these folders in your path

clearvars;
close all;

%% Path to data
name_of_sample = 'BiomaxOrgan10_Bladder_M13';                                                      % Modify accordingly

data_folder = 'C:\Users\Paul_Lemaillet\Documents\WholeSlideImaging\ProgMatlab\AndrewLamont\Data\'; % Modify accordingly

input_folder = [data_folder 'input\'];                                                             % Create this folder in the data_folder, put the folder with the raw data there. In my case for this example 
                                                                                                   % (please see FolderTree image on the github), I had:
                                                                                                   % C:\Users\Paul_Lemaillet\Documents\WholeSlideImaging\ProgMatlab\AndrewLamont\Data\BiomaxOrgan10_Bladder_M13 and in this folder
                                                                                                   % 2 subfolders: BiomaxOrgan10_Bladder_M13_sample and BiomaxOrgan10_Bladder_M13_white containing the measurement data 
                                                                                                   % (img_background_stack.mat  vim_background_mean_array.mat  vim_std_array.mat
                                                                                                   % img_stack.mat, vim_background_std_array.mat, max_array.mat, vim_mean_array.mat)
                                                                                                   % The names of the measurements files is always the same, the subfolder names are as <sample name>_sample and <sample name>_white                                                                                                   

output_folder = [data_folder 'output\'];                                                           % Create this folder in the data_folder 

% These are par of the code that's in f_init_tissues.m
% Raw data
p_rdata = strcat(input_folder, name_of_sample);
p_sample = [p_rdata '\' name_of_sample '_sample'];
p_white = [p_rdata '\' name_of_sample '_white'];
   
% Processed data
p_pdata = strcat(output_folder, name_of_sample);
p_trans = [p_pdata '\Transmittance'];
p_cie = [p_pdata '\CIE_Coord'];
p_er = [p_pdata '\EndResults'];

% Creates folders to processed data
mkdir(p_pdata);

% Create the subfolders
mkdir(p_trans);
mkdir(p_cie);
mkdir(p_er);
    
% Path to D65 illuminant
p_illuminant = 'C:\Users\Paul_Lemaillet\Documents\WholeSlideImaging\ProgMatlab\AndrewLamont\DataIlluminants'; % Path to D65 illuminant, modify accordingly

%% Camera: Calculate transmittance, based on f_meas_tissues.m, section 4
numberofshots = 10; % 10 for each image to compute the uncertainties

% Compute the tranmittance based on the temporal mean/std dev over numberofshots
[trans_array_m, trans_array_s, sizey, sizex] = f_frame2transmittance_white(p_sample, p_white, numberofshots);

% Corrects for potential Inf values in the transmittance
[trans_array_m, trans_array_s] = f_interp_infTval(trans_array_m, trans_array_s);

%% Camera: Calculate LAB, based on f_meas_tissues.m, section 5
% Prepares the illuminant, CIE D65
load ([p_illuminant '\spec_cied65'],'spec');
ls = spec(1:10:401,2);

% Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)

[LAB_array, CovLAB_array, XYZ_array, CovXYZ_array] = f_transmittance2LAB(trans_array_m, trans_array_s, sizey, sizex, ls, 'y'); % 'y' top trim the max tranmsittance to 1

% Save transmittance values and the CIELAB/CIEXYZ values pixel by pixel
save([p_trans '\trans_mean_camera'],'trans_array_m','sizey','sizex','-v7.3');
save([p_cie '\LAB_array'],'LAB_array');
save([p_cie '\XYZ_array'],'XYZ_array');

if ~isequal(numberofshots, 1)
    save([p_trans '\trans_std_camera'],'trans_array_s','sizey','sizex','-v7.3');
    save([p_cie '\CovLAB_array'],'CovLAB_array');
    save([p_cie '\CovXYZ_array'],'CovXYZ_array');
end

%% Reconstruct sRGB image, based on f_meas_tissues.m, section 6

% Rescale XYZ so that Y of D65 illuminant is 1
Y0 = 100;

% Convert to sRGB and save
rgb = f_XYZ2sRGB(XYZ_array/Y0);
save([p_er '\rgb'],'rgb')

% Tiff
im = reshape(rgb,sizey,sizex,3);
imwrite(im,[p_er '\truth.tif'])

% Visualize
figure
image(im);
axis image    
