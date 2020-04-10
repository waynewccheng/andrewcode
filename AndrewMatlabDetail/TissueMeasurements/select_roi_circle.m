% 04-09-20 -- Select a circular area with which to create a mask of pixels
% to be analyzed, and recolor the pixels in the image

% p_image -- input the name or path of the image you want to use
% center -- declare the center of the circle you want to create
% radius -- declare the radius of the circle you want to create

function mask = select_roi_circle(p_image, center, radius)

% Read the image into a matrix
original = imread(p_image);

% Show the original image
figure;
subplot(2,1,1);
imshow(original);
title('Original Image');

% Draw the circle on the original image
drawcircle('Center', center, 'Radius', radius, 'color','r');

% Calculate the mathematical X and Y coordinates of the circle
theta = 0:0.1:2*pi; %Degrees 0 to 2 pi
Xcircle = center(1) + radius*cos(theta); %X coords. of the circle
Ycircle = center(2) + radius*sin(theta); %Y coords. of the circle

% Make a matrix with the X and Y positions of all pixels in the image
[sizex, sizey, num_colors] = size(original);
[Xpos Ypos] = meshgrid(1:sizey, 1:sizex);

% Create a binary array showing which pixels are encapsulated by the circle
binary = inpolygon(Xpos, Ypos, Xcircle, Ycircle);

% Output the X & Y coordinates of the encapsulated pixels
[y, x] = find(binary);
mask = [x, y];

% Change the color of the encapsulated pixels
modified = original;
for i = 1:size(mask(:,1))
    modified(mask(i,2),mask(i,1),:) = [255,0,0];
end

% Plot changed colors
subplot(2,1,2);
imshow(modified);
title('Recolored Pixels');

end


