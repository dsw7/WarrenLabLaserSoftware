classdef internal_QC9514_channel_manager
    % see pages 41-46, QC9500+ user manual
    properties
        Channel % 'A', 'B', 'C', or 'D'
        Device 
    end
    
    methods
        function status_byte = TOGGLE(obj, state)
            % toggle channel : {Enabled/Disabled}
            c = containers.Map;
            c('A') = ':PULSE1';
            c('B') = ':PULSE2';
            c('C') = ':PULSE3';
            c('D') = ':PULSE4';
            
            d = containers.Map;
            d('ON') = ':STATE ON <cr><lf>';
            d('OFF') = ':STATE OFF <cr><lf>';
            
            command = strcat(c(obj.Channel), d(state));
            fprintf(obj.Device, command);
            pause(0.1);
            if isempty(fscanf(obj.Device)) == 1
                status_byte = 0;
            else
                status_byte = 1;
            end
        end
        
        function status_byte = WIDTH(obj, width)
            % set width
            width = num2str(width);          
            command = [':PULSE:WIDT' ' ' width ' ' '<cr><lf>'];
            fprintf(obj.Device, command);
            pause(0.1);
            if isempty(fscanf(obj.Device)) == 1
                status_byte = 0;
            else
                status_byte = 1;
            end
        end 
        
        function status_byte = DELAY(obj, delay)
            % set delay            
            c = containers.Map;
            c('A') = ':PULSE1';
            c('B') = ':PULSE2';
            c('C') = ':PULSE3';
            c('D') = ':PULSE4';
                                   
            command = strcat(c(obj.Channel), ':DELAY');                 
            delay = num2str(delay);
            command = [command ' ' delay ' ' '<cr><lf>'];
            fprintf(obj.Device, command);
            pause(0.1);
            if isempty(fscanf(obj.Device)) == 1
                status_byte = 0;
            else
                status_byte = 1;
            end
        end
        
        function status_byte = SYNC(obj, direction)
            % set delay
            %{
                Parameters: 
                    direction : TO, CHA, CHB, CHC, CHD
            %}
            
            c = containers.Map;
            c('A') = ':PULSE1';
            c('B') = ':PULSE2';
            c('C') = ':PULSE3';
            c('D') = ':PULSE4';
                                   
            command = strcat(c(obj.Channel), ':SYNC');                 
            command = [command ' ' direction ' ' '<cr><lf>'];
            fprintf(obj.Device, command);
            pause(0.1);
            if isempty(fscanf(obj.Device)) == 1
                status_byte = 0;
            else
                status_byte = 1;
            end
        end         
    end
end

