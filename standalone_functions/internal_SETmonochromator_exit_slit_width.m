function [status_byte] = internal_SETmonochromator_exit_slit_width(object,width)
%{
Function for setting DK240 monochromator exit slit width

    Parameters:
        object : the monochromator object
        width : the desired slit width in micrometers
    Returns:
        status_byte : a status byte below 128 suggests the command was
        accepted

%}

% S2ADJ (page 30, DK240 user manual)

% To DK240: <32>
% From DK240: <32>
fwrite(object, 32);
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