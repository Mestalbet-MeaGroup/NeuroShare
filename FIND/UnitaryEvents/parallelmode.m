function DataFile = parallelmode(varargin)


if isequal(varargin{1},'init')  % LAUNCH GUI

    fig = openfig(mfilename,'reuse');

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    DataFile = varargin{2};

    handles.data.mode            = DataFile.PVM.ParallelMode;
    handles.data.autodelete      = DataFile.PVM.AutomaticDelete;
    handles.data.njob            = DataFile.PVM.NumberOfJobs;
    handles.data.ncpu            = DataFile.PVM.NumberOfProcessors;
    handles.data.randomize       = DataFile.PVM.RandomizeWindows;
    handles.data.priority        = DataFile.PVM.NicePriority;
    handles.data.allscratchesdir = DataFile.PVM.AllScratchesDir;
    handles.data.allscratches    = DataFile.PVM.AllScratchesList;
    handles.data.partscratches   = DataFile.PVM.PartScratchesList;
    handles.data.usersscratchlnk = DataFile.PVM.UsersScratchLink;


    % in case of cancel, return original parameters
    handles.cancel = 'on';
    handles.originaldata = DataFile;

    guidata(fig, handles);


    % AllScratchesDir
    set(handles.all_scratches_edit,'string',DataFile.PVM.AllScratchesDir);

    % UsersScratchLink
    set(handles.users_scratch_edit,'string',DataFile.PVM.UsersScratchLink);
    
    % set Host Lists
    set(handles.all_hosts_listbox,'string',DataFile.PVM.AllScratchesList);
    set(handles.selected_hosts_listbox,'string',DataFile.PVM.PartScratchesList);


    % AutomaticDelete
    switch DataFile.PVM.AutomaticDelete
        case 'on'
            set(handles.delete_checkbox,'value',1);
        case 'off'
            set(handles.delete_checkbox,'value',0);
    end

    % Balancing
    switch DataFile.PVM.RandomizeWindows
        case 'on'
            set(handles.randomize_checkbox,'value',1);
        case 'off'
            set(handles.randomize_checkbox,'value',0);
    end

    % NumberofJobs
    set(handles.njob_edit,'string',num2str(DataFile.PVM.NumberOfJobs));

    % NumberofProcessors
    set(handles.ncpu_edit,'string',num2str(DataFile.PVM.NumberOfProcessors));

    % Priority Level
    set(handles.priority_edit,'string',num2str(DataFile.PVM.NicePriority));

    % Mode
    switch DataFile.PVM.ParallelMode
        case 'off'
            set(handles.mode_checkbox,'value',0);
            set(handles.all_scratches_edit,'enable','off');
            set(handles.users_scratch_edit,'enable','off');
            set(handles.add_host_pushbutton,'enable','off');
            set(handles.add_all_pushbutton,'enable','off');
            set(handles.remove_host_pushbutton,'enable','off');
            set(handles.all_hosts_listbox,'enable','off');
            set(handles.selected_hosts_listbox,'enable','off');
            set(handles.delete_checkbox,'enable','off');
            set(handles.njob_edit,'enable','off');
            set(handles.ncpu_edit,'enable','off');
            set(handles.priority_edit,'enable','off');
            set(handles.randomize_checkbox,'enable','off');
            set(handles.search_hosts_pushbutton,'enable','off');
        case 'on'
            set(handles.mode_checkbox,'value',1);
            set(handles.all_scratches_edit,'enable','on');
            set(handles.users_scratch_edit,'enable','on');
            set(handles.all_hosts_listbox,'enable','on');
            set(handles.selected_hosts_listbox,'enable','on');
            set(handles.delete_checkbox,'enable','on');
            set(handles.njob_edit,'enable','on');
            set(handles.ncpu_edit,'enable','on');
            set(handles.priority_edit,'enable','on');
            set(handles.randomize_checkbox,'enable','on');
            set(handles.search_hosts_pushbutton,'enable','on');
    end

    information(sprintf(['Before running parallel mode make sure that: \n'...
        '- UEMainAnalyseWindow.m has been recompiled\n'...
        '  after changes (run InstallUE)\n'...
        '- PVM is correctly installed and the deamon\n'...
        '  is running on all hosts\n'...
        '- ppmake is installed and its path included in\n'...
        '  the ep parameter of the PVM hostfile\n\n'...
        'For further informations about some settings klick on'...
        ' the corresponding help buttons.']),'b')

    % Wait for callbacks to run and window to be dismissed:
    uiwait(fig);

    handles = guidata(fig);

    switch handles.cancel
        case 'off'
            DataFile.PVM.ParallelMode       = handles.data.mode;
            DataFile.PVM.AllScratchesDir    = handles.data.allscratchesdir;
            DataFile.PVM.AllScratchesList   = handles.data.allscratches;
            DataFile.PVM.PartScratchesList  = handles.data.partscratches;
            DataFile.PVM.UsersScratchLink   = handles.data.usersscratchlnk;
            DataFile.PVM.AutomaticDelete    = handles.data.autodelete;
            DataFile.PVM.NumberOfJobs       = handles.data.njob;
            DataFile.PVM.NumberOfProcessors = handles.data.ncpu;
            DataFile.PVM.RandomizeWindows   = handles.data.randomize;
            DataFile.PVM.NicePriority       = handles.data.priority;

            information('Saved changes made in Parallel Mode menu','b');
            drawnow;
        case 'on'
            DataFile = handles.originaldata;

            information('No changes applied in Parallel Mode menu','b');
            drawnow;
    end

    delete(fig);


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



% CALLBACKS ---------------------------------------------------------------


% -------------------------------------------------------------------------
function varargout = users_scratch_pushbutton_Callback(h, eventdata, handles)

information(sprintf(['Specify the link which references the users''\n'...
    'scratch directory on each host.\n'...
    'This link should be the same on every host\n'...
    'but point to each host''s own scratch disk.']),'b');
drawnow;


% -------------------------------------------------------------------------
function varargout = all_scratches_pushbutton_Callback(h, eventdata, handles)

information(sprintf(['Specify the directory containing the mounted\n'...
    'scratch directories of all hosts and klick ''Search''\n'...
    'The directories can also be symbolic links.\n'...
    'The locations of these directories are needed when'...
    'the results of each host are collected after distribution'...
    'is finished.']),'b');
drawnow;


% -------------------------------------------------------------------------
function varargout = general_options_pushbutton_Callback(h, eventdata, handles)
information(sprintf(['Enable the load balancing mode if your analyzed data\n'...
                     'is strongly non-stationary. The analysis of the single\n'...
                     'windows are then randomly distributed among the hosts.\n\n'...
                     'When sharing the parallel system with multiple users\n'...
                     'you might want to decrease the processor priority of\n'...
                     'your calculations.\nThe range of values is:\n'...
                     '19 - lowest priority, thus beeing very ''nice''\n'...
                     ' :\n 0 - highest priority, system default']),'b');
drawnow;



% -------------------------------------------------------------------------
function varargout = mode_checkbox_Callback(h, eventdata, handles, varargin)

selection = get(handles.mode_checkbox,'value');

switch selection
    case 0
        set(handles.users_scratch_edit,'enable','off');
        set(handles.all_scratches_edit,'enable','off');
        set(handles.search_hosts_pushbutton,'enable','off');
        set(handles.add_host_pushbutton,'enable','off');
        set(handles.remove_host_pushbutton,'enable','off');
        set(handles.all_hosts_listbox,'enable','off');
        set(handles.selected_hosts_listbox,'enable','off');
        set(handles.delete_checkbox,'enable','off');
        set(handles.njob_edit,'enable','off');
        set(handles.ncpu_edit,'enable','off');
        set(handles.priority_edit,'enable','off');
        set(handles.randomize_checkbox,'enable','off');
    case 1
        set(handles.users_scratch_edit,'enable','on');
        set(handles.all_scratches_edit,'enable','on');
        set(handles.all_hosts_listbox,'enable','on');
        set(handles.selected_hosts_listbox,'enable','on');
        set(handles.search_hosts_pushbutton,'enable','on');
        set(handles.delete_checkbox,'enable','on');
        set(handles.njob_edit,'enable','on');
        set(handles.ncpu_edit,'enable','on');
        set(handles.priority_edit,'enable','on');
        set(handles.randomize_checkbox,'enable','on');
end


% --------------------------------------------------------------
function varargout = cancel_pushbutton_Callback(h, eventdata, handles, varargin)

uiresume(handles.figure1);

% ------------------------------------------------------------
function varargout = apply_pushbutton_Callback(h, eventdata, handles, varargin)

% check for indispensable information if parallel mode is activated
selection = get(handles.mode_checkbox,'value');

if selection && isempty(handles.data.partscratches)
    information(['You have enabled the parallel mode but the list of '...
        'participating hosts is empty! Unitary Events will '...
        'fail to collect and analyse the results. Please select '...
        'the participating hosts.'],'r');
    drawnow;

elseif selection && isempty(handles.data.usersscratchlnk)
    information(['You have enabled the parallel mode but the link to '...
        'your scratch directory is not specified. The parallelization '...
        'process needs to know where to save the results on '...
        'each host. Please specify the link.'],'r');
    drawnow;

    % indispensable information for parallel mode is available, save
    % settings
else

    selection = get(handles.mode_checkbox,'value');
    switch selection
        case 1
            handles.data.mode = 'on';
        case 0
            handles.data.mode = 'off';
    end

    selection = get(handles.delete_checkbox,'value');
    switch selection
        case 1
            handles.data.autodelete = 'on';
        case 0
            handles.data.autodelete = 'off';
    end

    selection = get(handles.randomize_checkbox,'value');
    switch selection
        case 1
            handles.data.randomize = 'on';
        case 0
            handles.data.randomize = 'off';
    end

    handles.data.allscratchesdir = get(handles.all_scratches_edit,'string');
    handles.data.allscratches    = get(handles.all_hosts_listbox,'string');
    handles.data.partscratches   = get(handles.selected_hosts_listbox,'string');
    handles.data.usersscratchlnk = get(handles.users_scratch_edit,'string');
    handles.data.ncpu            = str2num(get(handles.ncpu_edit,'string'));
    handles.data.njob            = str2num(get(handles.njob_edit,'string'));
    handles.data.priority        = str2num(get(handles.priority_edit,'string'));

    handles.cancel = 'off';

    guidata(h, handles);
    uiresume(handles.figure1);

end


% -------------------------------------------------------------------------
function varargout = users_scratch_edit_Callback(h, eventdata, handles, varargin)

scratch_link = get(handles.users_scratch_edit,'string');
    
if isdir(scratch_link)
    handles.data.usersscratchlnk = scratch_link;
    guidata(h,handles);
    information(sprintf(['The host independent link to the user''s scratch '...
                         'directory has been selected:\n%s'],scratch_link),'b');
    drawnow;
else
    information(['Invalid link or directory name!'],'r');
    drawnow;
end


% -------------------------------------------------------------------------
function varargout = all_scratches_edit_Callback(h, eventdata, handles, varargin)

all_scratches_dir = get(handles.all_scratches_edit,'string');

handles.data.allscratches = all_scratches_dir;

guidata(h,handles);
set(handles.search_hosts_pushbutton,'enable','on');
information(['Klick on "Select", the list of all hosts will'...
    'then be displayed in the corresponding listbox.'],'b');
drawnow;


% -------------------------------------------------------------------------
function varargout = search_hosts_pushbutton_Callback(h, eventdata, handles, varargin)

% initialize listofallhosts, clear list and get directory names
listofallhosts_struct = [];
listofallhosts        = [];
set(handles.all_hosts_listbox,'string',listofallhosts);
set(handles.add_host_pushbutton,'enable','off');

% get all directory names within handles.data.allscratches
listofallhosts = getDirContent(handles.data.allscratchesdir);

if isempty(listofallhosts)
    information('ERROR: Selected directory is empty','r');
    drawnow;
else
    % fill listofallhosts and activate pushbutton
    set(handles.all_hosts_listbox,'string',listofallhosts);
    set(handles.add_host_pushbutton,'enable','on');
    set(handles.add_all_pushbutton,'enable','on');

    % save all_hosts_listbox content to DataFile
    handles.data.allscratches = listofallhosts;

    guidata(h,handles);
    information(['You can choose hosts from the list "All hosts" and' ...
        'add them to the list of "Participating Hosts".'],'b');
    drawnow;

end


% -------------------------------------------------------------------------
function varargout = add_host_pushbutton_Callback(h, eventdata, handles)

% get host name from host list
all_hosts_selected_item = popupstr(handles.all_hosts_listbox);
oldstring = get(handles.selected_hosts_listbox,'string');

% check if there is at least one host in selected_hosts_listbox
if ~isempty(oldstring)
    % make sure that no host is selected twice
    if ~ismember(all_hosts_selected_item,cellstr(oldstring))
        set(handles.selected_hosts_listbox,'string',...
            char(oldstring,all_hosts_selected_item));
        information(['Host ' all_hosts_selected_item ...
            ' added to "Participating Hosts".'],'b');
        drawnow;
    else
        information('Each host can only be selected once','r');
        drawnow;
    end
else % no host selected up to now: select host and initialize remove button
    set(handles.selected_hosts_listbox,'string',all_hosts_selected_item);
    set(handles.remove_host_pushbutton,'enable','on');
    information(['Host ' all_hosts_selected_item ...
        ' added to "Participating Hosts".'],'b');
    drawnow;
end

% save handles.data.partscratches
handles.data.partscratches = get(handles.selected_hosts_listbox,'string');
guidata(h,handles);



% -------------------------------------------------------------------------
function varargout = add_all_pushbutton_Callback(h, eventdata, handles)

%set(handles.selected_hosts_listbox,'string','');
all_hosts = get(handles.all_hosts_listbox,'string');
set(handles.selected_hosts_listbox,'string',all_hosts);
set(handles.remove_host_pushbutton,'enable','on');
information('All available Hosts added to "Participating Hosts"','b');
drawnow;

% save handles.data.partscratches
handles.data.partscratches = get(handles.selected_hosts_listbox,'string');
guidata(h,handles);



% -------------------------------------------------------------------------
function varargout = remove_host_pushbutton_Callback(h, eventdata, handles)

% remove host from list
index_selected = get(handles.selected_hosts_listbox,'value');
%host_list = cellstr(get(handles.selected_hosts_listbox,'string'));
host_list = get(handles.selected_hosts_listbox,'string');
information(['Host ' host_list(index_selected) ...
    ' was removed from "Participating Hosts".'],'b');
host_list(index_selected,:) = [];

% update host_list
%host_list = char(host_list);
set(handles.selected_hosts_listbox,'string',host_list);
set(handles.selected_hosts_listbox,'value',1);

% check, if there are hosts left in selected_hosts, else disactivate remove button
if isempty(host_list)
    set(handles.remove_host_pushbutton,'enable','off');
end

% save handles.data.partscratches
handles.data.partscratches = get(handles.selected_hosts_listbox,'string');
guidata(h,handles);


% -------------------------------------------------------------------------
function varargout = ncpu_edit_Callback(h, eventdata, handles, varargin)
% -------------------------------------------------------------------------
function varargout = delete_checkbox_Callback(h, eventdata, handles, varargin)
% -------------------------------------------------------------------------
function varargout = njob_edit_Callback(h, eventdata, handles, varargin)
% -------------------------------------------------------------------------
function varargout = randomize_checkbox_Callback(h, eventdata, handles, varargin)
% -------------------------------------------------------------------------
function varargout = priority_edit_Callback(h, eventdata, handles, varargin)
% -------------------------------------------------------------------------
function varargout = all_hosts_listbox_Callback(h, eventdata, handles, varargin)
% -------------------------------------------------------------------------
function varargout = selected_hosts_listbox_Callback(h, eventdata, handles)


