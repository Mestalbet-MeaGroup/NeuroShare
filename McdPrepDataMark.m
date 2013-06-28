function varargout = McdPrepDataMark(varargin)
%insert into THIS file all hand-written functions.
% Last Modified by GUIDE v2.5 20-Oct-2008 20:09:08
% Jan 14, 2003 - nadav - updated version

if nargin == 0  % LAUNCH GUI
    fig = openfig(mfilename,'reuse');
    
    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    guidata(fig, handles);
    DataStr.num_folder=0;
    DataStr.classes=[];
    %    DataStr.num_files=0;
    set(handles.McdPrepData,'userData',DataStr);
    if nargout > 0
        varargout{1} = fig;
    end
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end
end



% --------------------------------------------------------------------
%read folders
function varargout = folder_names_Callback(h, eventdata, handles, varargin)
DataStr=get(handles.McdPrepData,'userData');
DataStr.folder=(get(handles.folder_names,'string'));
set(handles.List_folders,'visible','on');
set(handles.McdPrepData,'userData',DataStr);
List_folders_Callback(h, eventdata, handles, varargin);


% --------------------------------------------------------------------
function varargout = List_folders_Callback(h, eventdata, handles, varargin)
DataStr=get(handles.McdPrepData,'userData');
DataStr.num_folder=DataStr.num_folder+1;
DataStr.folders{DataStr.num_folder}=DataStr.folder;
set(handles.List_folders,'string',DataStr.folders);
set(handles.McdPrepData,'userData',DataStr);


% --------------------------------------------------------------------
%prepare data:
function varargout = prep_data_Callback(h, eventdata, handles, varargin)
time1=datenum(clock);
DataStr=get(handles.McdPrepData,'userData');
path=cd;
DataStr.channels=[1:60];
folders_file=[path 'folders.txt'];

%Get Parameters:
Params.MaxVoltageThresh=str2num(get(handles.MaxVoltageThresh,'string'));
Params.SpikeDetectionThresh=str2num(get(handles.SpikeDetectionThresh,'string'));
Params.RemoveSubThreshSpikes=get(handles.RemoveSubThreshSpikes_checkbox,'value');
Params.MCSElectrodeLayout=get(handles.MCSElectrodeLayout_checkbox,'value');

%warnning if files already exist: press "yes" to continue and overwrite.
for j=1:length(DataStr.folders)
    [pathstr,name,ext] = fileparts(DataStr.folders{j});
    if ~isempty(dir([pathstr,'\*i.dat'])),
        if(questdlg(['data files ''*i.dat'' exist in directory: ', pathstr, '!!! Do you want to continue?'])~='yes'),
            error('data files ''*i.dat'' exist !!! cannot perform prepare data!!!');
        end
    end
end
% the folder txt file 
fid=fopen(folders_file,'wb');
for j=1:length(DataStr.folders)
    [pathstr,name,ext] = fileparts(DataStr.folders{j});
    fprintf(fid,'%s',[pathstr '\']);
    fprintf(fid,'%s\n','');    
end
fclose(fid);
%prepare data file by file:
fprintf('\n************************\nstarting prepare data...\n\n');
files_number=length(DataStr.folders);
% if files_number>1,
%     h=waitbar(0,'opening files...');
% end
for j=1:files_number
    fprintf('file no. %d out of %d: %s\n',j,files_number,DataStr.folders{j});
    fprintf('opening....');
%     if files_number>1,
%         waitbar(j/files_number,h);
%     end
    ReadMcdAndPrepDataNoah3(DataStr.folders{j},Params);
end
% if files_number>1,
%     close(h);
% end
fprintf('Finished prepare data !\n');
%set(handles.channels_number,'string',num2str(DataStr.channels));
time2=datenum(clock);
[Year,Month,Days,Hours,Minutes,Seconds] = datevec(time2-time1);
fprintf(['total time: ' num2str(Days*24+Hours) ' hours, ' num2str(Minutes) ' minutes, ' num2str(Seconds) ' seconds.\n']);
sound(sin(1:1000)/4);
set(handles.McdPrepData,'userData',DataStr);


% --------------------------------------------------------------------
function varargout = sort_file_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = load_folders_Callback(h, eventdata, handles, varargin)
DataStr=get(handles.McdPrepData,'userData');
[fname,pname] = uigetfile('*.mcd','Select the file you want to sort');
DataStr.folders{DataStr.num_folder+1}=[pname,fname];
DataStr.num_folder=length(DataStr.folders);
set(handles.List_folders,'visible','on');
set(handles.List_folders,'string',DataStr.folders)
set(handles.McdPrepData,'userData',DataStr);



function SpikeDetectionThresh_Callback(hObject, eventdata, handles)
% hObject    handle to SpikeDetectionThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpikeDetectionThresh as text
%        str2double(get(hObject,'String')) returns contents of SpikeDetectionThresh as a double


% --- Executes during object creation, after setting all properties.
function SpikeDetectionThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpikeDetectionThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxVoltageThresh_Callback(hObject, eventdata, handles)
% hObject    handle to MaxVoltageThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxVoltageThresh as text
%        str2double(get(hObject,'String')) returns contents of MaxVoltageThresh as a double


% --- Executes during object creation, after setting all properties.
function MaxVoltageThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxVoltageThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RemoveSubThreshSpikes_checkbox.
function RemoveSubThreshSpikes_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveSubThreshSpikes_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RemoveSubThreshSpikes_checkbox


% --- Executes on button press in MCSElectrodeLayout_checkbox.
function MCSElectrodeLayout_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to MCSElectrodeLayout_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MCSElectrodeLayout_checkbox


