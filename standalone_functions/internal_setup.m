function [HANDLE, DEPTH, TRIGGERHOLDOFF, BETWEEN] = internal_setup(TIMEBASE)
%{
Function for setting up the oscilloscope. Portions of this function have
been inherited from a previous code developed by another group.

    Parameters:
        timebase : the timebase of interest between 1 and 13
    Returns:
        handle : handle to scope
        Depth : necessary for plotting
        TriggerHoldoff : necessary for plotting
        between : necessary for plotting
%}

% predefine all arguments for scope
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
         
if TIMEBASE > 1 && TIMEBASE < 8
    Requested.Board = 1280; % CS12502 - fast
else
    Requested.Board = 214;  % CS8422 - slow
end

inputRange = str2double('10000');
[ret] = CsMl_Initialize;
CsMl_ErrorHandler(ret); % will yield info if system is fucked
[ret, HANDLE] = CsMl_GetSystem(Requested);
CsMl_ErrorHandler(ret, 1, HANDLE); % will yield info if system is fucked
Setup(HANDLE);


% acquisition arguments
[ret, acqInfo] = CsMl_QueryAcquisition(HANDLE);
CsMl_ErrorHandler(ret, 1, HANDLE); % will yield info if system is fucked
SampleRate = args_m(1, TIMEBASE - 1);
DEPTH = args_m(2, TIMEBASE - 1);
TRIGGERHOLDOFF = args_m(3, TIMEBASE - 1);
BETWEEN = args_m(4, TIMEBASE - 1);

acqInfo.SampleRate = SampleRate;
acqInfo.ExtClock = 0;
acqInfo.Mode = CsMl_Translate('Dual', 'Mode');
acqInfo.SegmentCount = 1;
acqInfo.Depth = DEPTH;
acqInfo.SegmentSize = DEPTH + TRIGGERHOLDOFF;
acqInfo.TriggerTimeout = 1000000;
acqInfo.TriggerHoldoff = TRIGGERHOLDOFF;
acqInfo.TriggerDelay = 0;
acqInfo.TimeStampConfig = 0;

[ret] = CsMl_ConfigureAcquisition(HANDLE, acqInfo);
CsMl_ErrorHandler(ret, 1, HANDLE);


% channel arguments
i = 1;
[ret, chan] = CsMl_QueryChannel(HANDLE, i);
CsMl_ErrorHandler(ret,1,HANDLE); % will yield info if system is fucked
chan(i).Channel = i;
chan(i).Coupling = CsMl_Translate('DC', 'Coupling');
chan(i).DiffInput = 0;
chan(i).InputRange = inputRange;
if TIMEBASE > 1 && TIMEBASE < 8
    chan(i).Impedance = 50;
else
    chan(i).Impedance = 1e6;
end
chan(i).DcOffset = 0;
chan(i).DirectAdc = 0;
chan(i).Filter = 0;

[ret] = CsMl_ConfigureChannel(HANDLE, chan);
CsMl_ErrorHandler(ret, 1, HANDLE);


% trigger arguments
[ret, trig] = CsMl_QueryTrigger(HANDLE, 1);
CsMl_ErrorHandler(ret, 1, HANDLE); % will yield info if system is fucked
trig.Trigger = 1;
trig.Slope = CsMl_Translate('Positive', 'Slope');
trig.Level = 15;
trig.Source = -1; % -1 = external, 1 = channel 1
trig.ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');
trig.ExtRange = inputRange;
[ret] = CsMl_ConfigureTrigger(HANDLE, trig);
CsMl_ErrorHandler(ret, 1, HANDLE);


% transmit all parameters to the scope
[ret] = CsMl_Commit(HANDLE);
CsMl_ErrorHandler(ret, 1, HANDLE);
