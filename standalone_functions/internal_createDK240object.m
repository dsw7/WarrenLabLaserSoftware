function [object, status] = internal_createDK240object(serial_port)
%{
Function establishes a connection with the Digikrom DK240 monochromator

    Parameters:
        serial_port : 'COM3', 'COM4', etc.
    Returns:
        object : the monochromator object
        status : 1/0
            1 : successful connection
            0 : port not available
%}

% see page 34, bottom, DK240 user manual for these specifications
object = serial(serial_port);
object.Baudrate = 9600;
object.Stopbits = 1;
object.Parity = 'none';
object.Databits = 8;

fopen(object);

% handshake
fwrite(object, 27);
pause(0.2);
try
    status = fread(object, object.BytesAvailable);
catch
    status = 0;
end
