function makeStrfLFPGUI()
% GUI for calculating the spatiotemporal receptive field.
%
% here a couple of parameters and methods can be chosen
% used as UI to parameter value pair generation for the
% command line function sortSpikes.m
%
% H. Walz Feb 2008
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


global nsFile;

global BUTTON_HEIGHT;
global BUTTON_WIDTH;
global LABEL_HEIGHT;
global MESSAGEBAR_PANEL_HEIGHT;
global MESSAGEBAR_LEFT_OFFSET;
global MESSAGEBAR_RIGHT_OFFSET;

% the global ones are needed within the
% resize function
global MAIN_MIN_WIDTH;
global MAIN_MIN_HEIGHT;

try

    % Check if the makeStrfSpikes GUI is already open
    if ishandle(findobj('tag', 'makeStrfLFPGUI'))
        close(findobj('tag', 'makeStrfLFPGUI'));
    end;

    % GUI window
    GUIxPos=80;
    GUIyPos=40;
    GUIwidth=120;
    GUIheight=25;


    leftPanelHeight=13;
    leftPanelWidth=GUIwidth/2;
    bottomPanelHeight=5;
    messageBarPanelWidth=GUIwidth-MESSAGEBAR_LEFT_OFFSET-MESSAGEBAR_RIGHT_OFFSET;
    topPanelHeight=GUIheight-bottomPanelHeight-leftPanelHeight-MESSAGEBAR_PANEL_HEIGHT;

    GUIwindow=figure('Units','characters',...
        'Position',[GUIxPos GUIyPos GUIwidth GUIheight], ...
        'Tag','makeStrfLFPGUI', ...
        'Name','processing lfp data',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'resize','off');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%% panels %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %size parameters see above main window initialization
    mainWindow=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 MESSAGEBAR_PANEL_HEIGHT ...
        GUIwidth (GUIheight-MESSAGEBAR_PANEL_HEIGHT)],...
        'Tag','makeStrfLFPGUI_centralPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);

    messageBarPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 0 ...
        GUIwidth MESSAGEBAR_PANEL_HEIGHT],...
        'Tag','makeStrfLFPGUI_messageBarPanel');


   
    leftPanel=uipanel('Parent',mainWindow,...
        'Units','characters',...
        'Position',[0 ...
        (bottomPanelHeight+MESSAGEBAR_PANEL_HEIGHT)...
        leftPanelWidth leftPanelHeight],...
        'Tag','makeStrfLFPGUI_leftPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);

        rightPanel=uipanel('Parent',mainWindow,...
        'Units','characters',...
        'Position',[leftPanelWidth ...
        (bottomPanelHeight+MESSAGEBAR_PANEL_HEIGHT)...
        leftPanelWidth leftPanelHeight],...
        'Tag','makeStrfLFPGUI_rightPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);
 
    bottomPanel=uipanel('Parent',mainWindow,...
        'Units','characters',...
        'Position',[0 MESSAGEBAR_PANEL_HEIGHT ...
        GUIwidth bottomPanelHeight],...
        'Tag','makeStrfLFPGUI_bottomPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);

    %%%%handles
    
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.25    0.92    0.5    0.07],...
        'Style','text',...
        'String','select event entity',...
        'Tag','makeStrfLFPGUI_selectedEventEntityLabelText',...
        'Enable','on');
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.25 0.8  0.5  0.1],...
        'Style','edit',...
        'String','[]',...
        'Tag','makeStrfLFPGUI_selectedEventEntity',...
        'Enable','on');
    uicontrol('Parent',rightPanel,...
        'Units','normalized',...
        'Position',[0.25    0.92    0.5    0.07],...
        'Style','text',...
        'String','select response entity',...
        'Tag','makeStrfLFPGUI_selectedResponseEntityLabelText',...
        'Enable','on');
    uicontrol('Parent',rightPanel,...
        'Units','normalized',...
        'Position',[0.25 0.8  0.5  0.1],...
        'Style','edit',...
        'String','[]',...
        'Tag','makeStrfLFPGUI_selectedResponseEntity',...
        'Enable','on');

    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.25 0.71  0.5  0.07],...
        'Style','text',...
        'String','edit trial duration',...
        'Tag','makeStrfLFPGUI_selectedTrialLengthText',...
        'Enable','on');
 
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.25 0.6  0.5  0.1],...
        'Style','edit',...
        'String','[]',...
        'Tag','makeStrfLFPGUI_selectedTrialLength',...
        'Enable','on');
    
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.25 0.51  0.5  0.07],...
        'Style','text',...
        'String','edit base duration',...
        'Tag','makeStrfLFPGUI_selectedBaseLengthText',...
        'Enable','on');
 
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.25 0.4  0.5  0.1],...
        'Style','edit',...
        'String','[]',...
        'Tag','makeStrfLFPGUI_selectedBaseLength',...
        'Enable','on');
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.25 0.31  0.5  0.07],...
        'Style','text',...
        'String','trials',...
        'Tag','makeStrfLFPGUI_sameTrialsText',...
        'Enable','on');
 
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.25 0.2  0.5  0.1],...
        'Style','edit',...
        'String','[]',...
        'Tag','makeStrfLFPGUI_sameTrials',...
        'Enable','on');
    
    %%%buttons
      uicontrol('Parent',rightPanel,...
        'Units','normalized',...
        'Position',[0.25    0.1    0.5    0.1],...
        'Style','pushbutton',...
        'String','align z-scores',...
        'Tag','makeStrfLFPGUI_alignzscoresPushbutton',...
        'Enable','on',...
        'Callback',@alignZscoresPushbuttonCallback);
catch
    close(findobj('tag', ',makeStrfLFPGUI'));
    rethrow(lasterror);
end
    
    %%%%FUNCTIONS%%%%%%%%%%
 
 function alignZscoresPushbuttonCallback(a,b)
 selectedEvent=str2num(get(findobj('Tag','makeStrfLFPGUI_selectedEventEntity'),'String'));
 selectedResponse=str2num(get(findobj('Tag','makeStrfLFPGUI_selectedResponseEntity'),'String'));
 trialDuration=str2num(get(findobj('Tag','makeStrfLFPGUI_selectedTrialLength'),'String'));
 baseDuration=str2num(get(findobj('Tag','makeStrfLFPGUI_selectedBaseLength'),'String'));
 sameTrials=str2num(get(findobj('Tag','makeStrfLFPGUI_sameTrials'),'String'));

 global LFP meanLFP
 [LFP,meanLFP]=makeStrfLFP('eventEntity',selectedEvent,'responseEntities',selectedResponse, 'trialDuration', trialDuration,'sameTrials',sameTrials, 'baseDuration',baseDuration);
