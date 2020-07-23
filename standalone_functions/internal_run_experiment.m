function [x, y] = internal_run_experiment(TYPE_EXP, ...
                                          numberShots, groupsShots, timeDecay, ...
                                          INST_NI_DIGITAL, ...
                                          handle, Depth, TriggerHoldoff, ...
                                          between, handles)
%{
    Parameters:
        mode : 'F' or 'T'
        numberShots : number of blank/read shots
        groupsShots : groups of numberShots
        shutter_1, shutter_2, shutter_3 : NI-DAQ channel objects
        handle : handle to scope
        Depth : necessary for plotting
        TriggerHoldoff : necessary for plotting
        between : necessary for plotting
    Returns:
        x : corrected time data
        y : corrected voltage data
%}

ret = CsMl_QueryStatus(handle);
if ret < 0
    msgbox('Check timebase selection!');
    return;
end

transfer.Mode = CsMl_Translate('Default', 'TxMode');
transfer.Channel = 1;
transfer.Segment = 1;
transfer.Start = -TriggerHoldoff;
transfer.Length = Depth + TriggerHoldoff;

% start by opening shutters to allow triggering
outputSingleScan(INST_NI_DIGITAL, [1 0 0]); % open shutter 1
if TYPE_EXP == 1
    outputSingleScan(INST_NI_DIGITAL, [1 0 1]); % open shutter 3
end

% begin counting trigger events -> now experiment is going
reads_S = {};
for s = 1:groupsShots % first iterate over the groups of shots
    reads_session = {};
    for session = 1:2 % 1, 2 = background, sample
        pause(0.005);
        
        % exit function if ABORT query returns true
        abort_status = get(handles.ABORT, 'UserData');
        if abort_status
            x = 'void';
            y = 'void';
            return;
        end
        
        % shutter 2 closed during blank read
        if session == 2
            outputSingleScan(INST_NI_DIGITAL, [1 1 0])
        else
            outputSingleScan(INST_NI_DIGITAL, [1 0 0])
        end
        
        reads_N = {};
        for read = 1:numberShots
            [ret] = CsMl_Capture(handle);
            CsMl_ErrorHandler(ret, 1, handle);

            status = CsMl_QueryStatus(handle);
            while status ~= 0
                status = CsMl_QueryStatus(handle);
            end
            
            % data transfer
            [ret, data, actual] = CsMl_Transfer(handle, transfer);
            CsMl_ErrorHandler(ret, 1, handle);
            reads_N = [reads_N, data];    
        end
        
        mean_reads_N = mean(cat(numberShots, reads_N{:}), numberShots);
        reads_session = [reads_session, mean_reads_N];    
    end  

    corrected_data = reads_session{2} - reads_session{1}; % correct for background
    reads_S = [reads_S, corrected_data];
    
    outputSingleScan(INST_NI_DIGITAL, [0 0 0]);  
    pause(timeDecay); 
    
    outputSingleScan(INST_NI_DIGITAL, [1 0 0]); % open shutter 1
    if TYPE_EXP == 1
        outputSingleScan(INST_NI_DIGITAL, [1 0 1]); % open shutter 3
    end
end

y = mean(cat(groupsShots, reads_S{:}), groupsShots);
length = size(y, 2);
xpos = actual.ActualStart;
xpos_end = length + xpos - 1;
points = (xpos:xpos_end)';
x = between * transpose(points);
pause(2.5);

