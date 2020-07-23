function [CH1, CH2, CH3, CH4] = internal_NI_channels(dig1, dig2, dig3, ana4)
%{
Create all NI channel objects for operating shutters and other peripherals.

Parameters:
    dig1 : true/false --> channel CH1
    dig2 : true/false --> channel CH2
    dig3 : true/false --> channel CH3
    dig4 : true/false --> channel CH4
Returns:
    Channel objects
%}

% digital channels
CH1 = daq.createSession('ni');
CH2 = daq.createSession('ni');
CH3 = daq.createSession('ni');
% lines 0, 1, 2 --> ports 17, 18, 19

outCh = [CH1, CH2, CH3];
inCh = [dig1, dig2, dig3];

% digital channels
for i = 1:3
    if inCh(1, i) == true
        lin = num2str(i - 1);
        lin = strcat('Port0/Line', lin);
        outCh(1, i).addDigitalChannel('Dev1', lin, 'OutputOnly');
    end
end

% analog channels
CH4 = daq.createSession('ni');
if ana4 == true
    CH4.addAnalogOutputChannel('Dev1', 'ao0', 'Voltage');
end

