function [wavelength, status_byte,data] = internal_GETmonochromator_wavelength(object)
%{
Function for getting current wavelength from DK240 monochromator

    Parameters:
        object : the monochromator object
    Returns:
        wavelength : in nm
        status_byte : a status byte below 128 suggests the command was
        accepted
        
* NOTES *
Byte syntax as follows:
    29 < - write byte
     0 < - hibyte
   242 < - midbyte
    48 < - lowbyte
     0 < - status byte
    24 < - cancel byte
%}

% WAVE? (see page 32, DK240 user manual)

% To DK240: <29>
fwrite(object, 29);
pause(0.5);

% From DK240: <29><High Byte><Mid Byte><Low Byte><Status Byte><24>
data = fread(object, object.BytesAvailable);

SIZE = size(data);
if SIZE(1, 1) == 6 % DK240 "1.9008e+04" bug fix
    wavelength = internal_byte2number(data(2:4, 1));
    status_byte = data(5, 1);
else
    wavelength = internal_byte2number(data(3:5, 1));
    status_byte = data(6, 1);
end

wavelength = wavelength / 100;
pause(0.5);

%{
Monochromator will sometimes return a wavelength in the following form:
    1.9008e+04

This seems to be caused by a frameshift whereby sequence of bytes is
frameshifted by a unit of 1.

    24                          29
    29          Instead of:     1                
     1                          44
    44                          200
   200                          0
     0                          24               
    24

I don't know why this is happening but I have put in a fix for this issue.
%}

%{
    0    0.25 0.5  0.75 1              
 5  0    0    0    0    0         
10  0    0    0    0    0            
15  1    1    1    1    1           
20  1    1    1    1    1          
25  E    1    1    1    1                
30  E    1    1    1    1                           
35  E    E    1    1    1           
40  E    E    E    1    1
45  E    E    E    E    1
50  E    E    E    E    E   
%}

%{
Pause value as a function of abs(change in wavelength)
x = [20 25 30 35 40]
y = [0 0.25 0.5 0.75 1]
y = 0.05 * x - 1
%}







