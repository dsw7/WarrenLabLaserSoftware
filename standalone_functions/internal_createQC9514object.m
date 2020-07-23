function [object, status_byte] = internal_createQC9514object(serial_port)
%{
Function for creating the QC9514 digital delay generator object

    Parameters:
        serial_port : 'COM3', 'COM4', etc.
    Returns:
        object : the device object
        status : 1/0
            1 : successful connection
            0 : port not available
%}

% see page 35, QC9500+ user manual
object = serial(serial_port);
object.Baudrate = 9600;
object.Stopbits = 1;
object.Parity = 'none';
object.Databits = 8;

fopen(object);

% handshake with the device by querying serial number
% see page 45, QC9500+ user manual
pause(0.1);
fprintf(object, ':SYSTem:SERNumber? <cr><lf>');
pause(0.1);

if isempty(fscanf(object)) == 1
    status_byte = 0;
else
    status_byte = 1;
end

