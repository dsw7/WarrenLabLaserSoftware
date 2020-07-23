function [x, y] = internal_run_experiment_lt(mode, ...
                                          numberShots, groupsShots, timeDecay, ...
                                          shutter_1, shutter_2, shutter_3, ...
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
                                          
%{
    corrected = []
    for s = 1:S
        background = []
        experimental = []
        for session = 1:2
            if session == 1 % the background
                open shutter 1 for 1 pulse
                close shutter 1
                delay for the entire timescale
                data from scope -> background []
            else % the actual experiment
                open shutter 1 for 1 pulse
                close shutter 1
                delay for the entire timescale
                data from scope -> experimental []

        experimental [] - background [] -> corrected []
    export corrected [] for plot
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

% ensure all shutters closed
shutter_1.outputSingleScan(0);
shutter_2.outputSingleScan(0);
shutter_3.outputSingleScan(0);

% the experiment
reads_S = {};
for s = 1:groupsShots
    for session = 1:2
        if session == 1 % background           
            [ret] = CsMl_Capture(handle); % begin wait for trigger event
            CsMl_ErrorHandler(ret, 1, handle);
            
            shutter_1.outputSingleScan(1); % open first shutter
            pause(0.15); % 150 ms guarantees one pulse will hit PD
            shutter_1.outputSingleScan(0); % close first shutter

            % query status and break when buffer filled
            status = CsMl_QueryStatus(handle);
            while status ~= 0
                status = CsMl_QueryStatus(handle);
            end
            
            % data transfer
            [ret, data_bg, actual] = CsMl_Transfer(handle, transfer);
            CsMl_ErrorHandler(ret, 1, handle);
            
            pause(1.0);
                                
        else % experimental
            [ret] = CsMl_Capture(handle); % begin wait for trigger event
            CsMl_ErrorHandler(ret, 1, handle);
            
            shutter_1.outputSingleScan(1); % open first shutter
            shutter_2.outputSingleScan(1); % open second shutter
            pause(0.15); % 150 ms guarantees one pulse will hit PD
            shutter_1.outputSingleScan(0); % close first shutter
            shutter_2.outputSingleScan(0); % close second shutter

            % query status and break when buffer filled
            status = CsMl_QueryStatus(handle);
            while status ~= 0
                status = CsMl_QueryStatus(handle);
            end
            
            % data transfer
            [ret, data_ex, actual] = CsMl_Transfer(handle, transfer);
            CsMl_ErrorHandler(ret, 1, handle);
            
            pause(1.0);
            
        end
    end
    corrected = data_ex - data_bg;
    reads_S = [reads_S, corrected];
    pause(timeDecay);
end

y = mean(cat(groupsShots, reads_S{:}), groupsShots);
length = size(y, 2);
xpos = actual.ActualStart;
xpos_end = length + xpos - 1;
points = (xpos:xpos_end)';
x = between * transpose(points);
pause(2.5);



