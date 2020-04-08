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
% p_illum -- specify the name of the folder within your current directory 
% that contains the data for the three illuminants

function f_processdata_illuminants (fn,p_illum)

    illuminant = ['D65';'D50';'-A-'];

    for i = 1:3
        %% 1: Create file paths for results

        %Check if your folder for the images exists
        if ~exist([fn '\IlluminantImages'],'dir')
            mkdir([fn '\IlluminantImages']); %Create the folder if it doesnt
        end

        %% 2: Calculate LAB
        
        %Save current directory path
        directory = cd();
        
        % Prepares the illuminant
        load ([directory '\' p_illum '\spec_cie' illuminant(i,:)],'spec'); % Load specs for illuminant
        ls = spec(1:10:401,2); % Load light source information from specs

        load([fn '\trans_mean_camera'],'trans_array_m','sizex', 'sizey'); % Load mean transmittance data
        load([fn '\trans_std_camera'], 'trans_array_s'); % Load standard deviation transmittance data

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