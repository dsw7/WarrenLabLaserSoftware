function [HANDLE, BETWEEN, ACQINFO] = css(TIMEBASE)

CsMl_FreeAllSystems();

% initialize CompuScope hardware and driver
retval = CsMl_Initialize;
CsMl_ErrorHandler(retval); 

if TIMEBASE > 1 && TIMEBASE < 8
    Requested.Board = 1280; % CS12502 - fast
else
    Requested.Board = 214;  % CS8422 - slow
end

% get handle to available CompuScope systems
[retval, HANDLE] = CsMl_GetSystem(Requested);
CsMl_ErrorHandler(retval);

% pass configuration settings
Setup(HANDLE);

% query acquisition, channel and trigger handles
channel = 1;
trig_input_param = 1;

[retval, acqInfo] = CsMl_QueryAcquisition(HANDLE);
CsMl_ErrorHandler(retval);
[retval, chanAttributes] = CsMl_QueryChannel(HANDLE, channel);
CsMl_ErrorHandler(retval);
[retval, trigAttributes] = CsMl_QueryTrigger(HANDLE, trig_input_param);
CsMl_ErrorHandler(retval);

%{
args_m = [
      5e8, 5e8, 2.5e8, 1.25e8, 2.5e7, 2.5e7, ...
      1e7, 2.5e6, 1e6, 2e5, 1e5, 1e4, 2e3;
      
      912, 9008, 9008, 11264, 9008, 18000, 90000, ...
      90000, 90000, 90000, 90000, 90000, 90000;
      
      112, 1008, 1008, 1264, 1008, 2000, 10000, ...
      10000, 10000, 10000, 10000, 10000, 10000;
      
      2e-9, 2e-9, 4e-9, 8e-9, 4e-8, 4e-8, ...
      1e-7, 4e-7, 1e-6, 5e-6, 1e-5, 1e-4, 5e-4
             ];

SampleRate = args_m(1, TIMEBASE - 1);
DEPTH = args_m(2, TIMEBASE - 1);
TRIGGERHOLDOFF = args_m(3, TIMEBASE - 1);
BETWEEN = args_m(4, TIMEBASE - 1);
%}


M1 = [5e8 5e8 2.5e8 1.25e8, 2.5e7 2.5e7 1e7 2.5e6 1e6 2e5 1e5 1e4 2e3];
M2 = [912 9008 9008 11264 9008 18000 9e4 9e4 9e4 9e4 9e4 9e4];
M3 = [112 1008 1008 1264 1008 2000 1e4 1e4 1e4 1e4 1e4 1e4];
M4 = [2e-9 2e-9 4e-9 8e-9 4e-8 4e-8 1e-7 4e-7 1e-6 5e-6 1e-5 1e-4 5e-4];

SAMPLERATE = M1(TIMEBASE - 1);
DEPTH = M2(TIMEBASE - 1);
TRIGGERHOLDOFF = M3(TIMEBASE - 1);
BETWEEN = M4(TIMEBASE - 1);

% SAMPLERATE = 500000000;
% DEPTH = 912;
% TRIGGERHOLDOFF = 112;
% BETWEEN = 2.0000e-09;
TIMEOUT = 1000000;
INPUTRANGE = 10000;

% these are some example acquisition settings for the fast digitizer
% the remaining settings are system defaults
acqInfo.SampleRate = SAMPLERATE;
acqInfo.Depth = DEPTH;
acqInfo.SegmentSize = DEPTH + TRIGGERHOLDOFF;
acqInfo.TriggerTimeout = TIMEOUT;
acqInfo.TriggerHoldoff = TRIGGERHOLDOFF;

ACQINFO = acqInfo; % make attribute global

retval = CsMl_ConfigureAcquisition(HANDLE, acqInfo);
CsMl_ErrorHandler(retval);

% these are some example channel settings for the fast digitizer
% the remaining settings are system defaults
chanAttributes(channel).Channel = channel;
chanAttributes(channel).InputRange = INPUTRANGE;
if TIMEBASE > 1 && TIMEBASE < 8
    chanAttributes(channel).Impedance = 50;
else
    chanAttributes(channel).Impedance = 1e6;
end

retval = CsMl_ConfigureChannel(HANDLE, chanAttributes);
CsMl_ErrorHandler(retval);

% these are some example trigger settings for the fast digitizer
% the remaining settings are system defaults
trigAttributes.Trigger = trig_input_param;
trigAttributes.Slope = CsMl_Translate('Positive', 'Slope');
trigAttributes.Level = 15;
trigAttributes.Source = -1;
trigAttributes.ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');
trigAttributes.ExtRange = INPUTRANGE;

retval = CsMl_ConfigureTrigger(HANDLE, trigAttributes);
CsMl_ErrorHandler(retval);

% here we actually pass these settings to the hardware
retval = CsMl_Commit(HANDLE);
CsMl_ErrorHandler(retval);

