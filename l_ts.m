function [time, voltage] = l_ts(TIMEBASE, EXP_MODE, S_NUMBER, ...
                                TIME_DECAY, HANDLE_DAQ, HANDLE_SCOPE, ...
                                SCOPE_TRANSFER_OBJ, BETWEEN_SCOPE)

% we will need:
% the timebase
% experimental mode (i.e. TA or fluorescence)
% groups of shots
% decay time between reads
% handle to DAQ to control shutters locally
% handle to scope to obtain data

% we will return
% time data
% voltage data

% we can plot these data locally but need to return the data into the
% main script so that user can save them

% delay between reads
DEL = containers.Map('KeyType', 'int32', 'ValueType', 'double');
DEL(8) = 0.01;
DEL(9) = 0.04;
DEL(10) = 0.1;
DEL(11) = 0.5;
DEL(12) = 1.0;
DEL(13) = 10.0;
DEL(14) = 50.0;

% first ensure all shutters closed
outputSingleScan(HANDLE_DAQ, [0 0 0]);
pause(0.5);

% wait then begin experiment
reads_S = {};
for s = 1:S_NUMBER
    for session = 1:2
        if session == 1 % background           
            [ret] = CsMl_Capture(HANDLE_SCOPE); % begin wait for trigger event
            CsMl_ErrorHandler(ret, 1, HANDLE_SCOPE);
            
            if EXP_MODE == 2 % fluorescence
                outputSingleScan(HANDLE_DAQ, [1 0 0]); % open first shutter
                pause(0.15); % 150 ms guarantees one pulse will hit PD
                outputSingleScan(HANDLE_DAQ, [0 0 0]); % close first shutter
            elseif EXP_MODE == 3 % TA
                outputSingleScan(HANDLE_DAQ, [1 0 1]); % open first shutter
                pause(0.15); % 150 ms guarantees one pulse will hit PD
                outputSingleScan(HANDLE_DAQ, [0 0 1]); % close first shutter
            end

            % query status and break when buffer filled
            status = CsMl_QueryStatus(HANDLE_SCOPE);
            while status ~= 0
                status = CsMl_QueryStatus(HANDLE_SCOPE);
            end
            
            % data transfer
            [ret, data_bg, actual] = CsMl_Transfer(HANDLE_SCOPE, SCOPE_TRANSFER_OBJ);
            CsMl_ErrorHandler(ret, 1, HANDLE_SCOPE);
            
            pause(DEL(TIMEBASE) + 0.05 * DEL(TIMEBASE));
                                
        else % experimental
            [ret] = CsMl_Capture(HANDLE_SCOPE); % begin wait for trigger event
            CsMl_ErrorHandler(ret, 1, HANDLE_SCOPE);            
            
            if EXP_MODE == 2 % fluorescence
                outputSingleScan(HANDLE_DAQ, [1 1 0]); % open first & second shutter
                pause(0.15); % 150 ms guarantees one pulse will hit PD
                outputSingleScan(HANDLE_DAQ, [0 0 0]); % close first & second shutter
            elseif EXP_MODE == 3 % TA
                outputSingleScan(HANDLE_DAQ, [1 1 1]); % open first & second shutter
                pause(0.15); % 150 ms guarantees one pulse will hit PD
                outputSingleScan(HANDLE_DAQ, [0 0 1]); % close first & second shutter
            end
            
            % query status and break when buffer filled
            status = CsMl_QueryStatus(HANDLE_SCOPE);
            while status ~= 0
                status = CsMl_QueryStatus(HANDLE_SCOPE);
            end
            
            % data transfer
            [ret, data_ex, actual] = CsMl_Transfer(HANDLE_SCOPE, SCOPE_TRANSFER_OBJ);
            CsMl_ErrorHandler(ret, 1, HANDLE_SCOPE);
            
            pause(DEL(TIMEBASE) + 0.05 * DEL(TIMEBASE));
            
        end
    end
    corrected = data_ex - data_bg;
    reads_S = [reads_S, corrected];
    pause(TIME_DECAY);
end

voltage = mean(cat(S_NUMBER, reads_S{:}), S_NUMBER);
length = size(voltage, 2);
xpos = actual.ActualStart;
xpos_end = length + xpos - 1;
points = (xpos:xpos_end)';
time = BETWEEN_SCOPE * transpose(points);

% fix for TA y-axis offset
voltage = voltage - mean(voltage(:, 1:50));

% plot
plot(time, voltage);
grid minor;
grid on;
set(gca, 'color', [1 1 0]);
xlabel('Time (s)', 'FontSize', 10);
ylabel('Voltage (V)', 'FontSize', 10);
ylim([ min(voltage) - 0.005, max(voltage) + 0.005 ]);
msgbox('The experiment has completed!', 'Success');


