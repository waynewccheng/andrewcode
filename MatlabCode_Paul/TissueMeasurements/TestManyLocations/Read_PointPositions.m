clearvars;
close all;

n_row = 3;
n_col = 8;

for i = 1:n_row*n_col
    f_name = ['tmp_' num2str(i) '_xy.txt'];
    posxy_all(i, :) = csvread(f_name);
    delete(f_name);
end

csvwrite('posxy_all.txt', posxy_all);

% posxy_all = csvread('posxy_all.txt');

I = imread('Phantom2_img2.tif');
imshow(I);

% Plot the points and add a listener for adjustement
k = 1;
for i = 0:n_col-1
 for j = 0:n_row-1
    images.roi.Point(gca,'Position',[posxy_all(k, 1) posxy_all(k, 2)], 'Color', 'r');
    k = k + 1;
 end
end