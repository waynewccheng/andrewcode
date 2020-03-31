% 7-19-2016
% D65
% 7-23-2015
% convert reflectance into RGB using D65
% usage: rgb = reflectance2D65(reflectance_array7);

function [LAB, CovLAB, XYZ, CovXYZ] = transmittance2LAB (trans_array_m, trans_array_s, sizey, sizex, ls)

    disp('Combining reflectance and illuminant into LAB...')

    % reference white
    XYZ0 = spd2XYZ(ls, 0, 'white');
    
    % whiteY = XYZ0(2);

    % Image dimensions here
    if sizey ~= 1
        ls_array = repmat(ls,1,sizey*sizex);
    else
        ls_array = ls;
    end

    disp('  calculate SPD...')
    spd_array = trans_array_m .* ls_array;
    
    disp('  calculate XYZ...')
    [XYZ, CovXYZ] = spd2XYZ(spd_array, trans_array_s, 'sample');

    disp('  calculate LAB...')
    [LAB, CovLAB] = XYZ2lab(XYZ, XYZ0, CovXYZ);

end