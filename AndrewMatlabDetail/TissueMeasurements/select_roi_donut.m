% 04-09-20 -- Select a donut-shaped area with which to create a mask of 
% pixels to be analyzed, and recolor the pixels in the image

% p_image -- input the name or path of the image you want to use
% center -- declare the center of the circle you want to create
% rad_in -- declare the inner radius of the donut you want to create
% rad_out -- declare the outer radius of the donut you want to create

function mask = select_roi_donut(p_image, center, rad_in, rad_out)

%Read the image into a matrix
original = imread(p_image);

%Show the original image
figure;
subplot(2,1,1);
imshow(original);
title('Original Image');

% Draw the inner and outer circles on the original image
drawcircle('Center', center, 'Radius', rad_in, 'color','r');
drawcircle('Center', center, 'Radius', rad_out, 'color','b');

% Calculate the X and Y coordinates of the circle
theta = 0:0.1:2*pi; % Degrees 0 to 2pi
Xc_in = center(1) + rad_in*cos(theta); % X coords. of the inner circle
Yc_in = center(2) + rad_in*sin(theta); % Y coords. of the inner circle
Xc_out = center(1) + rad_out*cos(theta); % X coords. of the outer circle
Yc_out = center(2) + rad_out*sin(theta); % Y coords. of the outer circle

% Make a matrix with the X and Y positions of all pixels in the image
[sizex, sizey, num_colors] = size(original);
[Xpos Ypos] = meshgrid(1:sizey, 1:sizex);

% Create a binary array showing which pixels are encapsulated by the circle
binary_in = inpolygon(Xpos, Ypos, Xc_in, Yc_in);
binary_out = inpolygon(Xpos, Ypos, Xc_out, Yc_out);
binary = binary_out(:,:) - binary_in(:,:);

% Output the X & Y coordinates of the encapsulated pixels
[y, x] = find(binary);
mask = [x, y];

% Change the color of the encapsulated pixels
modified = original;
for i = 1:size(mask(:,1))
    modified(mask(i,2),mask(i,1),:) = [0,0,255];
end

% Plot changed colors
subplot(2,1,2);
imshow(modified);
title('Recolored Pixels');

end