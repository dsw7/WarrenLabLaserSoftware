%{
This program has been written for operation of the Warren lab Fluorescence
and Transient Absorption (TA) spectrometer and has been developed by
David S. Weber in collaboration with Dr. Jeffrey J. Warren.

Relevent contact information as follows:
dsw7@sfu.ca
j.warren@sfu.ca
Department of Chemistry, Simon Fraser University, Burnaby, BC, Canada
%}


function varargout = LaserTableProgram(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LaserTableProgram_OpeningFcn, ...
                   'gui_OutputFcn',  @LaserTableProgram_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% this function sets up the program before the GUI is made visible to user
function LaserTableProgram_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

CURR_VERSION = '3.9.0';
global INST_NI_DIGITAL;
global INST_NI_ANALOG;
global ARRAY_CHAN;
global DK240;
global QC9514;
global CHANNELS;
global STATE;
global SYNC;

CHANNELS = containers.Map;
CHANNELS('A') = ':PULSE1';
CHANNELS('B') = ':PULSE2';
CHANNELS('C') = ':PULSE3';
CHANNELS('D') = ':PULSE4';

STATE = containers.Map;
STATE('ON') = ':STATE ON <cr><lf>';
STATE('OFF') = ':STATE OFF <cr><lf>';

SYNC = containers.Map;
SYNC('2') = 'T0';
SYNC('3') = 'CHA';
SYNC('4') = 'CHB';
SYNC('5') = 'CHC';
SYNC('6') = 'CHD';

% label handles figure
set(handles.figure1, 'Name', strcat('WarrenLabLaser_', CURR_VERSION));

% generate a default plot
plot(0.05 * rand(250, 1));
ylim([-0.5, 1]);
grid minor;
grid on;
set(gca, 'color', [1 1 0]);
xlabel('Time (s)', 'FontSize', 10);
ylabel('Voltage (V)', 'FontSize', 10);

% destroy handles to all instruments prior to connecting new instruments
delete(instrfindall);

% initialize all NI global objects
% create two instances - one for digital channels and one for analog channels
ARRAY_CHAN = [0 0 0]; % channel array will be updated in place
INST_NI_DIGITAL = daq.createSession('ni');
INST_NI_ANALOG = daq.createSession('ni');
addDigitalChannel(INST_NI_DIGITAL, 'Dev1', 'port0/Line0:2', 'OutputOnly');
addAnalogOutputChannel(INST_NI_ANALOG, 'Dev1', 'ao0', 'Voltage');
outputSingleScan(INST_NI_DIGITAL, ARRAY_CHAN); % close all shutters
outputSingleScan(INST_NI_ANALOG, 0.0); % default PMT power to 0

% open monochromator serial communication
DK240 = serial('COM3');

% see page 34, bottom, DK240 user manual for these specifications
DK240.Baudrate = 9600;
DK240.Stopbits = 1;
DK240.Parity = 'none';
DK240.Databits = 8;
fopen(DK240);

% echo the monochromator to ensure device is turned on/connected
fwrite(DK240, 27);
pause(0.2);
try
    fread(DK240, DK240.BytesAvailable);
catch
    message = 'Check DK240 power and/or connection then restart program.';
    uiwait(msgbox(message, 'Error'));
    closereq;
end

% get the wavelength setting upon starting
fwrite(DK240, 29); % tells the monochromator to send us wavelength byte vector
pause(0.2); % wait for the vector to arrive
bytesIncoming = fread(DK240, DK240.BytesAvailable);
pause(0.2);

% note that here we ignore echo <29>, <Status Byte> and <24> - no need
% take dot product of return vector and byte converter
wavelength = dot(bytesIncoming(2:4, 1), [65536 256 1]);
wavelength_current = wavelength / 100; % data is returned in hundredths of nm
set(handles.actual_wavelength_edit, 'String', wavelength_current);

% get the slit width settings upon starting
fwrite(DK240, 30);
pause(0.2);
bytesIncoming = fread(DK240, DK240.BytesAvailable);
slit_width_entr = dot(bytesIncoming(2:3, 1), [256 1]);
slit_width_exit = dot(bytesIncoming(4:5, 1), [256 1]);
set(handles.edit_entrance_slit, 'String', slit_width_entr);
set(handles.edit_exit_slit, 'String', slit_width_exit);
pause(0.2);
% note that here we ignore <30> and <24> return bytes - no need for them

% create QC9514 object
% see page 35, QC9500+ user manual
QC9514 = serial('COM4');
QC9514.Baudrate = 9600;
QC9514.Stopbits = 1;
QC9514.Parity = 'none';
QC9514.Databits = 8;
fopen(QC9514);

% outputs from this function are returned to the command line
function varargout = LaserTableProgram_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;

% SELECT EXPERIMENT TYPE ==================================================
function mode_Callback(hObject, ~, handles)
global EXPERIMENT_MODE;
global QC9514;
global CHANNELS;
global STATE;
global SYNC;

width_A = num2str(0.001);
delay_A = num2str(0.0006);
width_B = num2str(0.000001);
delay_B = num2str(0.1);

% return if QC9514 connection is fucked up
fprintf(QC9514, ':SYSTem:SERNumber? <cr><lf>');
pause(0.05);
if isempty(fscanf(QC9514)) == 1
    msgbox('Check QC9514 power or connection.', 'Error');
    return;
end

EXPERIMENT_MODE = get(hObject, 'Value');

if EXPERIMENT_MODE == 2
    fprintf(QC9514, strcat(CHANNELS('A'), STATE('OFF')));
    fprintf(QC9514, strcat(CHANNELS('B'), STATE('ON')));
    fprintf(QC9514, [CHANNELS('B'), ':WIDT ', width_B, ' <cr><lf>']);
    fprintf(QC9514, [CHANNELS('B'), ':DELAY ', delay_B, ' <cr><lf>']);
    fprintf(QC9514, [CHANNELS('B'), ':SYNC ', SYNC('2'), ' <cr><lf>']);    
    set(handles.channel_A_checkbox, 'Value', 0);
    set(handles.channel_B_checkbox, 'Value', 1);
    set(handles.width_box_B, 'String', width_B);
    set(handles.delay_box_B, 'String', delay_B);
    set(handles.sync_source_B, 'String', 'To');
else
    fprintf(QC9514, strcat(CHANNELS('A'), STATE('ON')));
    fprintf(QC9514, strcat(CHANNELS('B'), STATE('ON')));
    fprintf(QC9514, [CHANNELS('A'), ':WIDT ', width_A, ' <cr><lf>']);
    fprintf(QC9514, [CHANNELS('A'), ':DELAY ', delay_A, ' <cr><lf>']);
    fprintf(QC9514, [CHANNELS('A'), ':SYNC ', SYNC('4'), ' <cr><lf>']); 
    fprintf(QC9514, [CHANNELS('B'), ':WIDT ', width_B, ' <cr><lf>']);
    fprintf(QC9514, [CHANNELS('B'), ':DELAY ', delay_B, ' <cr><lf>']);
    fprintf(QC9514, [CHANNELS('B'), ':SYNC ', SYNC('2'), ' <cr><lf>']);    
    set(handles.channel_A_checkbox, 'Value', 1);
    set(handles.channel_B_checkbox, 'Value', 1);
    set(handles.width_box, 'String', width_A);
    set(handles.delay_box, 'String', delay_A);
    set(handles.width_box_B, 'String', width_B);
    set(handles.delay_box_B, 'String', delay_B);
    set(handles.sync_source, 'String', 'ChB');
    set(handles.sync_source_B, 'String', 'To');
end

% executes after setting all experiment type properties
function mode_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
    get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end


% SHUTTERS ================================================================

function panel_shutterA_SelectionChangedFcn(hObject, ~, ~)
% toggle first shutter open / closed
global INST_NI_DIGITAL;
global ARRAY_CHAN;
status = get(hObject, 'String');

if strcmp(status(1:4), 'Open')
    ARRAY_CHAN(1) = true;
    outputSingleScan(INST_NI_DIGITAL, ARRAY_CHAN);
else
    ARRAY_CHAN(1) = false;
    outputSingleScan(INST_NI_DIGITAL, ARRAY_CHAN);
end


function panel_shutterB_SelectionChangedFcn(hObject, ~, ~)
% toggle second shutter open / closed
global INST_NI_DIGITAL;
global ARRAY_CHAN;
status = get(hObject, 'String');

if strcmp(status(1:4), 'Open')
    ARRAY_CHAN(2) = true;
    outputSingleScan(INST_NI_DIGITAL, ARRAY_CHAN);
else
    ARRAY_CHAN(2) = false;
    outputSingleScan(INST_NI_DIGITAL, ARRAY_CHAN);
end


function panel_shutterC_SelectionChangedFcn(hObject, ~, ~)
% toggle third shutter open / closed
global INST_NI_DIGITAL;
global ARRAY_CHAN;
status = get(hObject, 'String');

if strcmp(status(1:4), 'Open')
    ARRAY_CHAN(3) = true;
    outputSingleScan(INST_NI_DIGITAL, ARRAY_CHAN);
else
    ARRAY_CHAN(3) = false;
    outputSingleScan(INST_NI_DIGITAL, ARRAY_CHAN);
end


function CLOSE_ALL_Callback(~, ~, ~)
% close all shutters
global INST_NI_DIGITAL;
global ARRAY_CHAN;
ARRAY_CHAN = [0 0 0];
outputSingleScan(INST_NI_DIGITAL, ARRAY_CHAN);


function OPEN_ALL_Callback(~, ~, ~)
% open all shutters
global INST_NI_DIGITAL;
global ARRAY_CHAN;
ARRAY_CHAN = [1 1 1];
outputSingleScan(INST_NI_DIGITAL, ARRAY_CHAN);


% SIGNAL AVERAGE ==========================================================

% get the number of shots (laser pulses) from user
function signal_average_Callback(hObject, ~, ~)
nShots = str2double(get(hObject, 'String'));
if nShots < 1
    msgbox('A minimum of 1 shot is required.', 'Error')
    set(hObject, 'String', 1);
else
    set(hObject, 'String', nShots);
end


% creates function after setting properties
function signal_average_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end


% S NUMBER ================================================================

% get the number of shot groups from user
function s_number_Callback(hObject, ~, ~)
nGroups = str2double(get(hObject, 'String'));
if nGroups < 3
    msgbox('S must be set to a minimum value of 3!', 'Error');
    set(hObject,'String', 3);
else
    set(hObject,'String', nGroups);
end


% creates function after setting properties
function s_number_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end


% DECAY TIME ==============================================================

% get the lag time between shots from user
function decay_time_Callback(hObject, ~, ~)
decay_time = str2double(get(hObject, 'String'));
set(hObject, 'String', decay_time);


% creates function after setting properties
function decay_time_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end


% TIMEBASE OPTIONS ========================================================

% get the timebase from the drop down menu
function timebase_Callback(hObject, ~, handles)
global SCOPE_HANDLE;
global SCOPE_TIMEBASE;
global SCOPE_BETWEEN;
global ACQINFO;

SCOPE_TIMEBASE = get(hObject, 'Value');

if SCOPE_TIMEBASE > 7
    set(handles.signal_average, 'String', 1, 'enable', 'off'); 
elseif SCOPE_TIMEBASE <= 7
    set(handles.signal_average, 'String', 25, 'enable', 'on'); 
end

set(hObject, 'Value', SCOPE_TIMEBASE);
[SCOPE_HANDLE, SCOPE_BETWEEN, ACQINFO] = css(SCOPE_TIMEBASE);

% creates function after setting properties
function timebase_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% START EXPERIMENT ========================================================
function start_Callback(~, ~, handles)

global SCOPE_HANDLE;
global SCOPE_TIMEBASE;
global INST_NI_DIGITAL;
global ARRAY_CHAN;
global SCOPE_BETWEEN;
global EXPERIMENT_MODE;
global TIME_OUT_X;
global VOLT_OUT_Y;
global QC9514;
global QC9514_STATE_PULSE;
global ACQINFO;
global CHANNELS;
global STATE;

% stop user from starting experiment without toggling the laser pulse
% starting without a pulse would force scope to wait forever for trigger
if QC9514_STATE_PULSE == 0
    msgbox('The QC9514 Digital Delay Generator pulse must be enabled!', ...
           'Warning');
    return;
end

% get number of shots, groups of shots and the lag time from user
nShots = str2num(get(handles.signal_average, 'String')); 
nGroups = str2num(get(handles.s_number, 'String')); 
decayTime = str2num(get(handles.decay_time, 'String'));

% transfer attribute needs to be updated locally
transfer.Mode = CsMl_Translate('Default', 'TxMode');
transfer.Channel = 1;
transfer.Segment = 1;
transfer.Start = -ACQINFO.TriggerHoldoff;
transfer.Length = ACQINFO.SegmentSize;


% ***********************************
% patched in a long timescale routine
% redirect to the long timescale routine if timebase > 1 ms
if SCOPE_TIMEBASE > 7
    % re-enable channel A if user selected TA experiment
    if EXPERIMENT_MODE == 3
        set(handles.channel_A_checkbox, 'Value', 1);
        fprintf(QC9514, strcat(CHANNELS('A'), STATE('ON')));
    end 
    
    [TIME_OUT_X, VOLT_OUT_Y] = l_ts(SCOPE_TIMEBASE, EXPERIMENT_MODE, ...
                                    nGroups, decayTime, INST_NI_DIGITAL, ...
                                    SCOPE_HANDLE, transfer, SCOPE_BETWEEN);                                
    % shut off pulse after experiment is over
    if EXPERIMENT_MODE == 3
        set(handles.channel_A_checkbox, 'Value', 0);
        fprintf(QC9514, strcat(CHANNELS('A'), STATE('OFF')));
    end                           
    return;
end
% otherwise continue with original routine
% ***********************************


% start by opening shutters to allow triggering and ensure pulser is
% enabled if it was previously disabled at the bottom of the loop
if EXPERIMENT_MODE == 2
    outputSingleScan(INST_NI_DIGITAL, [1 0 0]); % open shutter 1
elseif EXPERIMENT_MODE == 3
    outputSingleScan(INST_NI_DIGITAL, [1 0 1]); % open shutter 1 and 3
    set(handles.channel_A_checkbox, 'Value', 1);
    fprintf(QC9514, strcat(CHANNELS('A'), STATE('ON')));
end

% acquisition loop
reads_nGroups = {};
for s = 1:nGroups
    reads_typeReads = {};
    for typeread = 1:2
        
        % acquisition shutter control
        if typeread == 2 && EXPERIMENT_MODE == 2 % experiment & fluorescence
            outputSingleScan(INST_NI_DIGITAL, [1 1 0])
        elseif typeread == 1 && EXPERIMENT_MODE == 2 % blank & fluorescence
            outputSingleScan(INST_NI_DIGITAL, [1 0 0])
        elseif typeread == 2 && EXPERIMENT_MODE == 3 % experiment & TA
            outputSingleScan(INST_NI_DIGITAL, [1 1 1])
        elseif typeread == 1 && EXPERIMENT_MODE == 3 % blank & TA
            outputSingleScan(INST_NI_DIGITAL, [1 0 1])
        end
        
        reads_nShots = {};
        for n = 1:nShots                       
            % await a trigger event
            retval = CsMl_Capture(SCOPE_HANDLE);
            CsMl_ErrorHandler(retval);     
            
            % abort the run
            % this method is not necessarily the best approach but it works
            drawnow();
            outstr = get(handles.ABORT, 'String');                       
            if strcmp(outstr, 'Aborting...')
                % CsMl_AbortCapture(SCOPE_HANDLE);
                set(handles.ABORT, 'String', 'ABORT');
                outputSingleScan(INST_NI_DIGITAL, [0 0 0]);
                clear reads_nGroups{:}; % flush buffer containing acquisition data
                return
            end
            
            % continuously query status to see if data has arrived
            status = CsMl_QueryStatus(SCOPE_HANDLE);
            while status ~= 0
                status = CsMl_QueryStatus(SCOPE_HANDLE);
            end
            
            % transfer data once buffer is loaded
            [retval, voltage, actual] = CsMl_Transfer(SCOPE_HANDLE, transfer);
            CsMl_ErrorHandler(retval);
            reads_nShots = [reads_nShots, voltage];
        end
        
        % reads_typeReads contains both background and experimental data
        reads_typeReads = [reads_typeReads, mean(cat(nShots, reads_nShots{:}), nShots)];  
    end
    
    % background correct and append
    reads_nGroups = [reads_nGroups, reads_typeReads{2} - reads_typeReads{1}];
    
    % close all shutters and let sample relax
    outputSingleScan(INST_NI_DIGITAL, [0 0 0]);  
    pause(decayTime); 
end

VOLT_OUT_Y = mean(cat(nGroups, reads_nGroups{:}), nGroups);

% prepare data for plotting
size_voltage = size(VOLT_OUT_Y, 2);
t_0 = actual.ActualStart;
t_f = size_voltage + t_0 - 1;
indices = (t_0:t_f)';
TIME_OUT_X = SCOPE_BETWEEN * indices; % scale indices to time between reads
TIME_OUT_X = transpose(TIME_OUT_X);

% fix for TA y-axis offset
% this is also corrected locally inside l_ts.m
VOLT_OUT_Y = VOLT_OUT_Y - mean(VOLT_OUT_Y(:, 1:50));

% plot
plot(TIME_OUT_X, VOLT_OUT_Y);
grid minor;
grid on;
set(gca, 'color', [1 1 0]);
xlabel('Time (s)', 'FontSize', 10);
ylabel('Voltage (V)', 'FontSize', 10);
ylim([ min(VOLT_OUT_Y) - 0.005, max(VOLT_OUT_Y) + 0.005 ]);

% terminate the experiment by closing all shutters,
% yielding a message box, and shutting off arc lamp pulser
ARRAY_CHAN = [0 0 0];
outputSingleScan(INST_NI_DIGITAL, ARRAY_CHAN);
msgbox('The experiment has completed!', 'Success');
if EXPERIMENT_MODE == 3
    set(handles.channel_A_checkbox, 'Value', 0);
    fprintf(QC9514, strcat(CHANNELS('A'), STATE('OFF')));
end


% ABORT RUN ===============================================================

% stop a run once the current nShots number is reached
% this is mainly for aborting a failed experiment that would otherwise take
% a long time to terminate
function ABORT_Callback(hObject, ~, ~)
set(hObject, 'String', 'Aborting...');
msgbox('The run has been aborted!');

% SAVE DATA ===============================================================

% save the data collected during the experiment
function save_data_Callback(~, ~, ~)
global TIME_OUT_X;
global VOLT_OUT_Y;

[file, path] = uiputfile('Untitled.csv');
if file ~= 0
    save_path = strcat(path, file);
    export_local = [TIME_OUT_X; VOLT_OUT_Y];
    export_local = transpose(export_local);
    csvwrite(char(save_path), export_local);   
else
    return
end

% MENU BAR ITEMS ==========================================================

% menu -> file
function file_Callback(~, ~, ~)

% menu -> file -> save
function file_save_Callback(~, ~, ~)
global TIME_OUT_X;
global VOLT_OUT_Y;

[file, path] = uiputfile('Untitled.csv');
if file ~= 0
    save_path = strcat(path, file);
    export_local = [TIME_OUT_X; VOLT_OUT_Y];
    export_local = transpose(export_local);
    csvwrite(char(save_path), export_local);   
else
    return
end

% menu -> file -> quit
function file_quit_Callback(~, ~, ~)
global QC9514;
global DK240;
global INST_NI_DIGITAL;
global INST_NI_ANALOG;
global SCOPE_HANDLE;

choice = questdlg('Are you sure?', 'Quit', 'Yes', 'No', 'Cancel', 'Cancel');
switch choice
    case 'Yes'
        CsMl_FreeSystem(SCOPE_HANDLE);
        % shut off laser pulse before exiting
        fprintf(QC9514, ':PULSE0:STATE OFF <cr><lf>');
        fclose(QC9514);
        fclose(DK240);
        % close shutters and power down PMT before closing connections
        outputSingleScan(INST_NI_DIGITAL, [0 0 0]);
        outputSingleScan(INST_NI_ANALOG, 0.0);
        delete(INST_NI_DIGITAL);
        delete(INST_NI_ANALOG);
        closereq;
    case 'No'
        return
    case 'Cancel'
        return
end


% menu -> instructions
function instructions_Callback(~, ~, ~)

% menu -> instructions -> general instructions
function gen_instruct_Callback(~, ~, ~)
% get instructions from text file (returns array)
gen_inst_file = textread('general_instructions.txt', '%s', ...
                         'delimiter', '\n', 'whitespace', '');

% need to convert from array to cell of character vectors
gen_inst_file = cellstr(gen_inst_file);                    

% and finally pass to dialog box
msgbox(gen_inst_file, 'General Instructions');


% menu -> instructions -> additional features
function additional_features_Callback(~, ~, ~)
% get instructions from text file (returns array)
add_feat_file = textread('additional_features.txt', '%s', ...
                         'delimiter', '\n', 'whitespace', '');

% need to convert from array to cell of character vectors
add_feat_file = cellstr(add_feat_file);  

% and finally pass to dialog box
msgbox(add_feat_file, 'Additional Features');


% MONOCHROMATOR WAVELENGTH ================================================

% here we send a command to DK240 monochromator to change wavelength
function target_wavelength_edit_Callback(hObject, ~, handles)
global DK240;

wavelength_target = str2double(get(hObject, 'String'));
wavelength_current = str2double(get(handles.actual_wavelength_edit, 'String'));

h = msgbox('Setting the wavelength...');

if wavelength_target <= 300 || wavelength_target >= 800
    delete(h);
    uiwait(msgbox('Wavelength must be between 300 and 800 nm', 'Error'));
    return;
end

if wavelength_target == wavelength_current
    delete(h);
    message = ['The wavelength is already ', wavelength_target, ' nm!'];
    uiwait(msgbox(message, 'Error'));
    return;
end

% convert to hundredths of nm
wavelength_target_hundredths = wavelength_target * 100;

% convert wavelength of interest to bytes (i.e. "anti-dot" product)
hibyte = floor(wavelength_target_hundredths / 65536);
intermediate = (wavelength_target_hundredths - (65536 * hibyte)) / 256;
midbyte = floor(intermediate);
remainder = intermediate - floor(intermediate);
lowbyte = remainder * 256;

% tells the monochromator to prepare to receive bytes
fwrite(DK240, 16);
pause(0.2); 
fread(DK240, DK240.BytesAvailable); % read the <16> echo
pause(0.2);

% send the bytes to DK240
fwrite(DK240, [hibyte midbyte lowbyte]);

% here program pauses for a time proportional to the difference
% in current and target wavelengths - this gives device time to adjust
pause_val = 0.05 * abs(wavelength_current - wavelength_target) - 1.0;
if pause_val < 0.2
    % account for linearly determined pauses < 0.2 s
    % i.e target = 650 nm, current = 645 nm
    pause(0.2);
else
    pause(pause_val);
end

set(handles.actual_wavelength_edit, 'String', wavelength_target);
delete(h);

% read in the <Status Byte> and <24> after the DK240 updates wavelength
fread(DK240, DK240.BytesAvailable);
msgbox('The wavelength has been set.','Success');


% creates function after setting properties
function target_wavelength_edit_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
    get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% returns actual wavelength from DK240
function actual_wavelength_edit_Callback(~, ~, ~)


% creates function after setting properties
function actual_wavelength_edit_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end

   
% MONOCHROMATOR SLIT WIDTH ================================================

% set the DK240 exit slit width
function edit_exit_slit_Callback(hObject, ~, ~)
h = msgbox('Setting the exit slit width...');
global DK240;

width_updated = str2double(get(hObject, 'String'));

% tells the monochromator to prepare to receive bytes
fwrite(DK240, 32);
pause(0.2); 
fread(DK240, DK240.BytesAvailable); % read the <31> echo
pause(0.2);

% convert desired width to bytes
lowbyte = rem(width_updated, 256); 
hibyte = floor(width_updated / 256);

% to DK240: <High Byte> and <Low Byte>
fwrite(DK240, [hibyte lowbyte]);
pause(0.5);

% from DK240: <Status byte> and <24> // comes out as one array
fread(DK240, DK240.BytesAvailable);
delete(h);
msgbox('The exit slit width has been set.', 'Success');


% creates function after setting properties
function edit_exit_slit_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end


% set the DK240 entrance slit width
function edit_entrance_slit_Callback(hObject, ~, ~)
h = msgbox('Setting the entrance slit width...');
global DK240;

width_updated = str2double(get(hObject, 'String'));

% tells the monochromator to prepare to receive bytes
fwrite(DK240, 31);
pause(0.2); 
fread(DK240, DK240.BytesAvailable); % read the <31> echo
pause(0.2);

% convert desired width to bytes
lowbyte = rem(width_updated, 256); 
hibyte = floor(width_updated / 256);

% to DK240: <High Byte> and <Low Byte>
fwrite(DK240, [hibyte lowbyte]);
pause(0.5);

% from DK240: <Status byte> and <24> // comes out as one array
fread(DK240, DK240.BytesAvailable);

delete(h);
msgbox('The entrance slit width has been set.', 'Success');


% creates function after setting properties
function edit_entrance_slit_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end


% DIGITAL DELAY GENERATOR =================================================

% ---- channel A ----

% set channel A ON or OFF
function channel_A_checkbox_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
global STATE;

toggle_state = get(hObject, 'Value');
if toggle_state == 1  
    cmd = strcat(CHANNELS('A'), STATE('ON'));
else
    cmd = strcat(CHANNELS('A'), STATE('OFF'));
end
fprintf(QC9514, cmd);
pause(0.01);


% set channel A width
function width_box_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
cmd = [CHANNELS('A'), ':WIDT ', get(hObject, 'String'), ' <cr><lf>'];
fprintf(QC9514, cmd);
pause(0.01);


% creates function after setting properties
function width_box_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
set(hObject, 'String', 'WIDTH');


% set channel A delay
function delay_box_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
cmd = [CHANNELS('A'), ':DELAY ', get(hObject, 'String'), ' <cr><lf>'];
fprintf(QC9514, cmd);
pause(0.01);


% creates function after setting properties
function delay_box_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
set(hObject, 'String', 'DELAY');


% sync channel A to some other channel
function sync_source_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
global SYNC;
ind = get(hObject, 'Value');
if ind == 3
    msgbox('Channel A cannot sync to itself.', 'Error');
    set(hObject, 'Value', 1);
    return;
else
    cmd = [CHANNELS('A'), ':SYNC ', SYNC(num2str(ind)), ' <cr><lf>'];
    fprintf(QC9514, cmd);
    pause(0.01);
end


% creates function after setting properties
function sync_source_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end

% ---- channel B ----

% set channel B ON or OFF
function channel_B_checkbox_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
global STATE;

toggle_state = get(hObject, 'Value');
if toggle_state == 1  
    cmd = strcat(CHANNELS('B'), STATE('ON'));
else
    cmd = strcat(CHANNELS('B'), STATE('OFF'));
end
fprintf(QC9514, cmd);
pause(0.01);


% set channel B width
function width_box_B_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
cmd = [CHANNELS('B'), ':WIDT ', get(hObject, 'String'), ' <cr><lf>'];
fprintf(QC9514, cmd);
pause(0.01);


% creates function after setting properties
function width_box_B_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
          get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
set(hObject, 'String', 'WIDTH');


% set channel B delay
function delay_box_B_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
cmd = [CHANNELS('B'), ':DELAY ', get(hObject, 'String'), ' <cr><lf>'];
fprintf(QC9514, cmd);
pause(0.01);


% creates function after setting properties
function delay_box_B_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
    get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
set(hObject, 'String', 'DELAY');


% sync channel B to some other channel
function sync_source_B_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
global SYNC;
ind = get(hObject, 'Value');
if ind == 4
    msgbox('Channel B cannot sync to itself.', 'Error');
    set(hObject, 'Value', 1);
    return;
else
    cmd = [CHANNELS('B'), ':SYNC ', SYNC(num2str(ind)), ' <cr><lf>'];
    fprintf(QC9514, cmd);
    pause(0.01);
end


% creates function after setting properties
function sync_source_B_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end

% ---- channel C ----

% set channel C ON or OFF
function channel_C_checkbox_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
global STATE;

toggle_state = get(hObject, 'Value');
if toggle_state == 1  
    cmd = strcat(CHANNELS('C'), STATE('ON'));
else
    cmd = strcat(CHANNELS('C'), STATE('OFF'));
end
fprintf(QC9514, cmd);
pause(0.01);


% set channel C width
function width_box_C_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
cmd = [CHANNELS('C'), ':WIDT ', get(hObject, 'String'), ' <cr><lf>'];
fprintf(QC9514, cmd);
pause(0.01);


% creates function after setting properties
function width_box_C_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
set(hObject, 'String', 'WIDTH');


% set channel C delay
function delay_box_C_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
cmd = [CHANNELS('C'), ':DELAY ', get(hObject, 'String'), ' <cr><lf>'];
fprintf(QC9514, cmd);
pause(0.01);


% creates function after setting properties
function delay_box_C_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
set(hObject, 'String', 'DELAY');


% sync channel C to some other channel
function sync_source_C_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
global SYNC;
ind = get(hObject, 'Value');
if ind == 5
    msgbox('Channel C cannot sync to itself.', 'Error');
    set(hObject, 'Value', 1);
    return;
else
    cmd = [CHANNELS('C'), ':SYNC ', SYNC(num2str(ind)), ' <cr><lf>'];
    fprintf(QC9514, cmd);
    pause(0.01);
end


% creates function after setting properties
function sync_source_C_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end

% ---- channel D ----

% set channel D ON or OFF
function channel_D_checkbox_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
global STATE;

toggle_state = get(hObject, 'Value');
if toggle_state == 1  
    cmd = strcat(CHANNELS('D'), STATE('ON'));
else
    cmd = strcat(CHANNELS('D'), STATE('OFF'));
end
fprintf(QC9514, cmd);
pause(0.01);


% set channel D width
function width_box_D_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
cmd = [CHANNELS('D'), ':WIDT ', get(hObject, 'String'), ' <cr><lf>'];
fprintf(QC9514, cmd);
pause(0.01);


% creates function after setting properties
function width_box_D_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', 'WIDTH');


% set channel D delay
function delay_box_D_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
cmd = [CHANNELS('D'), ':DELAY ', get(hObject, 'String'), ' <cr><lf>'];
fprintf(QC9514, cmd);
pause(0.01);


% creates function after setting properties
function delay_box_D_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
set(hObject, 'String', 'DELAY');


% sync channel D to some other channel
function sync_source_D_Callback(hObject, ~, ~)
global QC9514;
global CHANNELS;
global SYNC;
ind = get(hObject, 'Value');
if ind == 6
    msgbox('Channel D cannot sync to itself.', 'Error');
    set(hObject, 'Value', 1);
    return;
else
    cmd = [CHANNELS('D'), ':SYNC ', SYNC(num2str(ind)), ' <cr><lf>'];
    fprintf(QC9514, cmd);
    pause(0.01);
end

% creates function after setting properties
function sync_source_D_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end

% ---- other QC9514 stuff ----

% creates function after setting properties
function pulse_state_checkbox_CreateFcn(hObject, ~, ~)
% Set initial pulse state in case user decides to attempt to try to
% start experiment without setting PULSE ON
set(hObject, 'Value', 0);
global QC9514_STATE_PULSE;
QC9514_STATE_PULSE = get(hObject, 'Value');


% --- Executes on button press in pulse_state_checkbox.
function pulse_state_checkbox_Callback(hObject, ~, handles)
%{
    User should not be able to start the pulse without some arguments being
    passed directly to the DDG. As such, throw an error and return should 
    the fields for channel B be empty. Of course this depends on which
    channel is being used to actually trigger the laser. We use channel B
    in the Warren lab
%}

global QC9514;
global QC9514_STATE_PULSE;

state_width = get(handles.width_box_B, 'String');
state_delay = get(handles.delay_box_B, 'String');

if state_width(1) == 'W' || state_delay(1) == 'D'
    msgbox({'Channel B parameters have not been set.';
            'Set all parameters either by:';
            ' (1) Choosing an experiment type';
            ' (2) Manually inputting parameters';}, 'Error');
    set(hObject, 'Value', 0);
    return;
end

QC9514_STATE_PULSE = get(hObject, 'Value');
if QC9514_STATE_PULSE == 1
    fprintf(QC9514, ':PULSE0:STATE ON <cr><lf>');
else        
    fprintf(QC9514, ':PULSE0:STATE OFF <cr><lf>');
end
pause(0.01);


% PMT VOLTAGE =============================================================

function voltage_PMT_Callback(hObject, ~, handles)
global INST_NI_ANALOG;
% y = 251.8x + 0.8813
CORR_FACTOR = 251.8; % correction factor for NI -> PMT gain
set(hObject, 'min', 0.0);
set(hObject, 'max', 3.5);
volt_PMT = get(hObject, 'Value');
outputSingleScan(INST_NI_ANALOG, volt_PMT); % default PMT power to 0
outval = strcat(num2str(round(CORR_FACTOR * volt_PMT, 1)), ' V');
set(handles.voltage_PMT_display, 'String', outval);

function voltage_PMT_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% display showing the APPROXIMATE voltage of the PMT
function voltage_PMT_display_Callback(~, ~, ~)

function voltage_PMT_display_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
