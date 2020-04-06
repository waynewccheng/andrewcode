% 04-03-20: Use transmittance data & data illuminant functions to compute
% CIEXYX,CIELAB, and sRGB coordinates and output a .png image.

% Code modified from f_meas_tissue.m function:
%   - Only retained LAB calculation and sRGB image reconstruction sections
%   - Added a for loop to loop through the 3 data illuminants
%   - Modified loading of specs from the illuminant (lines 36-37) to be
%   specific to the illuminant type.
%   - Eliminated lines that save CIE coordinate & sRGB data.
%   - Changed image output to reflect the name of the illuminant and
%   changed file type to .png instead of .tiff. 

% fn -- specify the folder path that contains the transmittance data of 
% interest

% Modify line 34 to specify the path where illuminant data is saved on your
% computer
% Modify line 42 to specify the path where this function is saved in on 
% your computer.

function f_processdata_illuminants (fn)

    illuminant = ['D65';'D50';'-A-'];

    for i = 1:3
        %% 1: Create file paths for results

        %Create path to write images to
        mkdir([fn '\IlluminantImages']);

        %% 2: Calculate LAB

        % Prepares the illuminant
        cd('D:\DigitalPathology\ColorDetail\Matlab_Color\Scripts\Data Illuminants'); % Change Directory to 'Data Illuminants' folder
        load (['spec_cie' illuminant(i,:)],'spec'); % Load specs for illuminant
        ls = spec(1:10:401,2); % Load light source information from specs

        cd(fn); % Change directory to the folder containing transmittance data
        load('trans_mean_camera','trans_array_m','sizex', 'sizey'); % Load mean transmittance data
        load('trans_std_camera', 'trans_array_s'); % Load standard deviation transmittance data

        cd('D:\DigitalPathology\ColorDetail\Matlab_Color\Scripts\TissueMeasurements') % Change Directory back to 'Tissue Measurements' folder
        % Trans -> XYZ -> LAB with saving XYZ and LAB (values + uncertainties)
        [LAB_array, CovLAB_array, XYZ_array, CovXYZ_array] = f_transmittance2LAB(trans_array_m, trans_array_s, sizey, sizex, ls, 'y'); % 'y' top trim the max tranmsittance to 1

        %% 3: Reconstruct sRGB image

        % Rescale XYZ so that Y of illuminant is 1
        Y0 = 100;

        % Convert to sRGB and save
        rgb = f_XYZ2sRGB(XYZ_array/Y0);

        % Create png from sRGB values
        im = reshape(rgb,sizey,sizex,3);
        imwrite(im,[fn '\IlluminantImages\' illuminant(i,:) '.png'])

        % Visualize image
        figure
        image(im);
        axis image
    end

end