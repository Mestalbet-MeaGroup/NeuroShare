function FIND_GUI()
% GUI for extracting and handling neuronal data.
%
% Data sources can be files stored in Neuroshare compatible data files.
% Furthermore, additional data formats are in the
% process of being incorporated like GDF (Goettingen Data Format) and data
% acquired with Meabench.
%
% Markus Nenniger 2005-2007, mnenniger@gmx.net
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

% makes sure that no other windows of the same type are open

global nsFile;

if ishandle(findobj('tag', 'FIND_GUI'))
    close(findobj('tag', 'FIND_GUI'));
end;


% default values for button size etc. to be used in the main window and the
% sub windows; units in characters

global BUTTON_HEIGHT;
global LABEL_HEIGHT;
global MESSAGEBAR_PANEL_HEIGHT
global MESSAGEBAR_LEFT_OFFSET %for placement in panel
global MESSAGEBAR_RIGHT_OFFSET

BUTTON_HEIGHT=1.35;
LABEL_HEIGHT=1.1;
MESSAGEBAR_PANEL_HEIGHT=1.5;
MESSAGEBAR_LEFT_OFFSET=1;
MESSAGEBAR_RIGHT_OFFSET=2;

% Initialize FIND settings. These are stored in a variable called
% FIND_GUIdata, which will then be used to set the 'UserData' property of
% the GUI figure after it is created below. Access with
% FIND_GUIdata = get(findobj('Tag','FIND_GUI'),'UserData');
% Furthemore, the nsFile variable is initialized.
init;





% the global ones are needed within the
% resize function
global MAIN_MIN_WIDTH;
global MAIN_MIN_HEIGHT;

%some panels are flexible in one or both dimensions, in these cases the
%values below are minimal values
topPanelHeight=6;
topPanelWidth=157;
leftPanelHeight=13;
leftPanelWidth=33;
rightPanelHeight=13;
rightPanelWidth=topPanelWidth-leftPanelWidth;
bottomPanelHeight=8;
bottomPanelWidth=topPanelWidth;
messageBarPanelWidth=bottomPanelWidth;


MAIN_MIN_WIDTH=topPanelWidth;
MAIN_MIN_HEIGHT=topPanelHeight+rightPanelHeight+bottomPanelHeight+ ...
    MESSAGEBAR_PANEL_HEIGHT;


mainWindow=figure('Units','characters',...
    'Position',[20 5 MAIN_MIN_WIDTH MAIN_MIN_HEIGHT], ...
    'Tag','FIND_GUI', ...
    'Name','FIND Data Handling Interface',...
    'DeleteFcn',@deleteMain,...
    'ResizeFcn',@resizeCallback,...
    'NumberTitle','off',...
    'MenuBar','none');

set(mainWindow,'UserData',FIND_GUIdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Help menu%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

helpMenu=uimenu('Parent',mainWindow,...
    'Label','&Help');

uimenu('Parent',helpMenu,...
    'Label','What does this GUI do?',...
    'Callback','disp(''For detailed and actual help call generate_documentation.m and have a look at the html tree. '')');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% panels %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%size parameters see above main window initialization

topPanel=uipanel('Parent',mainWindow,...
    'Units','characters',...
    'Position',[0 (MAIN_MIN_HEIGHT-topPanelHeight)...
    topPanelWidth topPanelHeight],...
    'Tag','FIND_GUI_topPanel',...
    'BackgroundColor', [0.8 0.8 0.8]);

leftPanel=uipanel('Parent',mainWindow,...
    'Units','characters',...
    'Position',[0 ...
    (bottomPanelHeight+MESSAGEBAR_PANEL_HEIGHT)...
    leftPanelWidth leftPanelHeight],...
    'Tag','FIND_GUI_leftPanel',...
    'BackgroundColor', [0.8 0.8 0.8]);

rightPanel=uipanel('Parent',mainWindow,...
    'Units','characters',...
    'Position',[leftPanelWidth ...
    (bottomPanelHeight+MESSAGEBAR_PANEL_HEIGHT)...
    rightPanelWidth rightPanelHeight],...
    'Tag','FIND_GUI_rightPanel',...
    'BackgroundColor', [0.8 0.8 0.8]);

bottomPanel=uipanel('Parent',mainWindow,...
    'Units','characters',...
    'Position',[0 MESSAGEBAR_PANEL_HEIGHT ...
    bottomPanelWidth bottomPanelHeight],...
    'Tag','FIND_GUI_bottomPanel',...
    'BackgroundColor', [0.8 0.8 0.8]);

messageBarPanel=uipanel('Parent',mainWindow,...
    'Units','characters',...
    'Position',[0 0 ...
    messageBarPanelWidth MESSAGEBAR_PANEL_HEIGHT],...
    'Tag','FIND_GUI_messageBarPanel');


% find logo top right; a little bit clumsy because of the units
oldUnits=get(topPanel,'Units');
set(topPanel,'Units','pixels');
topPanelpos=get(topPanel,'Position');
axes('Parent', topPanel,'Units', 'pixels'); %logo

set(topPanel,'Units',oldUnits);

%image(imread('find_logo.png'));
set(gca,'DataAspectRatioMode','manual', 'Visible','off',...
    'Position', [0 0 topPanelpos(4) topPanelpos(4)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% file loading controls %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[2    3.42  15    LABEL_HEIGHT],...
    'Tag','FIND_GUI_filenameLabelText',...
    'Enable','on',...
    'String','File to load:',...
    'Style','text');

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[19.75    3.42    72.5    LABEL_HEIGHT],...
    'Tag','FIND_GUI_dataFileEdit',...
    'Enable','on',...
    'Style','edit',...
    'BackgroundColor','w',...
    'TooltipString','Enter filename here; path can be relative.',...
    'Callback',@dataFileEditCallback);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[92.25    3.295    15    BUTTON_HEIGHT],...
    'Tag','FIND_GUI_browseDataFilePushbutton',...
    'String','Browse',...
    'Enable','on',...
    'TooltipString','Browse filesystem for file to load.',...
    'Callback',@browseDataFilePushbuttonCallback);


uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[2    1.72    15    LABEL_HEIGHT],...
    'Tag','FIND_GUI_fileInUseLabelText',...
    'Enable','on',...
    'String','File in use:',...
    'Style','text');

% contains the string used to load the data file

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[19.75 1.72    87.5    LABEL_HEIGHT],...
    'Tag','FIND_GUI_fileInUseText',...
    'Enable','on',...
    'Tooltipstring','currently selected file',...
    'Style','text');


%%%%%%%%%%%%% info selection controls %%%%%%%%%%%%%%


% title
uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[118.75    4    30    LABEL_HEIGHT],...
    'Tag','FIND_GUI_infoCheckboxesLabelText',...
    'Enable','on',...
    'String','Entity info to retrieve',...
    'Tooltipstring',' Retrieve info for these entity types when loading the file. ',...
    'Style','text');


% all

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[112    2.1  3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_allInfoCheckbox',...
    'Tooltipstring','Retrieve info for all entity types when loading the file.',...
    'Value',0,...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8],...
    'Callback',@allInfoCheckboxCallback);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[115.5    2.1    10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_allInfoLabelText',...
    'Tooltipstring','Retrieve info for all entity types when loading the file.',...
    'Enable','on',...
    'String','All',...
    'Style','text');



% general

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[112    .5  3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_generalInfoCheckbox',...
    'Enable','off',...
    'Tooltipstring','Retrieve general entity info when loading the file.',...
    'Value',1,...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[115.5    .5    10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_generalInfoLabelText',...
    'Tooltipstring','Retrieve general entity info when loading the file.',...
    'Enable','on',...
    'String','General',...
    'Style','text');


% event

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[126.5    2.1    3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_eventInfoCheckbox',...
    'Enable','on',...
    'Tooltipstring','Retrieve info for event entities when loading the file.',...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[130    2.1   10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_eventInfoLabelText',...
    'Tooltipstring','Retrieve info for event entities when loading the file.',...
    'Enable','on',...
    'String','Event',...
    'Style','text');

% analog

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[126.5    0.5    3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_analogInfoCheckbox',...
    'Enable','on',...
    'Tooltipstring','Retrieve info for analog entities when loading the file.',...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[130    0.5    10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_analogInfoLabelText',...
    'Tooltipstring','Retrieve info for analog entities when loading the file.',...
    'Enable','on',...
    'String','Analog',...
    'Style','text');



% segment

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[141    2.1    3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_segmentInfoCheckbox',...
    'Enable','on',...
    'Tooltipstring','Retrieve info for segment entities when loading the file.',...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[144.5    2.1    10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_segmentInfoLabelText',...
    'Tooltipstring','Retrieve info for segment entities when loading the file.',...
    'Enable','on',...
    'String','Segment',...
    'Style','text');

% neural

uicontrol('Parent', topPanel,...
    'Units','characters',...
    'Position',[141    0.5    3    LABEL_HEIGHT],...
    'Tag','FIND_GUI_neuralInfoCheckbox',...
    'Enable','on',...
    'Tooltipstring','Retrieve info for neural entities when loading the file.',...
    'Style','checkbox',...
    'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Parent',topPanel,...
    'Units','characters',...
    'Position',[144.5    0.5    10    LABEL_HEIGHT],...
    'Tag','FIND_GUI_neuralInfoLabelText',...
    'Tooltipstring','Retrieve info for neural entities when loading the file.',...
    'Enable','on',...
    'String','Neural',...
    'Style','text');


% browse entities

uicontrol('Parent',leftPanel,...
    'Units','characters',...
    'Position',[4   10    25    BUTTON_HEIGHT],... %0.55
    'Style','pushbutton',...
    'String','Browse Entities',...
    'Tag','FIND_GUI_browseEntitiesPushbutton',...
    'Enable','on',...
    'Callback',@browseEntitiesPushbuttonCallback);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% info boxes %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fileinfo - BOX

uicontrol('Parent',rightPanel,...
    'Units','normalized',...
    'Position',[0.03    0.05    0.45    0.9],...
    'Style','ListBox',...
    'String','Fileinfo',...
    'Tag','FIND_GUI_fileInfoListBox',...
    'HorizontalAlignment','left',...
    'Enable','on');

% Structure INFO Listobox
uicontrol('Parent',rightPanel,...
    'Units','normalized',...
    'Position',[0.52    0.05    0.45    0.9],...
    'Style','ListBox',...
    'String',structure2text(nsFile),...
    'Tag','FIND_GUI_structureInfoListBox',...
    'Enable','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% tool buttons %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% analog data based Spike Detection

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[15 3 25 BUTTON_HEIGHT],...
    'Style','pushbutton',...
    'String','Nonlin. Interdep.',...
    'Tag','FIND_GUI_NLITVtoolGUIpushbutton',...
    'Enable','on',...
    'Callback',@NLITVtoolGUIpushbuttonCallback);

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[15    1    25    BUTTON_HEIGHT],...
    'Style','pushbutton',...
    'String','Detect Spikes',...
    'Tag','FIND_GUI_detectSpikesGUIpushbutton',...
    'Enable','on',...
    'Callback',@detectSpikesGUIpushbuttonCallback);

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[45    1    25    BUTTON_HEIGHT],...
    'Style','pushbutton',...
    'String','Sort Spikes',...
    'Tag','FIND_GUI_sortSpikesGUIpushbutton',...
    'Enable','on',...
    'Callback',@sortSpikesGUIpushbuttonCallback);

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[75    1   25   BUTTON_HEIGHT],...
    'Style','pushbutton',...
    'String','Sim. Gamma Proc.',...
    'Tag','FIND_GUI_simulateGammaGUIpushbutton',...
    'Enable','on',...
    'Callback',@simulateGammaGUIpushbuttonCallback);

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[105 3 25 BUTTON_HEIGHT],... %-% 1 and 25 are suggestions
    'Style','pushbutton',...
    'String','Import GDF',...
    'Tag','FIND_GUI_importGDF_GUIpushbutton',...
    'Enable','on',...
    'Callback',@importGDF_GUIpushbuttonCallback);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% export data Button  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[105 5 25 BUTTON_HEIGHT],... %-% 1 and 25 are suggestions
    'Style','pushbutton',...
    'String','Data Export',...
    'Tag','FIND_GUI_DataExport_GUIpushbutton',...
    'Enable','on',...
    'Callback',@DataExport_GUIpushbuttonCallback);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Unitary Events Button %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[75 3 25 BUTTON_HEIGHT],...
    'Style','pushbutton',...
    'String','Unitary Events',...
    'Tag','FIND_GUI_startUEpushbutton',...
    'Enable','on',...
    'Callback',@startUEpushbuttonCallback);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Spatiotemporal receptive field Button %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[75 5 25 BUTTON_HEIGHT],...
    'Style','pushbutton',...
    'String','Receptive Field',...
    'Tag','FIND_GUI_startStrfpushbutton',...
    'Enable','on',...
    'Callback',@startStrfpushbuttonCallback);


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Auto Align Button
%%%%%%%%%%%%%%%%%%%%%%%%

% function autoAlignGUIpushbutton=
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[45 3 25 BUTTON_HEIGHT],...
    'Style','pushbutton',...
    'String','AutoAlign',...
    'Tag','FIND_GUI_autoAlignGUIpushbutton',...
    'Enable','on',...
    'Callback',@autoAlignGUIpushbuttonCallback);
%-% use {@myCallback,arg1,arg2,...} to have args


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ParPoPro Button
%%%%%%%%%%%%%%%%%%%%%%%%

% function ParPoProGUIpushbutton=
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[45 5 25 BUTTON_HEIGHT],...
    'Style','pushbutton',...
    'String','ParPoPro',...
    'Tag','FIND_GUI_ParPoProGUIpushbutton',...
    'Enable','on',...
    'Callback',@ParPoProGUIpushbuttonCallback);


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CleanData Button
%%%%%%%%%%%%%%%%%%%%%%%%

% function CleanDataGUIpushbutton=
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[15 5 25 BUTTON_HEIGHT],...
    'Style','pushbutton',...
    'String','CleanData',...
    'Tag','FIND_GUI_ClaenDataGUIpushbutton',...
    'Enable','on',...
    'Callback',@CleanDataGUIpushbuttonCallback);

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PreProcessing
%%%%%%%%%%%%%%%%%%%%%%%%

% function basicProcessing=
uicontrol('Parent',bottomPanel,...
    'Units','characters',...
    'Position',[105 1 25 BUTTON_HEIGHT],...
    'Style','pushbutton',...
    'String','basic Processing',...
    'Tag','FIND_GUI_basicProcessingGUIpushbutton',...
    'Enable','on',...
    'Callback',@basicProcessingGUIpushbuttonCallback);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% MESSAGEBAR %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

messageBarPanelpos=get(messageBarPanel,'Position');

uicontrol('Parent',messageBarPanel,...
    'Units','characters',...
    'Position',[(messageBarPanelpos(1)+MESSAGEBAR_LEFT_OFFSET) ...
    (messageBarPanelpos(2)) ...
    (messageBarPanelpos(3)-MESSAGEBAR_RIGHT_OFFSET) ...
    LABEL_HEIGHT],...
    'Tag','messageBar',...
    'Enable','on',...
    'String','Welcome to FIND!',...
    'HorizontalAlignment','left',...
    'Style','text');


% prevent main window from becoming the target for graphics output
set(mainWindow,'HandleVisibility','callback');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% filehandling functions %%%%%%%%%%%%%%%%%%%%


function loadDataFile(fullFileName)
%Compile necessary information from the FIND_GUI settings and then load
%data file using the FIND_loader.
%
%loadDataFile compiles a list of parameter value pairs to pass to
%FIND_loader depending on which checkboxes for information about entities
%are checked. For documentation of FIND_loader parameters, see help
%FIND_loader.
%
%loadDataFile will be called either from dataFileEditCallback or from
%browseDataFilePushbuttonCallback. These correspond to either using the
%edit box or the browse button to determine the fullFileName (which
%includes the path, which does not have to be absolute.).

global nsFile;

try

    postMessage('');
    postMessage('Busy - please wait...');


    if ~isempty(nsFile.Analog.Data)||~isempty(nsFile.Segment.Data{1})||...
            ~isempty(nsFile.Event.TimeStamp{1})||~isempty(nsFile.Neural.Data{1})||...
            ~isempty(nsFile.EntityInfo(1).EntityLabel)
        loadModeSwitch=questdlg('Data already exists in the nsFile variable! Partially overwriting might arouse problems!',...
            'Do you want to reset FIND?', ...
            'reset','cancel','cancel');
        if strcmp(loadModeSwitch, 'reset')
            clear global nsFile;
            %whos;
            evalin('base','init;');
            whos;
            %global nsFile;
            %whos;
        else
            warning('already data in the variable - conflicts possible');
        end
    end


    PVPlist={'fileInfo',1};

    %compile list of parameter value pairs to pass to FIND_loader depending on
    %which checkboxes for information about entities are checked. for
    %documentation of FIND_loader parameters, see help FIND_loader.

    % this checkbox cant be unchecked
    if get(findobj(gcf,'Tag','FIND_GUI_generalInfoCheckbox'),'Value')==1
        PVPlist{length(PVPlist)+1}='entityInfo';
        PVPlist{length(PVPlist)+1}='all';
    end

    % analog entity information. stored in nsFile.Analog.Info
    if get(findobj(gcf,'Tag','FIND_GUI_analogInfoCheckbox'),'Value')==1
        PVPlist{length(PVPlist)+1}='analogInfo';
        PVPlist{length(PVPlist)+1}='all';
    end

    % event entity information. stored in nsFile.event.Info
    if get(findobj(gcf,'Tag','FIND_GUI_eventInfoCheckbox'),'Value')==1
        PVPlist{length(PVPlist)+1}='eventInfo';
        PVPlist{length(PVPlist)+1}='all';
    end

    % segment entity information. stored in nsFile.segment.Info
    if get(findobj(gcf,'Tag','FIND_GUI_segmentInfoCheckbox'),'Value')==1
        PVPlist{length(PVPlist)+1}='segmentInfo';
        PVPlist{length(PVPlist)+1}='all';
    end

    % neural entity information. stored in nsFile.Neural.Info
    if get(findobj(gcf,'Tag','FIND_GUI_neuralInfoCheckbox'),'Value')==1
        PVPlist{length(PVPlist)+1}='neuralInfo';
        PVPlist{length(PVPlist)+1}='all';
    end

    % dll path stored in the UserData (loaded from init.m)
    FIND_GUIdata = get(findobj('Tag','FIND_GUI'),'UserData');
    DLLpath=FIND_GUIdata.DLLpath;

    FIND_loader('fileName',fullFileName,'DLLpath',DLLpath, PVPlist{:});

    %show which file is in use in the GUI.
    set(findobj(gcf,'Tag','FIND_GUI_fileInUseText'),'String',fullFileName);
    %Also setting the current data file in the edit box.
    set(findobj(gcf,'Tag','FIND_GUI_dataFileEdit'),'String',fullFileName);

    evalin('caller','global nsFile');

    global nsFile;
    % get values for all fields in nsFile.FileInfo (general file info) and
    % write the in the big textbox (streamfileinfobox) in the main GUI.
    tempFieldNames=fieldnames(nsFile.FileInfo);
    tempFieldContent=struct2cell(nsFile.FileInfo);
    for ii = 1: size(tempFieldNames,1)
        tempString{ii}=strcat(tempFieldNames{ii},':  ',num2str(tempFieldContent{ii}));
    end
    set(findobj(gcbf,'Tag','FIND_GUI_fileInfoListBox'),'String',tempString);


    %%% Get the structure-info and write it into the list box
    set(findobj(gcbf,'Tag','FIND_GUI_structureInfoListBox'),'String',structure2text(nsFile));


    % (re)set selected entities
    FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
    FIND_GUIdata.IDselected=zeros(1,length(nsFile.EntityInfo));
    set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
    postMessage('...done.');
catch
    handleError(lasterror);
end


function dataFileEditCallback(source,event)
% Callback for the data file edit box. Calls loadDataFile().
%
fullFileName=get(findobj(gcf,'Tag','FIND_GUI_dataFileEdit'),'String');
try
    loadDataFile(fullFileName);
catch
    handleError(lasterror);
end


function browseDataFilePushbuttonCallback(source,event)
% Callback for the "browse" button, allows user to browse the filesystem
% to select a data file. Calls loadDataFile().

%%% THIS IS A ON THE FLY WORKAROUND of the uigetfile bug on some releases on
%%% linux --> see matlab bug report for details:
% % %
% % % Summary  	   	uigetfile sometimes works incorrectly on Linux platforms.
% % % Report ID 	  	259878
% % % Date Last Modified 	  	14 Nov 2006
% % % Product 	  	MATLABå¨
% % % Exists In Version 	  	7.0.1, 7.0.4, 7.1, 7.2, 7.3
% % % Exists In Release 	  	R14SP1, R14SP2, R14SP3, R2006a, R2006b
% % % Fixed In Version 	  	7.4
% % % Fixed In Release 	  	R2007a

if isunix
    setappdata(0,'UseNativeSystemDialogs',false);
    postMessage('Changed UI dialogs (LINUX only) as a workaround for matlab bug report ID: 259878');
end

%%% end of MATLAB Bugfix

prevFile=get(findobj(gcf,'Tag','FIND_GUI_dataFileEdit'),'String');
if ~isempty(prevFile)
   [prevSearchPath, ~, ~]=fileparts(prevFile);
   FIND_Path=pwd;
   cd(prevSearchPath)
end

[dataFileName,dataFilePath,filterSpec]=uigetfile({'*.*','all files';
    '*.mcd','MCRack files';...
    '*.smr','smr files';...
    '*.map','Alpha Omega files';...
    '*.nex','NeuroExplorer files';...
    '*.plx','Plexon files';...
    '*.stb','Tucker Davis files';...
    '*.spike','Meabench spike files'});

if dataFilePath==0, return, end; % if the action is cancelled do nothing

if ~isempty(prevFile)
    cd(FIND_Path);
end

loadDataFile(fullfile(dataFilePath,dataFileName));



function allInfoCheckboxCallback(source, event)
% Clicking the 'all' checkbox checks/unchecks all other info checkboxes
% accordingly.

allCheckedValue=get(findobj(gcf,'Tag','FIND_GUI_allInfoCheckbox'),'Value');

set(findobj(gcf,'Tag','FIND_GUI_eventInfoCheckbox'), 'Value',allCheckedValue)
set(findobj(gcf,'Tag','FIND_GUI_analogInfoCheckbox'), 'Value',allCheckedValue)
set(findobj(gcf,'Tag','FIND_GUI_segmentInfoCheckbox'), 'Value',allCheckedValue)
set(findobj(gcf,'Tag','FIND_GUI_neuralInfoCheckbox'), 'Value',allCheckedValue)




function browseEntitiesPushbuttonCallback(source,event)
%this starts up browseEntitiesGUI, enabling the user to browse through the datafile
%entities.

global nsFile
try
    postMessage(''); % Clean up prior messages.
    fileInUse=get(findobj('Tag','FIND_GUI_fileInUseText'),'String');
    if isempty(fileInUse)
        error('FIND:noFileLoaded','');
    else
        browseEntitiesGUI();
    end
catch
    handleError(lasterror);
end

%%% Get the structure-info and write it into the list box Update after
%%% Browsing!
set(findobj(gcbf,'Tag','FIND_GUI_structureInfoListBox'),'String',structure2text(nsFile));



%%%%%%%%%%% tool functions %%%%%%%%%%%%%%%%%%%%


function detectSpikesGUIpushbuttonCallback(source,event)
%% After loading of the data, spike detection may be performed!
% IMHO unnecessary to issue a warning here

global nsFile

try
    postMessage(''); % Clean up prior messages.
    detectSpikesGUI();
catch
    handleError(lasterror);
end

%%% Get the structure-info and write it into the list box Update after
%%% Browsing!
set(findobj(gcbf,'Tag','FIND_GUI_structureInfoListBox'),'String',structure2text(nsFile));

function NLITVtoolGUIpushbuttonCallback(source,event)

global nsFile
try
    postMessage(''); % Clean up prior messages.
    NLITVtoolGUI();
catch
    handleError(lasterror);
end
% End of function NLITVtoolGUIpushbuttonCallback(source,event)


function sortSpikesGUIpushbuttonCallback(source,event)
%% After spike detection, spike sorting may be performed!

global nsFile

try
    postMessage(''); % Clean up prior messages.
    sortSpikesGUI();
catch
    handleError(lasterror);
end

%%% Get the structure-info and write it into the list box Update after
%%% Browsing!
set(findobj(gcbf,'Tag','FIND_GUI_structureInfoListBox'),'String',structure2text(nsFile));
% END OF THIS FUNCTION


function  simulateGammaGUIpushbuttonCallback(source,event)
% call the Gamma function Simulation GUI

global nsFile;
postMessage(''); % Clean up prior messages.
simulateGammaGUI();



function importGDF_GUIpushbuttonCallback(source,event)
% Callback for the button that starts the tool's GUI.
% Source and event args are generated by default.
try
    postMessage(''); % Clean up prior messages.
    postMessage('Busy - please wait...');
    importGDF_GUI();
    postMessage('...done.');

catch
    handleError(lasterror);
end


%use {@myCallback,arg1,arg2,...} to have args

function DataExport_GUIpushbuttonCallback(source,event)
% source and event args are generated by default
try
    postMessage(''); % Clean up prior messages.

    % some checks maybe here?
    DataExport_GUI();
catch
    handleError(lasterror);
end

function startUEpushbuttonCallback(source,event)
% source and event args are generated by default
try
    postMessage(''); % Clean up prior messages.
    if exist('startue.m','file')
        % it is there ?
        postMessage('Found Unitary Event Toolbox, starting...');
        splashscreen('create');
        startue;

    else
        postMessage('Unitary Event Toolbox files not found.');
        answer=questdlg(...
            'Unitary Events Toolbox files need to be added to the MATLAB search path - continue?',...
            'Add UE to path',...
            'Yes',...
            'Cancel',...
            'Yes'); %last is default
        if strcmp(answer,'Yes')
            path(path,'UnitaryEvents');
            postMessage('Found Unitary Event Toolbox, starting...');
            splashscreen('create');
            startue;
        end
        %disp('Unitary Event Toolbox not found - change your path Variablea ccordingly (addpath ...)');
        %error('Unitary Event Toolbox not found - change your path Variable accordingly (addpath ...)');
    end
catch
    handleError(lasterror);
end

function startStrfpushbuttonCallback(source,event)
% source and event args are generated by default

postMessage(''); % Clean up prior messages.
if exist('makeStrfGUI.m','file')
    % it is there ?
    postMessage('Found makeStrf Toolbox, starting...');
    makeStrfGUI;

else
    postMessage('makeStrf Toolbox files not found.');
    answer=questdlg(...
        'makeStrf Toolbox files need to be added to the MATLAB search path - continue?',...
        'Add makeStrf to path',...
        'Yes',...
        'Cancel',...
        'Yes'); %last is default
    if strcmp(answer,'Yes')
        addpath('receptiveFields');
        postMessage('Found makeStrf Toolbox, starting...');
        makeStrfGUI;
    end
end


%%%%%%%%%%%%%%% Auto Align Pushbutton callback

function autoAlignGUIpushbuttonCallback(source,event)
% Callback for the button that starts the tool's GUI.
% Source and event args are generated by default.
try
    postMessage('starting AutoAlign GUI'); % Clean up prior messages.
    %-% some checks maybe here?
    autoAlignGUI(); %-% usually no arguments should be necessary
catch
    handleError(lasterror);
end


%%%%%%%%%%%%%%% ParPoPro Pushbutton callback

function ParPoProGUIpushbuttonCallback(source,event)
% source and event args are generated by default
try
    postMessage(''); % Clean up prior messages.
    if exist('ParPoPro.m','file')
        postMessage('The ParPoPro Toolbox requires the Matlab Statistics_Toolbox for some functions! Found ParPoPro Toolbox, starting...');
        ParPoPro;
    else
        postMessage('ParPoPro Toolbox files not found.');
        answer=questdlg(...
            'Note: The ParPoPro Toolbox requires the Matlab Statistics_Toolbox for some functions! ParPoPro Toolbox files need to be added to the MATLAB search path - continue?',...
            'Add ParPoPro Toolbox to path',...
            'Yes',...
            'Cancel',...
            'Yes');
        if strcmp(answer,'Yes')
            path(path,'ParPoPro');
            path(path,'ParPoPro\Concatination');
            path(path,'ParPoPro\CorrelatedProcesses');
            path(path,'ParPoPro\Data');
            path(path,'ParPoPro\GUI');
            path(path,'ParPoPro\DataHandling');
            path(path,'ParPoPro\Display');
            path(path,'ParPoPro\SingleProcesses');
            postMessage('Found ParPoPro Toolbox, starting...');
            ParPoPro;
        end

    end
catch
    handleError(lasterror);
end


%%%%%%%%%%%%%%% CleanDataGUI Pushbutton callback

function CleanDataGUIpushbuttonCallback(source,event)
% source and event args are generated by default
try
    postMessage(''); % Clean up prior messages.
    postMessage('starting CleanData GUI'); % Clean up prior messages.
    CleanDataGUI(); %-% usually no arguments should be necessary
catch
    handleError(lasterror);
end


%%%%%%%%%%%%%%% PreProcessingGUI Pushbutton callback

function basicProcessingGUIpushbuttonCallback(source,event)
% source and event args are generated by default
try
    postMessage(''); % Clean up prior messages.
    postMessage('starting basic Processing GUI'); % Clean up prior messages.
    basicProcessingGUI(); %-% usually no arguments should be necessary
catch
    handleError(lasterror);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% GUI functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function deleteMain(source,event)
% if the main window is closed, close all other windows too
try
    close(findobj('Name','browseEntitiesGUI'));
    close(findobj('Name','Filter settings'));
    close(findobj('Name','CleanData GUI'));
    close(findobj('Name','Spike Detection GUI'));
    close(findobj('Name','Spikes Sorting GUI'));
    close(findobj('Name','basic Processing GUI'));
    close(findobj('Name','autoAlign GUI'));
    close(findobj('Name','Data Export GUI'));
    close(findobj('Name','Non linear interdependencies GUI'));
    close(findobj('Name','Gamma Process Simulation GUI'));
    close(findobj('Name','Import GDF GUI'));
catch
end


function resizeCallback(scr,evt)
%% Resizing panels as needed; the panels are
%% flexible as long as the window is larger than a minimal size.
%% For smaller sizes, the window contents are cropped.

global MAIN_MIN_WIDTH;
global MAIN_MIN_HEIGHT;

mainPos=get(gcbo,'Position');

%yOffset is used to align the panels with respect to the top of the window,
%not the bottom.
yOffset=min(0,mainPos(4)-MAIN_MIN_HEIGHT);

%for calculating the new panel positions the 'virtual' main position is
%set in such a way that the window contents are cropped if the window
%is too small
mainPos(3)=max(MAIN_MIN_WIDTH,mainPos(3));
mainPos(4)=max(MAIN_MIN_HEIGHT,mainPos(4));

%retrieving positions of panels
mainChildren=get(gcbo,'children');
topPanel=(findobj(mainChildren,'Tag','FIND_GUI_topPanel'));
leftPanel=(findobj(mainChildren,'Tag','FIND_GUI_leftPanel'));
rightPanel=(findobj(mainChildren,'Tag','FIND_GUI_rightPanel'));
bottomPanel=(findobj(mainChildren,'Tag','FIND_GUI_bottomPanel'));
messageBarPanel=(findobj(mainChildren,'Tag','FIND_GUI_messageBarPanel'));

topPanelpos=get(topPanel, 'Position');
leftPanelpos=get(leftPanel, 'Position');
rightPanelpos=get(rightPanel, 'Position');
bottomPanelpos=get(bottomPanel, 'Position');
messageBarPanelpos=get(messageBarPanel, 'Position');

%new panel positons
%bottom-, top- & messagepanel are fixed height and their positions can be
%computed from the main window's position
newTopPanelPos=[0    (mainPos(4)-topPanelpos(4)+yOffset) ...
    mainPos(3)   topPanelpos(4)];
newBottomPanelPos=[0 (yOffset+messageBarPanelpos(4)) ...
    mainPos(3) bottomPanelpos(4)];
newMessageBarPanelPos=[0 yOffset ...
    mainPos(3) messageBarPanelpos(4)];

%left and right panels' y positions depend on the others' updated positions
newLeftPanelPos=[0 ...
    (newTopPanelPos(2)-leftPanelpos(4))...
    leftPanelpos(3)...
    (leftPanelpos(4))];
newRightPanelPos=[leftPanelpos(3)...
    (newBottomPanelPos(2)+newBottomPanelPos(4))...
    (mainPos(3)-leftPanelpos(3))...
    (mainPos(4)-topPanelpos(4)-bottomPanelpos(4)-messageBarPanelpos(4))];

%setting new positions
set(topPanel,'Position',newTopPanelPos);
set(bottomPanel,'Position', newBottomPanelPos);
set(messageBarPanel,'Position', newMessageBarPanelPos);
set(leftPanel,'Position', newLeftPanelPos);
set(rightPanel,'Position', newRightPanelPos);
