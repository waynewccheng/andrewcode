% 04-03-20: Process raw data to compute transmittance, CIEXYX,
% CIELAB, and sRGB coordinates, and output a .png image for the specified
% sample with the specified illuminant (D65, D50, or A)

% Code modified from f_meas_tissue.m function:
%   - Hardware-controlling sections (previously, sections 1-3) removed.
%   - Loading of specs from the illuminant (lines 63-64) modified to be
%   specific to the illuminant type.
%   - Image output has been changed to reflect the name of the illuminant
%   and the file-type changed to .png instead of .tiff. 
%   - Graphics section (previously, section 7) removed.

% Raw Data is pulled from the path: (Your Desired Location)\(Sample Name) 
% Modify line 34 to specify the desired location on your computer

% Processed Data is written to the path:
% (Your Desired Location)\(Illuminant)\(Sample Name)
% Modify line 39 to specify the desired location on your computer

% Modify line 59 to specify where the path where illuminant data is saved
% on your computer. 

% Modify line 63 to specify the path where this function is saved in on 
% your computer.


function f_processdata_illuminants (sample_name,illuminant)
    %% 1: Camera: Calculate transmittance
    % Compute the tranmittance based on the temporal mean/std dev over numberofshots
    
    numberofshots = 41;
    
    %Specify raw data paths
    p_rdata = ['D:\DigitalPathology\ColorDetail\ImageData\031320\RawData\' sample_name]; % Path with all of the raw data for the sample
    p_sample = [p_rdata '\' sample_name '_sample']; % Path with raw data for the sample images
    p_white = [p_rdata '\' sample_name '_white']; % Path with raw data for the white images
    
    %Specify processed data paths
    p_pdata = ['D:\DigitalPathology\ColorDetail\ImageData\AndrewProcessedData\' illuminant '\' sample_name]; % Path for all of the processed data
    p_trans = [p_pdata '\Transmittance']; % Path for the processed transmittance data
    p_cie = [p_pdata '\CIE_Coord']; % Path for the processed CIE data
    p_er = [p_pdata '\EndResults']; % Path for the processed End Results
    
    %Create processed data folders
    mkdir(p_pdata); % Create processed data larger folder
    mkdir(p_trans); % Create processed data sub-folders
    mkdir(p_cie);
    mkdir(p_er);
    
    % Compute Transmittance value from raw data
    [trans_array_m, trans_array_s, sizey, sizex] = f_frame2transmittance_white(p_sample, p_white, numberofshots); 

    % Corrects for potential Inf values in the transmittance
    [trans_array_m, trans_array_s] = f_interp_infTval(trans_array_m, trans_array_s);

    %% 2: Camera: Calculate LAB

    % Prepares the illuminant
    cd('D:\DigitalPathology\ColorDetail\Matlab_Color\Scripts\Data Illuminants'); % Change Directory to 'Data Illuminants' folder
    load (['spec_cie' illuminant],'spec'); % Load specs for illuminant
    ls = spec(1:10:401,2); % Load light source information from specs

    cd('D:\DigitalPathology\ColorDetail\Matlab_Color\Scripts\TissueMeasurements') % Change Directory back to 'Tissue Measurements' folder
    % Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)
    [LAB_array, CovLAB_array, XYZ_array, CovXYZ_array] = f_transmittance2LAB(trans_array_m, trans_array_s, sizey, sizex, ls, 'y'); % 'y' top trim the max tranmsittance to 1

    % Save transmittance values and the CIELAB/CIEXYZ values by pixel
    save([p_trans '\trans_mean_camera'],'trans_array_m','sizey','sizex','-v7.3');
    save([p_cie '\LAB_array'],'LAB_array');
    save([p_cie '\XYZ_array'],'XYZ_array');

    if ~isequal(numberofshots, 1)
        save([p_trans '\trans_std_camera'],'trans_array_s','sizey','sizex','-v7.3');
        save([p_cie '\CovLAB_array'],'CovLAB_array');
        save([p_cie '\CovXYZ_array'],'CovXYZ_array');
    end

    %% 3: Reconstruct sRGB image

    % Rescale XYZ so that Y of illuminant is 1
    Y0 = 100;

    % Convert to sRGB and save
    rgb = f_XYZ2sRGB(XYZ_array/Y0);
    save([p_er '\rgb'],'rgb')

    % Create png from sRGB values
    im = reshape(rgb,sizey,sizex,3);
    imwrite(im,[p_er '\' illuminant '.png'])

    % Visualize image
    figure
    image(im);
    axis image

    % Check if some pixels are still NaN
    nan_test = find(isnan(im) ~=0);
end