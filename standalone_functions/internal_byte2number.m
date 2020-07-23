function [output] = internal_byte2number(byte_matrix)
%{

A function for converting byte matrices to raw numbers

    Parameters:
        M : matrix containing the three bytes of interest
    Returns:
        output: a numerical result

Example:

fwrite(DK240, 29);
pause(0.5);
wavelength = fread(DK240, DK240.BytesAvailable);
wavelength = wavelength(2:4, 1);
output = internal_byte2number(wavelength);
output = output / 100; % divide by 100 to get nm

%}

byte_vector = [65536 255 1];
output = dot(byte_matrix, byte_vector);
