clearvars;
close all;

I = imread('Phantom2_img2.tif');
imshow(I);

n_row = input('Nb rows ');

n_col = input('Nb cols ');

% To Select 4 points
for i = 1:4
    roi(i) = images.roi.Point;
    draw(roi(i));
    posxy(i, :) = roi(i).Position;
end

% Compute x, y steps
d_x = mean([posxy(2, 1) - posxy(1, 1), posxy(3, 1) - posxy(4, 1)]);
d_y = mean([posxy(4, 2) - posxy(1, 2), posxy(3, 2) - posxy(2, 2)]);
stp_x = d_x/(n_col-1);
stp_y = d_y/(n_row-1);

% Plot the points and add a listener for adjustement
k = 1;
for i = 0:n_col-1
 for j = 0:n_row-1
    roi_all(k) = images.roi.Point(gca,'Position',[posxy(1, 1)+ i*stp_x posxy(1, 2)+ j*stp_y  ], 'Color', 'r');
    posxy_all(k, :) = roi_all(k).Position;
    csvwrite(['tmp_' num2str(k) '_xy.txt'], posxy_all(k, :));
    k = k + 1;
 end
end
addlistener(roi_all,'ROIMoved',@(src, evt) allevents(src, evt, posxy_all));
    
%-----------------------------------------------------------------
% Callback function, save outputs to tmp file to be treated later

function allevents(src,evt, varargin)
evname = evt.EventName;
arg1 = varargin{1};
    switch(evname)
        case{'ROIMoved'}
            tmp = (arg1 == evt.PreviousPosition);
            pos = find(prod(tmp, 2) == 1);
            if evt.CurrentPosition ~= evt.PreviousPosition
                xy = evt.CurrentPosition;
            else
                xy = evt.PreviousPosition;
            end
            csvwrite(['tmp_' num2str(pos) '_xy.txt'], xy);
    end
end

