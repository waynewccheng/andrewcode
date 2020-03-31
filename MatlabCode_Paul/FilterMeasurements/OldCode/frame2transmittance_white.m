% 7-30-2015
% convert frames (DDL) to transmittance by using reference white background
% 

function [transmittance_array, sizey, sizex] = frame2transmittance_white (foldername_sample, foldername_white)

    disp('Combining frames into transmittance...')

    fnin = sprintf('%s/vimarray',foldername_white);
    load(fnin,'vimarray');
    vimarray0 = vimarray;
    
    [sizewl sizey sizex] = size(vimarray0);
    
    fnin = sprintf('%s/vimarray',foldername_sample);
    load(fnin,'vimarray');
    
    % calculate the reflectance
    ddl_array = reshape(vimarray,sizewl,sizey*sizex);
    ddl_white_array = reshape(vimarray0,sizewl,sizey*sizex);
    
    transmittance_array = ddl_array ./ ddl_white_array;
    
    % This take the minimum element between transmittance_array and 1, i.e.
    % limits the max transmittance value to 1
    transmittance_array = min(transmittance_array,1);
    
    % ----------------------------------
    return
end
