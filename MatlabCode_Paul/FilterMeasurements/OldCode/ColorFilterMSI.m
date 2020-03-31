classdef ColorFilterMSI < handle
    
    properties
        vim_mean_array
        id
        spectra
        spectra_mean
        transmittance
        spd
        spd_d65
        XYZ
        XYZ_d65
        lab
        wavelength_range_pr730 = 380:1:780;
        list_patch = [3 24 34 39 40 43 46 48 51 52 56 57 59 60 68 71 77 85 88 91 93 95 97 99 310 316 336 337 342 347 356 360 389 398];
    end
    
    methods
        
        function test (obj)
        end
        
        function obj = ColorFilterMSI (patch_id)
            obj.id = patch_id;
            
            
            obj.showDataMSI_Transmittance(patch_id);

            
            return
            
            %            obj.show3Spectra();
            
            
            %            obj.calcSpectraMean();
            
            % obj.showSpectraMean();
            
            %            obj.calcTransmittance();
            
            % obj.showTransmittance();
            
            %            obj.calcSPD();
            
            % obj.showSPD();
            
            %            obj.calcXYZ();
            
            %            obj.calcLAB();
            
            %            [obj.lab]
        end
        
        function showSPD (obj)
            hold on
            plot(obj.wavelength_range_pr730,obj.spd)
        end
        
        function calcSPD (obj)
            obj.spd_d65 = obj.getD65();
            
            obj.spd = obj.transmittance .* obj.spd_d65;
        end
        
        function spec = getD65 (obj)
            load('spec_cied65','spec')
            spec = spec(:,2);
        end
        
        function showSpectraMean (obj)
            hold on
            plot(obj.wavelength_range_pr730,obj.spectra_mean(:,1),'-r')
            plot(obj.wavelength_range_pr730,obj.spectra_mean(:,2),'-g')
            plot(obj.wavelength_range_pr730,obj.spectra_mean(:,3),'-b')
            % too large for 34 subplots
            % legend('Sample','100%','0%')
            axis([380 780 0 8e-4])
        end
        
        function calcTransmittance (obj)
            sample = obj.spectra_mean(:,1);
            black = obj.spectra_mean(:,2);
            white = obj.spectra_mean(:,3);
            
            obj.transmittance = (sample-black) ./ (white-black);
        end
        
        function showTransmittance (obj)
            plot(obj.wavelength_range_pr730,obj.transmittance)
            axis([obj.wavelength_range_pr730(1) obj.wavelength_range_pr730(end) 0 1])
        end
        
        function calcSpectraMean (obj)
            obj.spectra_mean = squeeze(mean(obj.spectra,1));
        end
        
        function getDataMSI (obj,patch_id)
 %           filename = sprintf('.\\input\\Filter_%02d\\Filter_%02d_sample\\vim_mean_array.mat',patch_id,patch_id)
            filename = sprintf('./input/Filter_%02d/Filter_%02d_sample/vim_mean_array.mat',patch_id,patch_id)
            load(filename,'vim_mean_array')
            obj.vim_mean_array = vim_mean_array;
        end
        
        function showDataMSI (obj,patch_id,name)
            
 %           filename = sprintf('.\\input\\Filter_%02d\\Filter_%02d_sample\\vim_mean_array.mat',patch_id,patch_id)
            filename = sprintf('./input/Filter_%02d/Filter_%02d_%s/vim_mean_array.mat',patch_id,patch_id,name)
            load(filename,'vim_mean_array')
            
            wl_array = 380:10:780;
            for wl = 1:34
                subplot(5,7,wl)
                
                vvname = sprintf('%s(wl,:,:)','vim_mean_array');
                vv = eval(vvname);
                im = squeeze(vv);
                imagesc(im)
                axis off
                axis image
                colorbar
                title(sprintf('%d',wl_array(wl)))
            end
    
        end
     
        function showDataMSI_Transmittance (obj,patch_id)
            
            name = 'sample';
            filename = sprintf('./input/Filter_%02d/Filter_%02d_%s/vim_mean_array.mat',patch_id,patch_id,name)
            load(filename,'vim_mean_array')
            v_sample = vim_mean_array;
            
            name = 'black';
            filename = sprintf('./input/Filter_%02d/Filter_%02d_%s/vim_mean_array.mat',patch_id,patch_id,name)
            load(filename,'vim_mean_array')
            v_black = vim_mean_array;

            name = 'white';
            filename = sprintf('./input/Filter_%02d/Filter_%02d_%s/vim_mean_array.mat',patch_id,patch_id,name)
            load(filename,'vim_mean_array')
            v_white = vim_mean_array;
            
            vt = (v_sample-v_black)./(v_white-v_black);
            
            %% show the subplots
            figure('units','normalized','outerposition',[0 0 1 1])
            
            wl_array = 380:10:780;
            for wl = 1:41
                subplot(6,7,wl)
                
                vvname = sprintf('%s(wl,:,:)','vt');
                vv = eval(vvname);
                im = squeeze(vv);
                imagesc(im)
                axis off
                axis image
                colorbar
                title(sprintf('%d',wl_array(wl)))
            end
            
            saveas(gcf,sprintf('transmittance_%d.tif',patch_id))
            close all
        end
        
        function show3Spectra (obj)
            hold on
            for shot = 1:10
                plot(obj.wavelength_range_pr730,obj.spectra(shot,:,1),'-r')
                plot(obj.wavelength_range_pr730,obj.spectra(shot,:,2),'-g')
                plot(obj.wavelength_range_pr730,obj.spectra(shot,:,3),'-b')
                % too large when showing 34 subplots
                % legend('Sample','100%','0%')
                axis([380 780 0 8e-4])
            end
        end
        
        %% convert spectrum into XYZxyz
        % spd is a 41xN matrix
        % each spd is 41x1; no wavelength
        %
        function calcXYZ (obj)
            
            spd = obj.spd(1:10:end);
            
            % CIEXYZ 1931
            cmf = [
                380.0 0.001368 0.000039 0.006450;
                390.0 0.004243 0.000120 0.020050;
                400.0 0.014310 0.000396 0.067850;
                410.0 0.043510 0.001210 0.207400;
                420.0 0.134380 0.004000 0.645600;
                430.0 0.283900 0.011600 1.385600;
                440.0 0.348280 0.023000 1.747060;
                450.0 0.336200 0.038000 1.772110;
                460.0 0.290800 0.060000 1.669200;
                470.0 0.195360 0.090980 1.287640;
                480.0 0.095640 0.139020 0.812950;
                490.0 0.032010 0.208020 0.465180;
                500.0 0.004900 0.323000 0.272000;
                510.0 0.009300 0.503000 0.158200;
                520.0 0.063270 0.710000 0.078250;
                530.0 0.165500 0.862000 0.042160;
                540.0 0.290400 0.954000 0.020300;
                550.0 0.433450 0.994950 0.008750;
                560.0 0.594500 0.995000 0.003900;
                570.0 0.762100 0.952000 0.002100;
                580.0 0.916300 0.870000 0.001650;
                590.0 1.026300 0.757000 0.001100;
                600.0 1.062200 0.631000 0.000800;
                610.0 1.002600 0.503000 0.000340;
                620.0 0.854450 0.381000 0.000190;
                630.0 0.642400 0.265000 0.000050;
                640.0 0.447900 0.175000 0.000020;
                650.0 0.283500 0.107000 0.000000;
                660.0 0.164900 0.061000 0.000000;
                670.0 0.087400 0.032000 0.000000;
                680.0 0.046770 0.017000 0.000000;
                690.0 0.022700 0.008210 0.000000;
                700.0 0.011359 0.004102 0.000000;
                710.0 0.005790 0.002091 0.000000;
                720.0 0.002899 0.001047 0.000000;
                730.0 0.001440 0.000520 0.000000;
                740.0 0.000690 0.000249 0.000000;
                750.0 0.000332 0.000120 0.000000;
                760.0 0.000166 0.000060 0.000000;
                770.0 0.000083 0.000030 0.000000;
                780.0 0.000042 0.000015 0.000000;
                ];
            
            % show color matching functions
            if 0
                clf
                hold on;
                plot(cmf(:,1),cmf(:,2),'Color','r');
                plot(cmf(:,1),cmf(:,3),'Color','g');
                plot(cmf(:,1),cmf(:,4),'Color','b');
                title('Color Matching Functions')
            end
            
            % extend x_bar from 41x1 to 41xN
            input_n = size(spd,2);
            x_bar = repmat(cmf(:,2),1,input_n);
            y_bar = repmat(cmf(:,3),1,input_n);
            z_bar = repmat(cmf(:,4),1,input_n);
            
            X = sum(spd .* x_bar);
            Y = sum(spd .* y_bar);
            Z = sum(spd .* z_bar);
            
            % output Nx3
            XYZ = [X' Y' Z'];
            
            obj.XYZ = XYZ;
            
            %% d65
            % extend x_bar from 41x1 to 41xN
            spd_d65 = obj.spd_d65(1:10:end);
            
            input_n = size(spd_d65,2);
            x_bar = repmat(cmf(:,2),1,input_n);
            y_bar = repmat(cmf(:,3),1,input_n);
            z_bar = repmat(cmf(:,4),1,input_n);
            
            X_d65 = sum(spd_d65 .* x_bar);
            Y_d65 = sum(spd_d65 .* y_bar);
            Z_d65 = sum(spd_d65 .* z_bar);
            
            % output Nx3
            obj.XYZ_d65 = [X_d65' Y_d65' Z_d65'];
            
        end
        
        
        
        
        function calcLAB (obj)
            obj.lab = obj.XYZ2lab (obj.XYZ,obj.XYZ_d65);
        end
        
        %%
        %
        % CIEXYZ to CIELAB
        %
        function ret = XYZ2lab (obj,XYZ, XYZ_white)
            % XYZ is k-by-3
            % XYZ_white is 1-by-3
            k = size(XYZ,1);
            XYZn = repmat(XYZ_white,k,1);
            XYZ_over_XYZn = XYZ./XYZn;
            
            lstar = 116 * helpf(XYZ_over_XYZn(:,2)) - 16;
            astar = 500 * (helpf(XYZ_over_XYZn(:,1)) - helpf(XYZ_over_XYZn(:,2)));
            bstar = 200 * (helpf(XYZ_over_XYZn(:,2)) - helpf(XYZ_over_XYZn(:,3)));
            
            ret = [lstar astar bstar];
            %     if lstar > 100
            %         ['exceeding in xyz2lab']
            %         [x y z xn yn zn lstar astar bstar]
            %         lstar = 100;
            %     end
            
            return
            
            function ys = helpf (t)
                % conditional mask
                t_greater = (t > power(6/29,3));
                
                % conditional assignment
                t(t_greater) = t(t_greater) .^ (1/3);
                t(~t_greater) = t(~t_greater) * (((29/6)^2)/3) + 4/29;
                
                ys = t;
            end
        end
        
        %
        % lan1, lab2: 3xN matrix
        %
        function dEab = LAB2dEab (obj, lab1, lab2)
            % sum in the vertical direction
            dEab = sum((lab2-lab1) .^ 2,1) .^ 0.5;
        end
    end
end
