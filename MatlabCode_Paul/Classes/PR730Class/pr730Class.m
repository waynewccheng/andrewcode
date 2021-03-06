classdef pr730Class
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        comPort
    end
    
    methods
        %% Enter remote mode
        function obj = pr730Class (portname)
            % enter and exit the remote mode to avoid receiving the 'REMOTE MODE' message; should flush the serial port 
            % enter Remote mode
        % enter and exit the remote mode to avoid receiving the 'REMOTE MODE' message; should flush the serial port 
        % enter Remote mode

        obj.comPort = rs232Class(portname);

        obj.comPort.send('P');
        obj.comPort.send('H');
        obj.comPort.send('O');
        obj.comPort.send('T');
        obj.comPort.send('O');
        
        pause(2)

        Settings = obj.status
        
        end


        %%  
        function close (obj)
            % exit Remote mode
            obj.comPort.send('Q')
            obj.comPort.send(13)

            % close RS232
            obj.comPort.close;
            
            pause(1)
        end
    
        %%  
        function ret = status (obj)
            obj.comPort.send('D')
            obj.comPort.send('602')
            obj.comPort.send(13)
            
            ret = obj.comPort.get;
        end        
        %%
        function spect = measure (obj)
            slocal = zeros(401,2);

            % send command to take a measurement
            obj.comPort.send('M')
            obj.comPort.send('5')
            obj.comPort.send(13)

            % obtain reading here
            k = obj.comPort.get;

            % get rid of the leading 'REMOTE MODE'
            while (k(1)>'9' || k(1)<'0'),
                k = k(2:end);
            end

            ind = 0;
            for ii = 380:780
                k = obj.comPort.get;
                % get rid of the leading 'REMOTE MODE'
                while (k(1)>'9' || k(1)<'0'),
                    k = k(2:end);
                end
                val = textscan(k,'%d,%f\n');
                val2 = cell2mat(val(2));

                ind = ind + 1;
                slocal(ind,1) = ii;
                slocal(ind,2) = val2;
            end

            spect = SpectrumClass(slocal(:,1),slocal(:,2));
        end        
    
    end

end

