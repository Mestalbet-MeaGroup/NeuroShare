function varargout = UESetup(varargin)
% UESETUP Application M-file for UESetup.fig
%    FIG = UESETUP launch UESetup GUI.
%    UESETUP('callback_name', ...) invoke the named callback.


if nargin == 0

    warning off;
    fig = openfig(mfilename,'reuse');

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    guidata(fig, handles);

    % Fill Figure with default parameters
    DataFile = [];
    load UEParameters_Default.mat; % returns DataFile structure
    if ~isempty(DataFile)
        handles.DataFile = DataFile;
        guidata(fig,handles);
        
        UESetupFillParameters(handles,handles.DataFile,1);
        information(sprintf(['Select a Project Directory with the following\n'...
                     'Structure:\n\n'...
                     '{PROJECT_DIR}/Data/ \n  --> containing the Data Files\n'...
                     '{PROJECT_DIR}/Params/ \n  --> containing Parameter Files\n'...
                     '{PROJECT_DIR}/Analysis/ \n  --> will contain Directories for each Analysis\n'...
                     '        each containing the respective Parameter and\n'...
                     '        Result Files']),'b');
        drawnow;
    else
        information('Could not load valid DataFile structure from UEParameters_Default.mat.','r');
        drawnow;
    end
    clear DataFile;

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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --------------------------------------------------------------------
function varargout = projectdir_submenu_Callback(h, eventdata, handles, varargin)

pdir = uigetdir(pwd,'Select Project Directory');

if pdir ~= 0
    
    if ~isdir([pdir  filesep 'Data' filesep])

        % check if /Data/ directory exists
        information(['Your Project Data needs to be contained in the directory '...
            '''' pdir  filesep 'Data'  filesep '. This directory was not found.'],'r');
        drawnow;

    else
        
        % clear existing settings
        load UEParameters_Default.mat;
        handles.DataFile = DataFile;
        guidata(h,handles);
        UESetupFillParameters(handles,handles.DataFile,1);
        set(handles.datafile_edit,'string','');
        set(handles.paramfile_edit,'string','');
        set(handles.analysisdir_edit,'string','');

        % set directories
        handles.projectdir = pdir;
        handles.paramsdir = [filesep 'Params' filesep];

        % search for data files
        datafiles = getDirContent([handles.projectdir filesep 'Data' filesep]);

        % check if /Params/ and /Analysis/ directories exist, else create
        if ~isdir([handles.projectdir filesep 'Params' filesep])
            try
                mkdir(handles.projectdir,'Params');
            catch
                information(lasterr,'r');
            end
        end
        if ~isdir([handles.projectdir filesep 'Analysis' filesep])
            try
                mkdir(handles.projectdir,'Analysis');
            catch
                information(lasterr,'r');
            end
        end

        % search for parameter files and analysis directories
        paramfiles    = getDirContent([handles.projectdir filesep 'Params' filesep]);
        analysis_list = getDirContent([handles.projectdir filesep 'Analysis' filesep]);
        if ~isempty(paramfiles)
            paramfiles = strcat('/Params/',paramfiles);
            for i = 1:length(analysis_list)
                str = strcat([handles.projectdir '/Analysis/'], analysis_list(i),'/Params/');
                files = getDirContent(str{1});
                if ~isempty(files)
                    files = strcat(['/Analysis/' analysis_list{i} '/Params/'],files);
                    paramfiles = [paramfiles files];
                end
            end
        end

        % update/initialize popup menus and information
        set(handles.projectdir_edit,'visible','on');
        set(handles.projectdir_edit,'string',handles.projectdir);

        if isempty(datafiles)
            set(handles.loaddata_popupmenu,'enable','on');
            set(handles.loaddata_popupmenu,'string','N/A');
        else
            set(handles.datafile_edit,'visible','on');
            set(handles.loaddata_popupmenu,'enable','on');
            set(handles.loaddata_popupmenu,'string',['Select' datafiles]);
        end

        if isempty(paramfiles)
            set(handles.loadparam_popupmenu,'enable','on');
            set(handles.loadparam_popupmenu,'string','N/A');
        else
            set(handles.paramfile_edit,'visible','on');
            set(handles.loadparam_popupmenu,'enable','on');
            set(handles.loadparam_popupmenu,'string',['Select' paramfiles]);
        end

        if isempty(analysis_list)
            set(handles.analysisdir_edit,'visible','on');
            set(handles.analysisdir_edit,'string','');
            set(handles.newanalysis_pushbutton,'visible','on');
            set(handles.selectanalysis_popupmenu,'enable','on');
            set(handles.selectanalysis_popupmenu,'string','N/A');
        else
            set(handles.analysisdir_edit,'visible','on');
            set(handles.newanalysis_pushbutton,'visible','on');
            set(handles.selectanalysis_popupmenu,'enable','on');
            set(handles.selectanalysis_popupmenu,'string',['Select' analysis_list]);
        end

        information(['Select a Data File or load a Parameter File. '...
            'Choose an existing Analysis Directory or create a new one!'],'b');
    end
end

guidata(h,handles);


% --------------------------------------------------------------------
function varargout = loaddata_popupmenu_Callback(h, eventdata, handles, varargin)

% get selected data file and reset popupmenu
if get(handles.loaddata_popupmenu,'value') == 1, return, end
pathname = [handles.projectdir '/Data/'];
handles.filename = popupstr(handles.loaddata_popupmenu);
set(handles.loaddata_popupmenu,'value',1);

% remove .gdf from filename and save filename in DataFile, set OutFileName
position = findstr('.gdf',handles.filename);
if ~isempty(position)
    handles.DataFile.FileName = handles.filename(1:(position-1));
    handles.DataFile.OutFileName = [handles.filename(1:(position-1)) 'Res'];
    set(handles.datafile_edit,'string',['/Data/' handles.filename]);
else
    handles.DataFile.FileName = handles.filename;
    handles.DataFile.OutFileName = [handles.filename 'Res'];
    set(handles.datafile_edit,'string',['/Data/' handles.filename '.gdf']);
end

% initialize listofallevents, clear list and get filename
listofallevents = [];
set(handles.allevents_listbox,'string',listofallevents);
set(handles.addneuron_pushbutton,'enable','off');
set(handles.addevent_pushbutton,'enable','off');

% read gdf-data from file
information('Wait while program is reading the GDF File.','b');
drawnow;
try
    gdf = read_gdf([pathname handles.DataFile.FileName '.gdf']);
catch
    information(lasterr,'r')
end

if isempty(gdf.Data)
    information('ERROR: File does not have the right format (read_gdf).','r');
elseif gdf.Data == -1
    information('ERROR: Could not open selected file (read_gdf).','r');
else

    % fill listofallevents and activate addneuron and addevent
    listofallevents = unique(gdf.Data(:,1));
    handles.DataFile.ListofallEvents = listofallevents;
    set(handles.allevents_listbox,'string',listofallevents);
    set(handles.addneuron_pushbutton,'enable','on');
    set(handles.addevent_pushbutton,'enable','on');

    % clear selected events
    set(handles.neuronlist_listbox,'string',[]);
    set(handles.eventlist_listbox,'string',[]);

    % set save mode
    set(handles.saveresultmode_checkbox,'visible','on');
    switch handles.DataFile.SaveResult.Mode
        case 'off'
            set(handles.saveresultmode_checkbox,'value',0);
        case 'on'
            set(handles.saveresultmode_checkbox,'value',1);
    end
    
    % set menus
    %set(handles.savepara_submenu,'enable','off');
    set(handles.saveparafile_submenu,'enable','on');
    set(handles.datahandling_menu,'enable','on');
    %set(handles.uemwafigure_menu,'enable','off');
    %set(handles.signfigure_menu,'enable','off');

    guidata(h,handles);

    information(['You can choose events from the list of all events in the selected file ' ...
        'and add them to the "List of Neurons" or the "List of selected Events".'],'b');
end
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = loadparam_popupmenu_Callback(h, eventdata, handles, varargin)

% load DataFile structure
if get(handles.loadparam_popupmenu,'value') == 1, return, end
DataFile = [];
paramlistpath = popupstr(handles.loadparam_popupmenu);
loadfilename = [handles.projectdir paramlistpath];
[path, handles.paramfile] = SplitFileName(loadfilename);
handles.paramsdir = setdiff(handles.paramfile,setdiff(loadfilename,handles.projectdir));
set(handles.loadparam_popupmenu,'value',1);

% Load Parameter File correcting for incompability on older Versions
DataFile = newParamLoading(loadfilename,handles);

% fill new parameters
if ~isempty(DataFile)
    handles.DataFile = DataFile;
    guidata(h,handles);
    UESetupFillParameters(handles,handles.DataFile,0);
    set(handles.paramfile_edit,'string',paramlistpath);
    set(handles.saveparafile_submenu,'enable','on');
    set(handles.savepara_submenu,'enable','on');

    handles.DataFile.FileName = handles.DataFile.OutFileName(1:end-3);
    set(handles.datafile_edit,'string',['/Data/' handles.DataFile.FileName]);

    % set save mode
    set(handles.saveresultmode_checkbox,'visible','on');
    switch handles.DataFile.SaveResult.Mode
        case 'off'
            set(handles.saveresultmode_checkbox,'value',0);
        case 'on'
            set(handles.saveresultmode_checkbox,'value',1);
    end

    % enable menues
    set(handles.uemwafigure_menu,'enable','on');
    set(handles.signfigure_menu,'enable','on');
    set(handles.datahandling_menu,'enable','on');
    
    guidata(h,handles);

    information(['Loaded new Parameter File: ' loadfilename],'b');
    drawnow;
else
    information('Could not load valid DataFile structure from selected Parameter File.','r');
    drawnow;
end

clear DataFile;


% --------------------------------------------------------------------
function varargout = selectanalysis_popupmenu_Callback(h, eventdata, handles, varargin)

if get(handles.selectanalysis_popupmenu,'value') == 1, return, end

handles.analysisname = popupstr(handles.selectanalysis_popupmenu);
set(handles.analysisdir_edit,'string',handles.analysisname);
set(handles.selectanalysis_popupmenu,'value',1);

% set save paths
handles.DataFile.OutPath = [handles.projectdir '/Analysis/' handles.analysisname '/Results/'];
handles.DataFile.UEMWAFigure.FileName = [handles.projectdir '/Analysis/'...
                                         handles.analysisname '/Results/'...
                                         handles.DataFile.FileName 'UEFigure'];
handles.DataFile.SignFigure.FileName = [handles.projectdir '/Analysis/' ...
                                        handles.analysisname  '/Results/'...
                                        handles.DataFile.FileName 'SignFigure'];
handles.paramsdir = ['/Analysis/' handles.analysisname '/Params/'];
guidata(h,handles);

information(sprintf(['The existing Analysis Directory ' handles.analysisname ...
                     ' has been chosen. Results will be saved in:\n' ...
                     handles.projectdir '/Analysis/' handles.analysisname '/Results/'...
                     '\nPlease save your Parameter File(s) under:\n'...
                     handles.projectdir '/Analysis/' handles.analysisname '/Params/']),'b');
drawnow;


% --------------------------------------------------------------------
function varargout = newanalysis_pushbutton_Callback(h, eventdata, handles, varargin)

analysis_name = get(handles.analysisdir_edit,'string');
analysis_name(isspace(analysis_name)) = [];
set(handles.analysisdir_edit,'string',analysis_name);

% check for empty string
if isempty(analysis_name), return, end

analysis_list = getDirContent([handles.projectdir '/Analysis/']);
% check if analysis directory exists already
exist = strmatch(analysis_name,analysis_list,'exact');
if ~isempty(exist) % directory already exists
    handles.analysisname = analysis_name;    
    information(sprintf(['The existing Analysis Directory ' handles.analysisname ...
                 ' has been chosen. Results will be saved in:\n' ...
                 handles.projectdir '/Analysis/' handles.analysisname '/Results/'...
                 '\nPlease save your Parameter File(s) under:\n'...
                 handles.projectdir '/Analysis/' handles.analysisname '/Params/']),'b');
    drawnow;
else % directory does not exist yet
    % make directories
    try
        mkdir([handles.projectdir '/Analysis'],analysis_name);
        mkdir([handles.projectdir '/Analysis/' analysis_name],'Results');
        mkdir([handles.projectdir '/Analysis/' analysis_name],'Params');
    catch
        information(lasterr,'r');
    end
    
    % update analysis list in popup menu
    analysis_list = getDirContent([handles.projectdir '/Analysis/']);
    set(handles.selectanalysis_popupmenu,'string',['Select' analysis_list]);
    
    handles.analysisname = analysis_name;
    
    information(sprintf(['The new Analysis Directory ' handles.analysisname ...
                 ' has been created. Results will be saved in:\n' ...
                 handles.projectdir '/Analysis/' handles.analysisname '/Results/'...
                 '\nPlease save your Parameter File(s) under:\n'...
                 handles.projectdir '/Analysis/' handles.analysisname '/Params/']),'b');
    drawnow;
end

% set save paths
handles.DataFile.OutPath = [handles.projectdir '/Analysis/' handles.analysisname '/Results/'];
handles.DataFile.UEMWAFigure.FileName = [handles.projectdir '/Analysis/'...
                                         handles.analysisname '/Results/'...
                                         handles.DataFile.FileName 'UEFigure'];
handles.DataFile.SignFigure.FileName = [handles.projectdir '/Analysis/' ...
                                        handles.analysisname  '/Results/'...
                                        handles.DataFile.FileName 'SignFigure'];
handles.paramsdir = ['/Analysis/' handles.analysisname '/Params/'];
guidata(h,handles);



% --------------------------------------------------------------------
function varargout = startue_pushbutton_Callback(h, eventdata, handles, varargin)

% check if analysis directory has been chosen
if ~isfield(handles,'analysisname') | isempty(handles.analysisname)
    information(['An Analysis Directory has to be chosen before UE Analysis '...
                 'can be started!'],'r');
    drawnow;
else
    
%     if isfield(handles,'paramfile')
%         % copy parameter file to current analysis if it doesnt exist
%         analysis_pfiles = getContentDir(handles.paramsdir);
%         exist = strmatch(handles.paramfile,analysis_pfiles,'exact');
%         if ~exist
%             copyfile();
    
    % add absolute path to data filename
    handles.DataFile.FileName = [handles.projectdir '/Data/' handles.DataFile.FileName];
    
    % START UE ANALYSIS
    information('Started UE Analysis with current Parameter Setting.','b');
    drawnow;
    UEMain(handles.DataFile);
end



% --------------------------------------------------------------------
function varargout = addneuron_pushbutton_Callback(h, eventdata, handles, varargin)

% get eventnumber form eventlist
allevents_selected_item = popupstr(handles.allevents_listbox);
oldstring = get(handles.neuronlist_listbox,'string');

% look, if there is allready at least one neuron selected
if ~isempty(oldstring)
    % make sure that no neuron is selected twice
    if ~ismember(allevents_selected_item,cellstr(oldstring))
        set(handles.neuronlist_listbox,'string',...
            char(oldstring,allevents_selected_item));
        information(['Added event ' allevents_selected_item  ...
            '  to "Selected Neurons".'],'b');
        drawnow;
    else
        information('Each neuron can only be selected once','r');
        drawnow;
    end
else % no neuron selected up to now, select neuron and initialize remove_button
    set(handles.neuronlist_listbox,'string',allevents_selected_item);
    set(handles.removeneuron_pushbutton,'enable','on');
    information(['Added event ' allevents_selected_item  ...
        '  to "Selected Neurons".'],'b');
    drawnow;
end

% save DataFile.NeuronList
handles.DataFile.NeuronList = (str2num(get(handles.neuronlist_listbox,'string')))';
guidata(h,handles);



% --------------------------------------------------------------------
function varargout = addevent_pushbutton_Callback(h, eventdata, handles, varargin)

% get eventnumber form eventlist
allevents_selected_item = popupstr(handles.allevents_listbox);
oldstring = get(handles.eventlist_listbox,'string');

% look, if there is allready at least one event selected
if ~isempty(oldstring)
    % make sure that no event is selected twice
    if ~ismember(allevents_selected_item,cellstr(oldstring))
        eventlist = char(oldstring,allevents_selected_item);
        set(handles.eventlist_listbox,'string',eventlist);
        set(handles.cutevent_popupmenu,'enable','on');
        set(handles.cutevent_popupmenu,'string',...
            char(oldstring,allevents_selected_item));

        information(['Added event ' allevents_selected_item  ...
            '  to "Selected Events".'],'b');
        drawnow;
    else
        information('Each event can only be selected once','r');
        drawnow;
    end
else % no event selected up to now, select event and initialize remove_button
    set(handles.eventlist_listbox,'string',allevents_selected_item);
    set(handles.removeevent_pushbutton,'enable','on');
    set(handles.cutevent_popupmenu,'enable','on');
    set(handles.cutevent_popupmenu,'string',allevents_selected_item);
    information(['Added event ' allevents_selected_item  ...
        '  to "Selected Events".'],'b');
    drawnow;
end

% save DataFile.Eventlist
handles.DataFile.EventList = (str2num(get(handles.eventlist_listbox,'string')))';
handles.DataFile.UEMWAFigure.EventsToPlot = handles.DataFile.EventList;
guidata(h,handles);



% --------------------------------------------------------------------
function varargout = removeneuron_pushbutton_Callback(h, eventdata, handles, varargin)

% get neuronnumber form neuronlist and convert to cell
index_selected = get(handles.neuronlist_listbox,'value');
neuronlist = cellstr(get(handles.neuronlist_listbox,'string'));
information(['Removed neuron ' neuronlist{index_selected}  ...
    '  from "Selected Neurons".'],'b');
neuronlist(index_selected)=[];
% convert neuronlist back to char
neuronlist=char(neuronlist);
set(handles.neuronlist_listbox,'string',neuronlist);
set(handles.neuronlist_listbox,'value',1);

% check, if there are neurons left in neuronlist, else disactivate removebutton
if isempty(neuronlist)
    set(handles.removeneuron_pushbutton,'enable','off');
end

% save DataFile.NeuronList
handles.DataFile.NeuronList = (str2num(get(handles.neuronlist_listbox,'string')))';
guidata(h,handles);



% --------------------------------------------------------------------
function varargout = removeevent_pushbutton_Callback(h, eventdata, handles, varargin)

% get eventnumber form eventlist and convert to cell
index_selected = get(handles.eventlist_listbox,'value');
eventlist = cellstr(get(handles.eventlist_listbox,'string'));
information(['Removed event ' eventlist{index_selected}  ...
    '  from "Selected Events".'],'b');
eventlist(index_selected)=[];
% convert eventlist back to char
eventlist=char(eventlist);
set(handles.eventlist_listbox,'string',eventlist);
% check, if there are events left in eventlist, else disactivate removebutton
if isempty(eventlist)
    set(handles.removeevent_pushbutton,'enable','off');
else
    set(handles.eventlist_listbox,'value',1);
end

% save DataFile.Eventlist
handles.DataFile.EventList = (str2num(get(handles.eventlist_listbox,'string')))';
guidata(h,handles);



% --------------------------------------------------------------------
function varargout = cutevent_popupmenu_Callback(h, eventdata, handles, varargin)

cutevent  = popupstr(handles.cutevent_popupmenu);
set(handles.cutevent_edit,'string',cutevent);
set(handles.uemwafigure_menu,'enable','on');
set(handles.signfigure_menu,'enable','on');
handles.DataFile.CutEvent = str2num(cutevent);
text = [handles.DataFile.FileName ', cut event: ' int2str(cutevent)];
set(handles.DataFile.UEMWAFigure.Text,'string',text);
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = tpre_edit_Callback(h, eventdata, handles, varargin)

handles.DataFile.TPre = str2num(get(handles.tpre_edit,'string'));
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = tpost_edit_Callback(h, eventdata, handles, varargin)

handles.DataFile.TPost = str2num(get(handles.tpost_edit,'string'));
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = timeunits_edit_Callback(h, eventdata, handles, varargin)

handles.DataFile.TimeUnits = str2num(get(handles.timeunits_edit,'string'));
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = alpha_edit_Callback(h, eventdata, handles, varargin)

handles.DataFile.Analysis.Alpha = str2num(get(handles.alpha_edit,'string'));
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = complexity_edit_Callback(h, eventdata, handles, varargin)

handles.DataFile.Analysis.Complexity = str2num(get(handles.complexity_edit,'string'));
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = complexity_max_Callback(h, eventdata, handles, varargin)

handles.DataFile.Analysis.ComplexityMax = str2num(get(handles.complexity_max,'string'));
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = binsize_edit_Callback(h, eventdata, handles, varargin)

handles.DataFile.Analysis.Binsize = str2num(get(handles.binsize_edit,'string'));
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = tslid_edit_Callback(h, eventdata, handles, varargin)

handles.DataFile.Analysis.TSlid = str2num(get(handles.tslid_edit,'string'));
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = windowshift_edit_Callback(h, eventdata, handles, varargin)

handles.DataFile.Analysis.WindowShift = str2num(get(handles.windowshift_edit,'string'));
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = uemethod_popupmenu_Callback(h, eventdata, handles, varargin)

selection = get(handles.uemethod_popupmenu,'value');
switch selection
    case 1
        handles.DataFile.Analysis.UEMethod = 'trialaverage';
    case 2
        handles.DataFile.Analysis.UEMethod = 'trialbytrial';
    case 3
        handles.DataFile.Analysis.UEMethod = 'csr';
        information(['CSR Parameters can be changed in the "General Options" '...
            'submenu of the "File" Menu.'],'b');
        drawnow;
end
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = wildcard_popupmenu_Callback(h, eventdata, handles, varargin)

selection = get(handles.wildcard_popupmenu,'value');
switch selection
    case 1
        handles.DataFile.Analysis.Wildcard = 'off';
    case 2
        handles.DataFile.Analysis.Wildcard = 'on';
end
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = saveresultmode_checkbox_Callback(h, eventdata, handles, varargin)

mode = get(handles.saveresultmode_checkbox,'value');
switch mode
    case 0
        handles.DataFile.SaveResult.Mode = 'off';
        %set(handles.outfilename_edit,'visible','off');
    case 1
        handles.DataFile.SaveResult.Mode = 'on';
        %set(handles.outfilename_edit,'visible','on');
end
% save ResultMode to DataFile.Result.Mode
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = datahandling_menu_Callback(h, eventdata, handles, varargin)

information('','b');
handles.DataFile = datahandling('init',handles.DataFile);
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = uemwafigure_menu_Callback(h, eventdata, handles, varargin)

information('','b');
handles.DataFile = uemwaparameters('init',handles.DataFile);
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = signfigure_menu_Callback(h, eventdata, handles, varargin)

information('','b');
handles.DataFile = signparameters('init',handles.DataFile);
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = dotdisplay_menu_Callback(h, eventdata, handles, varargin)

information('','b');
handles.DataFile = dotparameters('init',handles.DataFile);
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = batchmode_menu_Callback(h, eventdata, handles, varargin)

batchwindow;


% --------------------------------------------------------------------
function parallelmode_menu_Callback(h, eventdata, handles)

information('','b');
handles.DataFile = parallelmode('init',handles.DataFile);
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = saveparafile_submenu_Callback(h, eventdata, handles, varargin)

[path, fname] = SplitFileName(handles.DataFile.FileName);
[filename, pathname] = uiputfile('*.mat','Save Parameters to File',...
    [handles.projectdir handles.paramsdir fname 'Param']);

if ~(filename == 0)
    % eventually add .mat to filename
    position = findstr('.mat',filename);
    if isempty(position)
        savefilename = [pathname filename '.mat'];
    else
        savefilename = [pathname filename];
    end
    % save DataFile structure
    DataFile = handles.DataFile;
    save(savefilename,'DataFile');
    
    % update parameter file list
    paramfiles_old = get(handles.loadparam_popupmenu,'string');
    paramfiles_old(1,:) = [];
    if isfield(handles,'analysisdir')
        paramfile_new = ['/Analysis/' handles.analysisname '/Params/' filename];
    else
        paramfile_new = ['/Params/' filename];
    end
    set(handles.paramfile_edit,'string',paramfile_new);
    set(handles.savepara_submenu,'enable','on');
    set(handles.loadparam_popupmenu,'string',['Select' paramfiles_old ; paramfile_new]);
    
    information(['Saved Parameter Setting to File: ' savefilename],'b');
    drawnow;
end


% --------------------------------------------------------------------
function varargout = savepara_submenu__Callback(h, eventdata, handles, varargin)

filename = get(handles.paramfile_edit,'string');
% eventually add .mat to filename
position = findstr('.mat',filename);
if isempty(position)
    savefilename = [filename '.mat'];
else
    savefilename = filename;
end
% save DataFile structure
DataFile = handles.DataFile;
save(savefilename,'DataFile');
information(['Saved Parameter Setting to File: ' savefilename],'b');
drawnow;


% --------------------------------------------------------------------
function varargout = resetpara_submenu_Callback(h, eventdata, handles, varargin)

% Load new default DataFile structure and fill parameters
try
    load UEParameters_Default.mat;
    handles.DataFile = DataFile;
    guidata(h,handles);
    UESetupFillParameters(handles,handles.DataFile,1);
    information('Parameters have been set back to default values.','b');
catch
    information(lasterr,'r');
end


% --------------------------------------------------------------------
function varargout = generaloptions_submenu_Callback(h, eventdata, handles,varargin)

information('','b');
drawnow;
handles.DataFile = generaloptions('init',handles.DataFile);
guidata(h,handles);


% --------------------------------------------------------------------
function varargout = close_submenu_Callback(h, eventdata, handles, varargin)

close all;


% --------------------------------------------------------------------
function varargout = check_pushbutton_Callback(h, eventdata, handles, varargin)

checkdatafile(handles.DataFile);


% --------------------------------------------------------------------
function varargout = closeplots_submenu_Callback(h, eventdata, handles, varargin)

set(handles.figure1,'HandleVisibility','off')
close all;
set(handles.figure1,'HandleVisibility','on')


% --------------------------------------------------------------------
function varargout = file_menu_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = paramfile_edit_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = datafile_edit_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = projectdir_edit_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = analysisdir_edit_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = allevents_listbox_Callback(h, eventdata,handles, varargin)

% --------------------------------------------------------------------
function varargout = neuronlist_listbox_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = eventlist_listbox_Callback(h, eventdata, handles, varargin)

