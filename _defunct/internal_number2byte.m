function [hibyte, midbyte, lowbyte] = internal_number2byte(input_val)
%{
Function for converting raw number to byte matrix

    Parameters:
        input : the number we wish to convert to a set of bytes
    Returns:
        hibyte : float type
        midbyte : float type
        lowbyte : float type

Example for DK240 Monochromator:
* The DK240 uses hundrendths of nms as an input argument for wavelength. *

wavelength = 100;
wavelength = 100 * wavelength;
[a, b, c]=internal_number2byte(wavelength);
% a = 0
% b = 39
% c = 16

%}

hibyte = floor(input_val / 65536);
intermediate = (input_val - (65536 * hibyte)) / 256;
midbyte = floor(intermediate);
remainder = intermediate - floor(intermediate);
lowbyte = remainder * 256;