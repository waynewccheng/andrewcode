% WCC 2/5/2021
% Q: how to convert Zeiss scan of Paul's color target into CIELAB

classdef Patch2CIELAB < handle
    
    properties (Constant)
        pic_name = 'RoscoluxPhantom_Full_1-11-21';
        ROI_xy_filename = 'ROI_xy.mat'
        n_patch = 24;
    end
    
    properties
        filepath = ''
        ROI_xy = zeros(Patch2CIELAB.n_patch,4);
        rgb_mean = zeros(Patch2CIELAB.n_patch,3);
        rgb_std = zeros(Patch2CIELAB.n_patch,3);
        lab = zeros(Patch2CIELAB.n_patch,3);
    end
    
    methods
        
        function obj = Patch2CIELAB
            if getenv('username') == 'wcc'
                obj.filepath = ['' obj.pic_name '.tif'];
            else
                obj.filepath = ['E:\DigitalPathology\WSI_Zeiss\DigiPath_RoscoluxPhantom\' obj.pic_name '.tif'];
            end
        end
        
        function select_patch (obj)
            % Read the image into a matrix
            original = imread(obj.filepath);
            
            % Show the original image
            figure;
            % subplot(2,1,1);
            imshow(original);
            title('Select the Region of Interest', 'FontSize',20);
            
            for i = 1:obj.n_patch
                xy1 = ginput(1);
                fprintf('%d: %d %d\n',i,xy1(1),xy1(2))
                xy2 = ginput(1);
                fprintf('%d: %d %d\n',i,xy2(1),xy2(2))
                obj.ROI_xy(i,1:2) = xy1;
                obj.ROI_xy(i,3:4) = xy2;
            end
            
            xy = obj.ROI_xy;
            save(obj.ROI_xy_filename,'xy')
        end
        
        function evaluate_patch (obj)
            
            % Read the image into a matrix
            original = imread(obj.filepath);
            load(obj.ROI_xy_filename,'xy')
            
            for i = 1:obj.n_patch
                box = int32(xy(i,:));
                roi = original(box(2):box(4),box(1):box(3),:);
                roi1d = reshape(roi,size(roi,1)*size(roi,2),3);
                rgb = mean(roi1d)/255;
                obj.rgb_mean(i,:) = rgb;
                obj.rgb_std(i,:) = std(double(rgb));
                obj.lab(i,:) = rgb2lab(rgb,'WhitePoint','d65','ColorSpace','srgb');
            end
            
        end   
        
        function im = recreate_patch (obj)
            w = 8;
            h = 3;
            im = uint8(zeros(h,w,3));
            for i = 1:obj.n_patch
                row = floor((i-1)/w)+1;
                col = uint8(mod((i-1),w))+1;
                fprintf('%d %d\n',row,col)
                im(row,col,1) = uint8(obj.rgb_mean(i,1)*255);
                im(row,col,2) = uint8(obj.rgb_mean(i,2)*255);
                im(row,col,3) = uint8(obj.rgb_mean(i,3)*255);
            end
            
            image(im)
            
            return
        end
    end
    
end