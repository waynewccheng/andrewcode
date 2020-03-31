%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the center coordinates of the tissue matrix, has to be a rectangle

% 09-25-19: First version

function xy = f_findcorners(ol490, ludl)
    % Turn on the light
    ol490.setWhite

    % Sets the camera
    vid = videoinput('pointgrey', 1, 'F7_Mono8_844x676_Mode5');
%     src = getselectedsource(vid);

    vid.FramesPerTrigger = 1;

    preview(vid);

    % Center of right back corner
    input('Press Enter to save location of right back center:')
    xy(1, :) = ludl.getXY;
    
    % Center of right front corner
    input('Press Enter to save location of right front center:')
    xy(2, :) = ludl.getXY;
    
    % Center of left front corner
    input('Press Enter to save location of left front center:')
    xy(3, :) = ludl.getXY;
        
    % Center of left back corner
    input('Press Enter to save location of left back center:')
    xy(4, :) = ludl.getXY;

    % Center of white patch
    input('Press Enter to save location of white patch:')
    xy(5, :) = ludl.getXY;
    
    delete(vid);
end