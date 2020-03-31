%% 
% Collects the info of the spectrometer and of the camera, the objective,
% etc... and store them in the meas_info.txt file
% Creates the folders and sub-folders

% 08-20-19: no black measurements, no dedicated folder

function [f_s, f_w, f_spec, f_t, f_CIE, p_rdata, p_pdata, p_prog] = init_PL2(pr, name_of_filter)

    % Spectrophotometer information
    % Get the speed
    pr_status = pr.status;
    pos_comma = strfind(pr_status,',');
    speed = char((pr_status(pos_comma(9)+1: pos_comma(10)-1)));
    spectro_id = char((pr_status(pos_comma(1)+1: pos_comma(2)-1)));

    % Camera information
    cam = CameraClass9MPSmall_PL2;
    [CamType, CamMode, CamParam] = cam.info;
    cam.close;

    % Objective information
    obj_type = 'Zeiss 20x Plan-Apochromat';
 
    % Other info
    formatOut = 'mm/dd/yy';
    date = datestr(now,formatOut);
    date_strp = strrep(date, '/', '');
    time = datestr(now, 'HH:MM:SS');

    % Paths
    p_rdata = ['F:\Data_Paul\RawData\' date_strp '\' name_of_filter];
    p_pdata = ['F:\Data_Paul\ProcessedData\' date_strp '\' name_of_filter];
    p_prog = 'C:\Users\wcc\Desktop\MatlabCode_Paul\FilterMeasurements'; 

    % Folders for camera measurements
    f_s = [name_of_filter '_sample'];  % For the filter spectra
    f_w = [name_of_filter '_white'];    % For the 100% tranmittance
%     f_b = [name_of_filter '_black'];    % For the 0% tranmittance

    % Folder for spectro-radiometer measurements
    f_spec = [name_of_filter '_spectro_' speed]; 

    % Folder for transmittance results
    f_t = 'Transmittance'; 

    % Folder for CIE coordonates results
    f_CIE = 'CIE_Coord'; 
    
    % Creates folder to rawdata and processed data
    mkdir(p_rdata);
    mkdir(p_pdata);

    % Create subfolders
    cd(p_rdata);
    mkdir(f_spec);

    cd(p_pdata);
    mkdir(f_t);
    mkdir(f_CIE);

    % Write info to meas_info.txt file
    cd(p_rdata);
    fileID = fopen('meas_info.txt','w');

    fprintf(fileID,'Date:\t%s, %s\r\n', date, time);
        
    fprintf(fileID,'\r\n%s\r\n','Spectrometer');
    fprintf(fileID,'\r\nDeviceId:\t%s\r\nSpeed:\t\t%s\r\n',spectro_id, speed);
    
    fprintf(fileID,'\r\n%s\r\n','Camera');
    fprintf(fileID,['\r\n' CamType{1} '\t%s\r\n' CamType{3} '\t%d\r\n' CamType{5} '\t\t%s\r\n'], CamType{2}, CamType{4}, CamType{6});
    
    fprintf(fileID,'\r\n%s\r\n', 'Objective');
    fprintf(fileID,'\r\nId:\t%s\r\n', obj_type);

    fprintf(fileID,'\r\n%s\r\n', 'Paths');
    fprintf(fileID,'\r\nCode:\t\t%s\r\n', p_prog);
    fprintf(fileID,'RawData:\t%s\r\n', p_rdata);
    fprintf(fileID,'ProcessedData:\t%s\r\n', p_pdata);
         
    fclose(fileID);

end
