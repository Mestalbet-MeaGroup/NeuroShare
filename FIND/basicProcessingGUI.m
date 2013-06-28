function basicProcessingGUI(varargin)
% function basicProcessingGUI(varargin)
% GUI initialization of the basicProcessingGUI.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
% (1.1) A. Kilias 10/08


global nsFile;

global BUTTON_HEIGHT;
global LABEL_HEIGHT;
global MESSAGEBAR_PANEL_HEIGHT;
global MESSAGEBAR_LEFT_OFFSET;
global MESSAGEBAR_RIGHT_OFFSET;

obligatoryArgs={}; %-% e.g. {'x','y'}

% optional arguments names with default values
optionalArgs={'selected_Process'};

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,'missing or wrong input arguments');
end
% set defaults
selected_Process='rasterPlot';

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

try
    % Check if the GUI is already open
    if ishandle(findobj('tag', 'basicProcessingGUI'))
        close(findobj('tag', 'basicProcessingGUI'));
    end;
    % GUI window
    GUIxPos=20;
    GUIyPos=20;
    GUIwidth=120;
    GUIheight=30;

    GUIwindow=figure('Units','characters',...
        'Position',[GUIxPos GUIyPos GUIwidth GUIheight], ...
        'Tag','basicProcessingGUI', ...
        'Name','basic Processing GUI',...
        'MenuBar','none',...
        'NumberTitle','off',...
        'resize','off');

    % panels
    leftPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 MESSAGEBAR_PANEL_HEIGHT ...
        GUIwidth/3 (GUIheight-MESSAGEBAR_PANEL_HEIGHT)],...
        'Tag','basicProcessingGUI_leftPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);

    rightPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[GUIwidth/3 MESSAGEBAR_PANEL_HEIGHT ...
        GUIwidth*2/3 (GUIheight-MESSAGEBAR_PANEL_HEIGHT)],...
        'Tag','basicProcessingGUI_rightPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);

    messageBarPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 0 ...
        GUIwidth-0.1 MESSAGEBAR_PANEL_HEIGHT],...
        'Tag','basicProcessingGUI_messageBarPanel');

    % message bar
    messageBarPanelPos=get(messageBarPanel,'Position');
    uicontrol('Parent',messageBarPanel,...
        'Units','characters',...
        'Position',[(messageBarPanelPos(1)+MESSAGEBAR_LEFT_OFFSET) ...
        (messageBarPanelPos(2)) ...
        (messageBarPanelPos(3)-MESSAGEBAR_RIGHT_OFFSET) ...
        LABEL_HEIGHT],...
        'Tag','basicProcessingGUI_messageBarText',...
        'Enable','on',...
        'String','',...
        'HorizontalAlignment','left',...
        'Style','text');

    % -----------------------------------------------------------
    %%%% process Selection Radio Group
    radioGroup = uibuttongroup('visible','off',...
        'Units','characters',...
        'Position',[0 0 GUIwidth*(1/3)-0.8 GUIheight-MESSAGEBAR_PANEL_HEIGHT-0.6],...
        'Parent',leftPanel,...
        'Tag','processSelectionGUI_radioGroup',...
        'Title','processing options');

    radioButtonRaster = uicontrol('Style','Radio',...
        'String','rasterPlot',...
        'Units','characters',...
        'pos',[1 24.5 20 BUTTON_HEIGHT],...
        'parent',radioGroup,...
        'HandleVisibility','off',...
        'Enable','on',...
        'Tag','processSelectionGUI_radioButtonRaster');

    radioButtonPSTH = uicontrol('Style','Radio',...
        'String','PSTH',...
        'Units','characters',...
        'pos',[1 23 20 BUTTON_HEIGHT],...
        'parent',radioGroup,...
        'HandleVisibility','off',...
        'Enable','on',...
        'Tag','processSelectionGUI_radioButtonPSTH');

    radioButtonJPSTH = uicontrol('Style','Radio',...
        'String','JPSTH',...
        'Units','characters',...
        'pos',[1 21.5 20 BUTTON_HEIGHT],...
        'parent',radioGroup,...
        'HandleVisibility','off',...
        'Enable','off',...
        'Tag','processSelectionGUI_radioButtonJPSTH');

    radioButtonFilter = uicontrol('Style','Radio',...
        'String','filtering',...
        'Units','characters',...
        'pos',[1 20 20 BUTTON_HEIGHT],...
        'parent',radioGroup,...
        'HandleVisibility','off',...
        'Enable','off',...
        'Tag','processSelectionGUI_radioButtonFilter');

    radioButtonCorr = uicontrol('Style','Radio',...
        'String','Correlation',...
        'Units','characters',...
        'pos',[1 18.5 20 BUTTON_HEIGHT],...
        'parent',radioGroup,...
        'HandleVisibility','off',...
        'Enable','off',...
        'Tag','processSelectionGUI_radioButtonCorr');

    radioButtonCoher = uicontrol('Style','Radio',...
        'String','Coherence',...
        'Units','characters',...
        'pos',[1 17 20 BUTTON_HEIGHT],...
        'parent',radioGroup,...
        'HandleVisibility','off',...
        'Enable','off',...
        'Tag','processSelectionGUI_radioButtonCoher');

    radioButtonFFT = uicontrol('Style','Radio',...
        'String','FFT',...
        'Units','characters',...
        'pos',[1 15.5 20 BUTTON_HEIGHT],...
        'parent',radioGroup,...
        'HandleVisibility','off',...
        'Enable','off',...
        'Tag','processSelectionGUI_radioButtonFFT');

    radioButtonPCA = uicontrol('Style','Radio',...
        'String','PCA',...
        'Units','characters',...
        'pos',[1 14 20 BUTTON_HEIGHT],...
        'parent',radioGroup,...
        'HandleVisibility','off',...
        'Enable','off',...
        'Tag','processSelectionGUI_radioButtonPCA');

    radioButtonICA = uicontrol('Style','Radio',...
        'String','ICA',...
        'Units','characters',...
        'pos',[1 12.5 20 BUTTON_HEIGHT],...
        'parent',radioGroup,...
        'HandleVisibility','off',...
        'Enable','off',...
        'Tag','processSelectionGUI_radioButtonICA');

    radioButtonICA = uicontrol('Style','Radio',...
        'String','ICA',...
        'Units','characters',...
        'pos',[1 12.5 20 BUTTON_HEIGHT],...
        'parent',radioGroup,...
        'HandleVisibility','off',...
        'Enable','off',...
        'Tag','processSelectionGUI_radioButtonICA');

    set(radioGroup,'SelectionChangeFcn',@selectProcess_callback);
    set(radioGroup,'Visible','on');

    switch selected_Process
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % %%%%%%%%%%%%% rasterPlot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'rasterPlot'
            rasterPlotGUI;

            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % %%%%%%%%%%%%% PSTH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'PSTH'
            PSTH_GUI;

            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % %%%%%%%%%%%%% JPSTH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'JPSTH'
            set(radioGroup,'SelectedObject',[radioButtonJPSTH]);
            set(radioGroup,'UserData','JPSTH');
            uicontrol('Parent',rightPanel,...
                'Units','characters',...
                'Position',[10 8 50 LABEL_HEIGHT],...
                'Style','text',...
                'String','JPSTH not implemented yet',...
                'Tag','notImplnow1',...
                'Enable','on');

            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % %%%%%%%%%%%%% Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'filtering'
            set(radioGroup,'SelectedObject',[radioButtonFilter]);  % Select one Default
            set(radioGroup,'UserData','filtering'); % also set the userdata default
            uicontrol('Parent',rightPanel,...
                'Units','characters',...
                'Position',[10 8 50 LABEL_HEIGHT],...
                'Style','text',...
                'String','filtering not implemented yet',...
                'Tag','notImplnow2',...
                'Enable','on');

            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % %%%%%%%%%%%%% Correlation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'Correlation'
            set(radioGroup,'SelectedObject',[radioButtonCorr]);  % Select one Default
            set(radioGroup,'UserData','Correlation'); % also set the userdata default
            uicontrol('Parent',rightPanel,...
                'Units','characters',...
                'Position',[10 8 50 LABEL_HEIGHT],...
                'Style','text',...
                'String','correlation calculation not implemented yet',...
                'Tag','notImplnow3',...
                'Enable','on');

            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % %%%%%%%%%%%%% Coherence %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'Coherence'
            set(radioGroup,'SelectedObject',[radioButtonCoher]);  % Select one Default
            set(radioGroup,'UserData','Coherence'); % also set the userdata default
            uicontrol('Parent',rightPanel,...
                'Units','characters',...
                'Position',[10 8 50 LABEL_HEIGHT],...
                'Style','text',...
                'String','coherence calculation not implemented yet',...
                'Tag','notImplnow4',...
                'Enable','on');

            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % %%%%%%%%%%%%% FFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'FFT'
            set(radioGroup,'SelectedObject',[radioButtonFFT]);
            set(radioGroup,'UserData','FFT');
            uicontrol('Parent',rightPanel,...
                'Units','characters',...
                'Position',[10 8 50 LABEL_HEIGHT],...
                'Style','text',...
                'String','FFT not implemented yet',...
                'Tag','notImplnow5',...
                'Enable','on');

            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % %%%%%%%%%%%%% PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'PCA'
            set(radioGroup,'SelectedObject',[radioButtonPCA]);
            set(radioGroup,'UserData','PCA');
            uicontrol('Parent',rightPanel,...
                'Units','characters',...
                'Position',[10 8 50 LABEL_HEIGHT],...
                'Style','text',...
                'String','PCA not implemented yet',...
                'Tag','notImplnow6',...
                'Enable','on');

            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % %%%%%%%%%%%%% ICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'ICA'
            set(radioGroup,'SelectedObject',[radioButtonICA]);
            set(radioGroup,'UserData','ICA');
            uicontrol('Parent',rightPanel,...
                'Units','characters',...
                'Position',[10 8 50 LABEL_HEIGHT],...
                'Style','text',...
                'String','ICA not implemented yet',...
                'Tag','notImplnow7',...
                'Enable','on');
    end
catch
    close(findobj('tag', 'basicProcessingGUI'));
    rethrow(lasterror);
end


% ------------- Callbacks --------------------

function selectProcess_callback(source,eventdata)

% Get the Value from the Radio Button-Group
temp=get(get(source,'SelectedObject'),'String');
tmp=findobj('Tag','processSelectionGUI_radioGroup');
set(tmp,'UserData',temp);
selected_Process=get(tmp(1),'UserData');
basicProcessingGUI('selected_Process',selected_Process);
postMessage([selected_Process, ' selected ']);


function selectNorm_callback(source,eventdata)

% Get the Value from the Radio Button-Group2
temp=get(get(source,'SelectedObject'),'String');
tmp=findobj('Tag','normSelectionGUI_radioGroup2');
set(tmp,'UserData',temp);
selected_Norm=get(tmp(1),'UserData');


function selectKernel_callback(source,eventdata)

% Get the Value from the Radio Button-Group3
temp=get(get(source,'SelectedObject'),'String');
tmp=findobj('Tag','kernelSelectionGUI_radioGroup3');
set(tmp,'UserData',temp);
selected_Kerneltotal=get(tmp(1),'UserData');

% ------------- RasterPlot --------------------
function rasterPlot_Callback(source,eventdata)
try
    postMessage('Busy - please wait...');

    % grab the variables
    temp1=findobj('Tag','dataID_edit');
    userString = get(temp1(1),'string');
    dataID=str2num(char(userString));

    temp2=findobj('Tag','eventID_edit');
    userString = get(temp2(1),'string');
    eventID=str2num(char(userString));


    temp3=findobj('Tag','preTrig_Edit');
    userString = get(temp3(1),'string');
    preTrigger=str2num(char(userString));

    temp4=findobj('Tag','postTrig_Edit');
    userString = get(temp4(1),'string');
    postTrigger=str2num(char(userString));

    rasterPlot('neuronID',dataID,'eventID',eventID,...
        'preTrigger',preTrigger,'postTrigger',postTrigger);
    postMessage('...done.');
catch
    handleError(lasterror);
end


% -------------  PSTH --------------------
function PSTH_Callback(source,eventdata)
try
     postMessage('Busy - please wait...');
     
    % grab the variables
    temp1=findobj('Tag','dataID_edit');
    userString = get(temp1(1),'string');
    dataID=str2num(char(userString));

    temp2=findobj('Tag','eventID_edit');
    userString = get(temp2(1),'string');
    eventID=str2num(char(userString));

    temp3=findobj('Tag','triggerNr_edit');
    userString = get(temp3(1),'string');
    triggerNr=str2num((userString));
       
    temp4=findobj('Tag','preTrig_Edit');
    userString = get(temp4(1),'string');
    preTrigger=str2num(char(userString));

    temp5=findobj('Tag','postTrig_Edit');
    userString = get(temp5(1),'string');
    postTrigger=str2num(char(userString));
    
    
    tmpNorm=findobj('Tag','normSelectionGUI_radioGroup2');
    selected_Norm=get(tmpNorm(1),'UserData');

    tmpKernS=findobj('Tag','KernelSize_Edit');
    userString = get(tmpKernS(1),'String');
    KernelSize=str2num(char(userString));

    tmpKernel=findobj('Tag','kernelSelectionGUI_radioGroup3');
    selected_Kerneltotal=get(tmpKernel(1),'UserData');
    selected_Kernel=selected_Kerneltotal(1:3);

    %         cell2mat(textscan(descInfo.Gain,'%n'))

    if length(selected_Kerneltotal)>3
        tempStr=textscan(selected_Kerneltotal,'%s');
        selected_Direct=str2num(tempStr{1}{2});

        plotPSTH('neuronID',dataID,'eventID',eventID,...
            'KernelSize',KernelSize,'selectedNorm',selected_Norm,...
            'selectedKernel',selected_Kernel,'selectedDirect',selected_Direct,...
            'postTrigger',postTrigger,'preTrigger',preTrigger,'triggerNR',triggerNr);
    else
        plotPSTH('neuronID',dataID,'eventID',eventID,...
            'KernelSize',KernelSize,'selectedNorm',selected_Norm,...
            'selectedKernel',selected_Kernel,...
            'postTrigger',postTrigger,'preTrigger',preTrigger,'triggerNR',triggerNr);
    end

    postMessage('...done.');
catch
    handleError(lasterror);
end
