%% 
% Collects the info on the camera, the objective,
% etc... and store them in the meas_info.txt file
% Creates the folders and sub-folders

% 09-26-19: first implementation based on init_filters (in FilterMeasurements folder)

function [p_sample, p_white, p_trans, p_cie, p_er, p_st] = init_tissues(name_of_sample)

    % Camera information
    cam = CameraClass9MPSmall_PL2;
    [CamType, ~, ~] = cam.info;
    cam.close;

    % Objective information
    obj_type = 'Zeiss 20x Plan-Apochromat';
 
    % Other info
    formatOut = 'mm/dd/yy';
    date = datestr(now,formatOut);
    date_strp = strrep(date, '/', '');
    time = datestr(now, 'HH:MM:SS');

    % Paths
    p_rdata = ['F:\Data_Paul\RawData\' date_strp '\' name_of_sample];
    p_pdata = ['F:\Data_Paul\ProcessedData\' date_strp '\' name_of_sample];
    
    p_sample = [p_rdata '\' name_of_sample '_sample'];
    p_white = [p_rdata '\' name_of_sample '_white'];
    p_trans = [p_pdata '\Transmittance'];
    p_cie = [p_pdata '\CIE_Coord'];
    p_er = [p_pdata '\EndResults'];
    
    p_st = 'C:\Users\wcc\Desktop\MatlabCode_Paul\PointGreySpec'; % Shutter time table

    % Creates folder to rawdata and processed data
    mkdir(p_rdata);
    mkdir(p_pdata);

    % Create subfolders
    mkdir(p_sample);
    mkdir(p_white);
    mkdir(p_trans);
    mkdir(p_cie);
    mkdir(p_er);

    % Write info to meas_info.txt file
    fileID = fopen([p_rdata '\meas_info.txt'],'w');

    fprintf(fileID,'Date:\t%s, %s\r\n', date, time);
   
    fprintf(fileID,'\r\n%s\r\n','Camera');
    fprintf(fileID,['\r\n' CamType{1} '\t%s\r\n' CamType{3} '\t%d\r\n' CamType{5} '\t\t%s\r\n'], CamType{2}, CamType{4}, CamType{6});
    
    fprintf(fileID,'\r\n%s\r\n', 'Objective');
    fprintf(fileID,'\r\nId:\t%s\r\n', obj_type);

    fprintf(fileID,'\r\n%s\r\n', 'Paths');
    fprintf(fileID,'RawData:\t%s\r\n', p_rdata);
    fprintf(fileID,'ProcessedData:\t%s\r\n', p_pdata);
         
    fclose(fileID);

end
