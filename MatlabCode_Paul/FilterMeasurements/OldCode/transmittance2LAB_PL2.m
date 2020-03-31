% 11-15-19: Added possibility of trans_array_s being empty (only 1
% acquisition shot, no uncertainty computation)

% 7-19-2016
% D65
% 7-23-2015
% convert reflectance into RGB using D65
% usage: rgb = reflectance2D65(reflectance_array7);

function [LAB, CovLAB, XYZ, CovXYZ] = transmittance2LAB_PL2(trans_array_m, trans_array_s, sizey, sizex, ls, trim)
    
    % Set the max input T to 1 and proportionaly scales the uncertainty
    % (mutltiplicative noise assumption)
    
    switch trim
        case 'y'
            tmp = min(trans_array_m, 1);
            diff = tmp - trans_array_m;
            mask = diff ~=0;
            
            if ~isempty(trans_array_s)
                t_m_masked = trans_array_m(mask);
                t_s_masked = trans_array_s(mask);
                ratio = t_s_masked./t_m_masked;
                trans_array_s(mask) = ratio;
            end
            
            trans_array_m = tmp;
            
        case'n'
            
    end

    disp('Combining reflectance and illuminant into LAB...')

    % reference white
    XYZ0 = spd2XYZ_PL2(1, 0, ls, 'white');

    % Image dimensions here
    if sizey ~= 1
        ls_array = repmat(ls,1,sizey*sizex);
    else
        ls_array = ls;
    end
    
    disp('  calculate XYZ...')
    [XYZ, CovXYZ] = spd2XYZ_PL2(trans_array_m, trans_array_s, ls_array, 'sample');

    disp('  calculate LAB...')
    [LAB, CovLAB] = XYZ2lab(XYZ, XYZ0, CovXYZ);

end