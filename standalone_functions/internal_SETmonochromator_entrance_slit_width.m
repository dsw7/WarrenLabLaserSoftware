function [status_byte] = internal_SETmonochromator_entrance_slit_width(object,width)
%{
Function for setting DK240 monochromator entrance slit width

    Parameters:
        object : the monochromator object
        width : the desired slit width in micrometers
    Returns:
        status_byte : a status byte below 128 suggests the command was
        accepted

%}

% S1ADJ (page 29, DK240 user manual)

% To DK240: <31>
% From DK240: <31>
fwrite(object, 31);
pause(0.5);
fread(object, object.BytesAvailable);

lowbyte = rem(width, 256); 
hibyte = floor(width / 256);

% To DK240: <High Byte><Low Byte>
fwrite(object, [hibyte lowbyte]);
pause(0.5);

% From DK240: <Status byte><24> // comes out as one array
output_byte = fread(object, object.BytesAvailable);
status_byte = output_byte(1, 1);
pause(0.5);