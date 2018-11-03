function [slit_width, status_byte] = internal_GETmonochromator_exit_slit_width(object)
%{
Function gets monochromator exit slit width from DK240

    Parameters:
        object : the monochromator object
    Returns:
        slit_width : slit width in micrometers
        status_byte : a status byte below 128 suggests the command was
        accepted

%}


% SLIT? (page 29, DK240 user manual)
fwrite(object,30);
pause(0.5); % wait for DK240 to write to buffer
data = fread(object, object.BytesAvailable);

%{
data return value is a vector of form:
<a, b, c, d, e, f>
    a = 30 // i.e. fwrite(object, 30) return
    b = high byte of ENTRANCE slit width
    c = low byte of ENTRANCE slit width
    d = high byte of EXIT slit width
    e = low byte of EXIT slit width
    f = <24>

%}

hibyte = data(4, 1);
lowbyte = data(5, 1);
status_byte = data(6, 1);
slit_width = 256 * hibyte + lowbyte; % does not use the internal_byte2number.m
pause(0.5);

