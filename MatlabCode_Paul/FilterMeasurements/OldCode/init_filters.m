%% 
% Collects the info on the spectrometer and the camera, the objective,
% etc... and store them in the meas_info.txt file
% Creates the folders and sub-folders

% 09-30-19: path to folders as outputs

% 08-20-19: no black measurements, no dedicated folder

function [p_sample, p_white, p_spectro, p_trans, p_cie, p_st] = init_filters(pr, name_of_sample)

    % Spectrophotometer information
    % Get the speed
    pr_status = pr.status;
    pos_comma = strfind(pr_status,',');
    speed = char((pr_status(pos_comma(9)+1: pos_comma(10)-1)));
    spectro_id = char((pr_status(pos_comma(1)+1: pos_comma(2)-1)));

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
    p_spectro = [p_rdata '\' name_of_sample '_spectro_' speed];
    p_trans = [p_pdata '\Transmittance'];
    p_cie = [p_pdata '\CIE_Coord'];
        
    p_st = 'C:\Users\wcc\Desktop\MatlabCode_Paul\PointGreySpec';
    
    % Creates folder to rawdata and processed data
    mkdir(p_rdata);
    mkdir(p_pdata);

    % Create subfolders
    mkdir(p_sample);
    mkdir(p_white);
    mkdir(p_spectro);
    mkdir(p_trans);
    mkdir(p_cie);
     
    % Write info to meas_info.txt file
    fileID = fopen([p_rdata '\meas_info.txt'], 'w');

    fprintf(fileID,'Date:\t%s, %s\r\n', date, time);
        
    fprintf(fileID,'\r\n%s\r\n','Spectrometer');
    fprintf(fileID,'\r\nDeviceId:\t%s\r\nSpeed:\t\t%s\r\n',spectro_id, speed);
    
    fprintf(fileID,'\r\n%s\r\n','Camera');
    fprintf(fileID,['\r\n' CamType{1} '\t%s\r\n' CamType{3} '\t%d\r\n' CamType{5} '\t\t%s\r\n'], CamType{2}, CamType{4}, CamType{6});
    
    fprintf(fileID,'\r\n%s\r\n', 'Objective');
    fprintf(fileID,'\r\nId:\t%s\r\n', obj_type);

    fprintf(fileID,'\r\n%s\r\n', 'Paths');
    fprintf(fileID,'RawData:\t%s\r\n', p_rdata);
    fprintf(fileID,'ProcessedData:\t%s\r\n', p_pdata);
         
    fclose(fileID);

end
