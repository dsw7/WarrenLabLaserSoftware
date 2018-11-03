function [status_byte] = internal_SETmonochromator_wavelength(object,wavelength)
%{
Function for setting monochromator wavelength

    Parameters:
        object : the monochromator object
        wavelength : in nm
    Returns:
        status_byte : a status byte below 128 suggests the command was
        accepted

%}

wavelength = 100 * wavelength;
[hibyte, midbyte, lowbyte] = internal_number2byte(wavelength);
byte_sequence = [hibyte midbyte lowbyte];

% GOTO (see page 26, DK240 user manual)

% To DK240: <16>
% From DK240: <16>
fwrite(object, 16);
pause(0.5);
fread(object, object.BytesAvailable);

% To DK240: <High Byte><Mid Byte><Low Byte>
pause(0.5);
fwrite(object, byte_sequence);
pause(0.5);

% From DK240: <Status Byte><24>
data = fread(object, object.BytesAvailable);
status_byte = data(1, 1);
pause(0.5);
