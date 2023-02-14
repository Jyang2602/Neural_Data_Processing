%%% viewData - v2.1
% 28 Mar - Improved sorting, files are now sorted by string and numerically
% 06 Apr - got to handle recorded files with aquire_w_trigger_v2 (show time
% axis in ms, but without pretrigger

function varargout = viewData(varargin)
% VIEWDATA M-file for viewData.fig
%      VIEWDATA, by itself, creates a new VIEWDATA or raises the existing
%      singleton*.
%
%      H = VIEWDATA returns the handle to a new VIEWDATA or the handle to
%      the existing singleton*.
%
%      VIEWDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWDATA.M with the given input arguments.
%
%      VIEWDATA('Property','Value',...) creates a new VIEWDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewData_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help viewData

% Last Modified by GUIDE v2.5 21-May-2007 16:34:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @viewData_OpeningFcn, ...
    'gui_OutputFcn',  @viewData_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before viewData is made visible.
function viewData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewData (see VARARGIN)
% Choose default command line output for viewData
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% This sets up the initial plot - only do when we are invisible
% so window can get raised using viewData.
% if strcmp(get(hObject,'Visible'),'off')

%handles.working_directory = 'data/Fev_10/';
%start_file = 'Fev_10.A.1.1.mat';
%handles.file_index = 10;

% directory = handles.working_directory;
% %%% CHECK THIS!!
% if (exist([directory start_file]) ~= 2)
%     fprintf('\n### Can''t read initial file!!\n### Program Halted!\n### Go back and change the filename!\n\n');
%     return;
% % end
%
% dir_list = dir(directory);
% file_names = {dir_list.name}'; % REGEXP!! Gets the filenames. Note the ' to invert matrix!
% file_names = sort(file_names); % This does pure string sorting which is bad because then 10 comes after 1...
% handles.file_names = file_names;
% guidata(hObject, handles);
%input_filename = varargin{:}; % gets the input filename (because vargargin is a special var, see hep!)
%input_filename = [directory start_file];

handles.working_directory = pwd;
%handles.working_directory = pwd;
%handles.working_directory = 'F:\Backup_lab\Tiago\data_Aq';

handles.thr = str2num(get(handles.SD_BOX, 'String'));
guidata(hObject, handles);
cla;

handles.last_plot_h = plot(1);
hold on; 

set(handles.figure1, 'MenuBar', 'Figure', 'Toolbar', 'Figure');


handles = load_listbox(hObject, handles);
guidata(hObject, handles);




% UIWAIT makes viewData wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = viewData_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in UP.
function UP_Callback(hObject, eventdata, handles)
% hObject    handle to UP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.index_selected = handles.index_selected - 1;
guidata(hObject, handles);
plot_graph(hObject, handles);
set(handles.DIRLIST, 'Value', handles.index_selected);

% --- Executes on button press in down.
function DOWN_Callback(hObject, eventdata, handles)
% hObject    handle to down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.index_selected = handles.index_selected + 1;
guidata(hObject, handles);
plot_graph(hObject, handles);
set(handles.DIRLIST, 'Value', handles.index_selected);

function plot_graph(hObject, handles)
% hObject    handle to down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = [handles.working_directory '/' handles.file_names{handles.index_selected}];  % NOTE THE CURLY BRACKETS! IT's a cell array!


if handles.index_selected <= 1
    set(handles.UP, 'Enable', 'off');
elseif handles.index_selected >= size(handles.file_names,1)
    set(handles.DOWN, 'Enable', 'off');
else
    set(handles.DOWN, 'Enable', 'on');
    set(handles.UP, 'Enable', 'on');
end





if exist(filename) ~= 2 % If filename is not a .MAT file
    set(handles.TITLE, 'String', ['"' filename '"' ' --> IS NOT A .MAT FILE!']);
    cla
    beep
else
    load(filename);
	

    % Transforms some of the parameters, depending on the script that recorded the data files!
    if isfield(p, 'AI_SR'); param.sr = p.AI_SR; end
    if isfield(p, 'AI_totalT'); param.sample_t = p.AI_totalT; end
    % If data file contains info about the channel offset then uses this info INSTEAD of the one set
    if isfield(p, 'channel_offset_start');
		handles.ch_offset_start_val = 10;
		%handles.ch_offset_start_val = param.channel_offset_start;
		set(handles.ch_offset_start, 'String',handles.ch_offset_start_val);
	end; %set(handles.WARNING, 'STRING', 'File contains ch_offset_start info! Ignoring text box.');



        
    data = data(:,1:handles.plot_res_val:end); % Reduces size of data
    
	
	num_channels = size(data,1);
    shift_num = ceil((num_channels-handles.ch_offset_start_val+1)/2);
    for i = handles.ch_offset_start_val:num_channels
        std_data = mean(data(i,:)) - handles.thr * std(data(i,:));  % SD Line
        sd(1:2,i) = [std_data std_data];                            % SD Line
        %if handles.intra_checkbox == 1 && i == 1; continue; end;
        data(i,:) = data(i,:) + shift_num - (i - handles.ch_offset_start_val + 1);                   % Shift data lines
        sd(:,i) = sd(:,i) + shift_num - (i - handles.ch_offset_start_val + 1);                       % SD Line
    end
    
    % Picks the color to plot
    if get(handles.LineColorBlue, 'Value') == 1; plot_color = 'b';
    elseif get(handles.LineColorRed, 'Value') == 1; plot_color = 'r';
    elseif get(handles.LineColorOrange, 'Value') == 1; plot_color = [1 0.66 0];
    elseif get(handles.LineColorGreen, 'Value') == 1; plot_color = [0 0.5 0];        
    else; plot_color = 'b'; end;
    
% Deletes the previous object if the hold plots checkbox is NOT marked
if get(handles.hold_plots,'Value') ~= 1
    delete(handles.last_plot_h);
end
    
    % Tries to get the sampling rate and re-scale the X axis
    if exist('param', 'var') ==  1
        if isfield(param, 'pretrig_t')
            handles.last_plot_h = plot(1000*[param.pretrig_t+1/param.sr:(1/param.sr)*handles.plot_res_val:param.sample_t],data', 'Color',plot_color);
            xlabel('Time (ms)'); set(gca, 'XLim',1000*[param.pretrig_t param.sample_t-1/param.sr]);
		else
			dt = 1/param.sr;
			xaxis = 1000*(dt:dt*handles.plot_res_val:param.sample_t);
            handles.last_plot_h = plot(xaxis, data', 'Color',plot_color);
            xlabel('Time (ms)'); set(gca, 'XLim',1000*[0 param.sample_t-1/param.sr]);
        end
    else
        handles.last_plot_h = plot(data', 'Color',plot_color);
    end
    
    % Standard Deviation line
    if handles.thr ~= 0
        line(get(handles.PLOT, 'Xlim'), sd, 'color', [0.5 0.5 0.5], 'LineStyle', ':') % Horizontal line for threshold
    end
    
    % Tries to put trigger info (provided info is available). 'trigger_time' was loaded together with the file
    if isfield(param, 'trig_chan')
        trigger_info_label = ['Trigger Channel: ' num2str(param.trig_chan) ' | Trigger Time: ' num2str(trigger_time) '.'];
        set(handles.TRIGGER_INFO, 'String', trigger_info_label);
    
    yval = -(-shift_num + param.trig_chan) + param.trig_threshold; yval = [yval yval];
    line(get(handles.PLOT, 'Xlim'), yval, 'color', [1 0.5 0.5], 'LineStyle', ':') % Horizontal line for trigger line
    clear('trig_channel', 'trigger_info_label');
    else
        set(handles.TRIGGER_INFO, 'String', 'Trigger Time: N/A');
    end
    
    % Yscaling
    % If hold_zoom check_box is ON then sets axis lims to previous values (that were stored)
    if get(handles.hold_zoom, 'Value') == 1
        set(handles.PLOT, 'XLim',[handles.zoom_XY_val(1:2)], 'YLim',[handles.zoom_XY_val(3:4)])
    else
        if handles.intra_checkbox == 0
            set(handles.PLOT, 'ylim', [-(shift_num+2), shift_num+1]);
        elseif handles.intra_checkbox == 1 | handles.acute_hippocampus_checkbox == 1
            set(handles.PLOT, 'ylim', [handles.plot_Ymin_val, handles.plot_Ymax_val]);
        end
    end

    % Plot Title
    set(handles.TITLE, 'String', filename);  
    
    guidata(hObject, handles);
    
end


% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function handles = load_listbox(hObject, handles)
dir_struct = dir(handles.working_directory);
[not_used,sorted_index] = sortrows({dir_struct.name}');


% --- SORTING CODE ---
filenames = {dir_struct.name}';         % Gets the filenames, in a CELL ARRAY column of strings!
for i = 1:size(filenames,1)
    idx = strfind(filenames{i}, '.');   % For each string finds the indexes of the COLONs
    % If string has more than to colons and string is bigger than '..mat'
    if length(idx) >= 2 && length(filenames{i}) > 5                         
        final_struct{i,1} = filenames{i};                                   % Writes as STRING the full filename, eg: Fev_10.A.1.mat
        final_struct{i,2} = filenames{i}(1:idx(end-1));                     % Writes as STRING the common part of filename, eg: Fev_10.A.1.
        final_struct{i,3} = str2num(filenames{i}(idx(end-1)+1:idx(end)-1));     % Writes as a NUMBER the experiment TRIAL number, eg: 5
    else
        final_struct{i,1} = filenames{i};
        final_struct{i,2} = filenames{i};
        final_struct{i,3} = 0;
    end
end
% Now we have a 3 COLUMNS CELL ARRAY 'final_struct'. 1st column = Fev_10.A.5.mat; 2nd column = Fev_10.A.5.; 3rd column = 5
temp_matrix = [];
for i = 1:size(filenames,1)-1 % Starts in 2nd element, because is going to compare present element with the previous
    if strcmp(final_struct{i,2}, final_struct{i+1,2}) % If, in the 2nd column of final_struct, the present element is equal to the previous
        temp_matrix = cat(1,temp_matrix, [final_struct{i,3}, i]);
        % temp_matrix is a matrix in which the first column is the file
        % index number and the 2nd column the array index number
    else
        if ~isempty(temp_matrix)
            temp_matrix = cat(1,temp_matrix, [final_struct{i,3}, i]);
            temp_matrix = sortrows(temp_matrix);
            filenames(min(temp_matrix(:,2)):max(temp_matrix(:,2))) = final_struct(temp_matrix(:,2),1);
            temp_matrix = [];
        end
    end
end
% Has to run once more to include the last file in the directory
if ~isempty(temp_matrix)
    temp_matrix = cat(1,temp_matrix, [final_struct{end,3}, size(filenames,1)]); % Added line on 04/19/06
    temp_matrix = sortrows(temp_matrix);
    filenames(min(temp_matrix(:,2)):max(temp_matrix(:,2))) = final_struct(temp_matrix(:,2),1);
end


% --- END SORTING CODE ---

% filenames(end + 1) = {'F:\'};
% dir_struct.isdir(end + 1) = 1;
% sorted_index(end + 1) = max(sorted_index) + 1;

handles.file_names = filenames;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;

% 'handles sorted:'
% handles.sorted_index
% hObject
% guidata(hObject, handles)
% 
% 
% 'stored guidata;'
% guidata(hObject)

set(handles.DIRLIST,'String',handles.file_names,...
    'Value',1)
set(handles.DIRTEXT,'String',handles.working_directory)

% --- Executes on selection change in DIRLIST.
function DIRLIST_Callback(hObject, eventdata, handles)
% hObject    handle to DIRLIST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DIRLIST contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DIRLIST



if strcmp(get(handles.figure1,'SelectionType'),'open') % If there is a double click...
    index_selected = get(handles.DIRLIST,'Value');
    file_list = get(handles.DIRLIST,'String');
    filename = file_list{index_selected};
	
    if  handles.is_dir(handles.sorted_index(index_selected)) % If click is a directory...
        if strcmp(filename, '..') %go up one level in working directory
            % Improve this, put in a single line
            split_index = regexp(handles.working_directory, '/');
            size_si = size(split_index); last_val = split_index(size_si(2));
            handles.working_directory = handles.working_directory(1:last_val-1);
            guidata(hObject, handles);
            handles = load_listbox(hObject, handles);
        elseif strcmp(filename, '.') % Just refreshes dir list
            handles = load_listbox(hObject, handles);
        else
            handles.working_directory = [handles.working_directory '/' filename];
            guidata(hObject, handles);
            handles = load_listbox(hObject, handles)
        end
    else
        %[path,name,ext,ver] = fileparts(filename); %DVB
        [path,name,ext] = fileparts(filename);
        switch ext
            case '.mat'
                handles.index_selected = index_selected;
                guidata(hObject, handles);
                plot_graph(hObject, handles);                
            otherwise
                fprintf('Not a .MAT file!!\n');
        end
    end
end


function SD_BOX_Callback(hObject, eventdata, handles)
% hObject    handle to SD_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SD_BOX as text
%        str2double(get(hObject,'String')) returns contents of SD_BOX as a double
handles.thr = str2double(get(hObject,'String'));
guidata(hObject, handles);
plot_graph(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SD_BOX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SD_BOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function DIRLIST_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DIRLIST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in intra_checkbox.
function intra_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to intra_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of intra_checkbox
handles.intra_checkbox = get(hObject,'Value');
if handles.intra_checkbox == 1
    handles.working_directory = 'C:\Tiago\Data_Aq\data_extra_intra';
    %handles.working_directory = 'F:\Backup_lab\Tiago\data_Aq\data_intracell';
else
    handles.working_directory = 'C:\Tiago\Data_Aq\data';
    %handles.working_directory = 'F:\Backup_lab\Tiago\data_Aq';
end
guidata(hObject, handles);
handles = load_listbox(hObject, handles);


% --- Executes on button press in acute_hippocampus_checkbox.
function acute_hippocampus_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to acute_hippocampus_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of intra_checkbox
handles.acute_hippocampus_checkbox = get(hObject,'Value');
if handles.acute_hippocampus_checkbox == 1; handles.working_directory = 'C:\Tiago\Data_Aq\data_acute_hippocampus';
else;                                       handles.working_directory = 'C:\Tiago\Data_Aq\data'; end;
guidata(hObject, handles);
handles = load_listbox(hObject, handles);



% --- Executes on button press in cell_attached_checkbox.
function cell_attached_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to cell_attached_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cell_attached_checkbox
handles.cell_attached_checkbox = get(hObject,'Value');
if handles.cell_attached_checkbox == 1; handles.working_directory = 'C:\Tiago\Data_Aq\data_cell_attached';
else;                                       handles.working_directory = 'C:\Tiago\Data_Aq\data'; end;
guidata(hObject, handles);
handles = load_listbox(hObject, handles);


% --- Executes during object creation, after setting all properties.
function plot_Ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.plot_Ymax_val = str2double(get(hObject,'String'));
guidata(hObject, handles);

function plot_Ymax_Callback(hObject, eventdata, handles)
% hObject    handle to plot_Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plot_Ymax as text
%        str2double(get(hObject,'String')) returns contents of plot_Ymax as
%        a double
handles.plot_Ymax_val = str2double(get(hObject,'String'));
my_set_axis_1lim(handles.PLOT, 'Ylim', 'max', handles.plot_Ymax_val)
guidata(hObject, handles);
%plot_graph(hObject, handles);

% --- Executes during object creation, after setting all properties.
function plot_Ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_Ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.plot_Ymin_val = str2double(get(hObject,'String'));
guidata(hObject, handles);

function plot_Ymin_Callback(hObject, eventdata, handles)
% hObject    handle to plot_Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of plot_Ymax as text
%        str2double(get(hObject,'String')) returns contents of plot_Ymax as
%        a double
handles.plot_Ymin_val = str2double(get(hObject,'String'));
my_set_axis_1lim(handles.PLOT, 'Ylim', 'min', handles.plot_Ymin_val)
guidata(hObject, handles);
%plot_graph(hObject, handles);



% --- Executes during object creation, after setting all properties.
function plot_res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.plot_res_val = str2double(get(hObject,'String'));
guidata(hObject, handles);

function plot_res_Callback(hObject, eventdata, handles)
% hObject    handle to plot_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of plot_res as text
%        str2double(get(hObject,'String')) returns contents of plot_res as a double
handles.plot_res_val = str2double(get(hObject,'String'));
guidata(hObject, handles);
plot_graph(hObject, handles);




function ch_offset_start_Callback(hObject, eventdata, handles)
% hObject    handle to ch_offset_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ch_offset_start as text
%        str2double(get(hObject,'String')) returns contents of ch_offset_start as a double
handles.ch_offset_start_val = str2double(get(hObject,'String'));
guidata(hObject, handles);
plot_graph(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ch_offset_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch_offset_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.ch_offset_start_val = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes on button press in hold_plots.
function hold_plots_Callback(hObject, eventdata, handles)
% hObject    handle to hold_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of hold_plots
%if get(hObject,'Value') == 1; hold on; else; hold off; end;


% --- Executes on button press in hold_zoom.
function hold_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to hold_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of hold_zoom
handles.zoom_XY_val = [get(gca,'XLim') get(gca,'YLim')];
guidata(hObject, handles);


% --- Executes on button press in erase_plot.
function erase_plot_Callback(hObject, eventdata, handles)
% hObject    handle to erase_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla;
handles.last_plot_h = plot(1);
guidata(hObject, handles);





