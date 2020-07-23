function [status_byte] = internal_QC9514_pulsestate(object, state)

%{
    Parameters:
        object : the QC9514 object
        state : 'ON' or 'OFF'
    Returns:
        status : 1/0
            1 : successful connection
            0 : port not available
%}

command = [':PULSE0:STATE' ' ' state ' ' '<cr><lf>'];
fprintf(object, command);
pause(0.1);
if isempty(fscanf(object)) == 1
    status_byte = 0;
else
    status_byte = 1;
end
