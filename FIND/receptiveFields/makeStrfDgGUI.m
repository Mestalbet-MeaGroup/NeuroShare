function makeStrfDgGUI()
% GUI for calculating the tuning curve to drifting gratings.
%
% 
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
    if ishandle(findobj('tag', 'makeStrfDgGUI'))
        close(findobj('tag', 'makeStrfDgGUI'));
    end;

    % GUI window
    GUIxPos=80;
    GUIyPos=40;
    GUIwidth=150;
    GUIheight=22;


    leftPanelHeight=18;
    leftPanelWidth=GUIwidth/3;
    messageBarPanelWidth=GUIwidth-MESSAGEBAR_LEFT_OFFSET-MESSAGEBAR_RIGHT_OFFSET;
    topPanelHeight=GUIheight-leftPanelHeight-MESSAGEBAR_PANEL_HEIGHT;

    GUIwindow=figure('Units','characters',...
        'Position',[GUIxPos GUIyPos GUIwidth GUIheight], ...
        'Tag','makeStrfDgGUI', ...
        'Name','receptive field calculation with drifting gratings GUI',...
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
        'Tag','makeStrfDgGUI_centralPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);

    messageBarPanel=uipanel('Parent',GUIwindow,...
        'Units','characters',...
        'Position',[0 0 ...
        GUIwidth MESSAGEBAR_PANEL_HEIGHT],...
        'Tag','makeStrfDgGUI_messageBarPanel');

    topPanel=uipanel('Parent',mainWindow,...
        'Units','characters',...
        'Position',[0 leftPanelHeight...
        GUIwidth topPanelHeight],...
        'Tag','makeStrfGwnGUI_topPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);
   
    leftPanel=uipanel('Parent',mainWindow,...
        'Units','characters',...
        'Position',[0 0, ...
        leftPanelWidth leftPanelHeight],...
        'Tag','makeStrfDgGUI_leftPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);

       
    centralPanel=uipanel('Parent',mainWindow,...
        'Units','characters',...
        'Position',[leftPanelWidth 0,...
        leftPanelWidth leftPanelHeight],...
        'Tag','makeStrfDgGUI_leftPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);
    
        rightPanel=uipanel('Parent',mainWindow,...
        'Units','characters',...
        'Position',[2*leftPanelWidth 0,...
        leftPanelWidth leftPanelHeight],...
        'Tag','makeStrfDgGUI_rightPanel',...
        'BackgroundColor', [0.8 0.8 0.8]);


   %%%%%%%message%%%%%%%%%%%%
    uicontrol('Parent',topPanel,...
        'Units','normalized',...
        'Position',[ 0.1  0.2  0.8  0.6 ],...
        'Style','text',...
        'String','for more information read the tutorial on www.find.bcc.uni-freiburg.de',...
        'Tag', 'makeStrfGwnGUI_workLabelText',...
        'Enable','on');
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get the data sets for stimulus and response respectively %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% 1)the stimulus
    % text label
    
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.15    0.92    0.7    0.07],...
        'Style','text',...
        'String','edit stimulus information',...
        'Tag','makeStrfDgGUI_InfoLabelText',...
        'Enable','on');
    
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.1    0.85    0.8    0.06],...
        'Style','text',...
        'String','select stimulus from workspace',...
        'Tag','makeStrfDgGUI_selectedEntityLabelText',...
        'Enable','on');
   
    h_listbox=uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.25  0.5  0.5  0.33],...
        'Style','ListBox',...
        'String', evalin('base','who'),...
        'Tag','makeStrfDgGUI_stimulusSelectListBox',...
        'Enable','on');
        
    
    %%% edit refresh rate of stimulus
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.55    0.4    0.4    0.07],...
        'Style','text',...
        'String','base duration [sec]',...
        'Tag','makeStrfDgGUI_selectedRateLabelText',...
        'Enable','on');
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.6   0.32   0.3  0.07],...
        'Style','edit',...
        'String','[1]',...
        'Tag','makeStrfDgGUI_selectedBaseDuration',...
        'Enable','on');
  
    %%%%%%%%%determine trial duration
   uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.01  0.4  0.4   0.07],...
        'Style','text',...
        'String','trial duration [sec]',...
        'Tag','makeStrfDgGUI_selectedTrialsDurationLabelText',...
        'Enable','on');
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.1    0.32   0.25  0.07],...
        'Style','edit',...
        'String','[20]',...
        'Tag','makeStrfDgGUI_selectedTrialDuration',...
        'Enable','on'); 
     %%%%%%%%%determine base duration
   uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.25  0.24   0.42   0.07],...
        'Style','text',...
        'String','frame duration [sec]',...
        'Tag','makeStrfDgGUI_selectedFrameDurationLabelText',...
        'Enable','on');
    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.4    0.15   0.2  0.07],...
        'Style','edit',...
        'String','[0.013]',...
        'Tag','makeStrfDgGUI_selectedFrameDuration',... 
                'Enable','on'); 
   
    
    %%%%% 2)the response
    uicontrol('Parent',centralPanel,...
        'Units','normalized',...
        'Position',[0.15    0.92    0.7   0.07],...
        'Style','text',...
        'String','edit response information',...
        'Tag','makeStrfDgGUI_InfoLabelText',...
        'Enable','on');
      %edit event entity
      uicontrol('Parent',centralPanel,...
        'Units','normalized',...
        'Position',[0.05    0.75    0.4  0.07],...
        'Style','text',...
        'String','event [entityID]',...
        'Tag','makeStrfDgGUI_selectedEventEntityLabelText',...
        'Enable','on');
    uicontrol('Parent',centralPanel,...
        'Units','normalized',...
        'Position',[0.2    0.67    0.2  0.08],...
        'Style','edit',...
        'String','[]',...
        'Tag','makeStrfDgGUI_selectedEventEntity',...
        'Enable','on');

    
  uicontrol('Parent',centralPanel,...
        'Units','normalized',...
        'Position',[0.5	   0.75    0.45   0.07],...
        'Style','text',...
        'String','response [entityIDs]',...
        'Tag','makeStrfDgGUI_selectedResponseEntitiesLabelText',...
        'Enable','on');
    uicontrol('Parent',centralPanel,...
        'Units','normalized',...
        'Position',[0.65    0.67    0.2  0.08],...
        'Style','edit',...
        'String','[]',...
        'Tag','makeStrfDgGUI_selectedResponseEntities',...
        'Enable','on');

 
  %%%%%%%% Radio buttons for selecting the modulation of the grating %%%%%%%

    buttonGroup = uibuttongroup('Visible','off',...
        'Units','normalized',...
        'Position',[0.25  0.5 0.5 0.15],...
        'Parent',centralPanel,...
        'Tag','makeStrfDgGUI_modulationButtongroup',...
        'Title','modulation' );


    uicontrol('Style','Radio',...
        'String','sf',...
        'Units','normalized',...
        'Position',[0.01 0.1 0.32 1],...
        'Parent',buttonGroup,...
        'Tag','makeStrfDgGUI_sfRadiobutton',...
        'HandleVisibility','on');
    uicontrol('Style','Radio',...
        'String','tf',...
        'Enable','on',...
        'Units','normalized',...
        'pos',[0.33 0.1 0.32 1],...
        'Parent',buttonGroup,...
        'Tag','makeStrfDgGUI_tfradiobutton',...
        'HandleVisibility','on');
    oriButton=uicontrol('Style','Radio',...
        'String','ori',...
        'Enable','on',...
        'Units','normalized',...
        'pos',[0.65 0.1 0.32 1],...
        'Parent',buttonGroup,...
        'Tag','makeStrfDgGUI_oriradiobutton',...
        'HandleVisibility','on');
    set(buttonGroup,'SelectedObject',oriButton);  % Select one Default
    set(buttonGroup,'Visible','on');
    
    %%%%%%%%get angles or frequencies%%%%%%%%%%%%
     uicontrol('Parent',centralPanel,...
        'Units','normalized',...
        'Position',[0.2    0.43    0.6    0.06],...
        'Style','text',...
        'String','edit modulated parameters',...
        'Tag','makeStrfDgGUI_selectedParametersLabelText',...
        'Enable','on');
    uicontrol('Parent',centralPanel,...
        'Units','normalized',...
        'Position',[0.15   0.33  0.7  0.08],...
        'Style','edit',...
        'String','[0 45 90 135 180 215 260 305]',...
        'Tag','makeStrfDgGUI_selectedParameters',...
        'Enable','on');

    
    %determine evaluation trial
    uicontrol('Parent',centralPanel,...
        'Units','normalized',...
        'Position',[0.05   0.2    0.9   0.07],...
        'Style','text',...
        'String','[no.] of trials for each condition',...
        'Tag','makeStrfDgGUI_selectedTrialsLabelText',...
        'Enable','on');
    uicontrol('Parent',centralPanel,...
        'Units','normalized',...
        'Position',[0.4    0.1   0.2  0.09],...
        'Style','edit',...
        'String','[10]',...
        'Tag','makeStrfDgGUI_selectedEstimationTrials',...
        'Enable','on');
%% Buttons
    uicontrol('Parent',rightPanel,...
        'Units','normalized',...
        'Position',[0.15    0.92    0.7   0.07],...
        'Style','text',...
        'String','functions',...
        'Tag','makeStrfDgGUI_InfoLabelText',...
        'Enable','on');
   
     %%%%%%button to align trials from response to trial onsets of%%%%%%%%%
            % event data
    uicontrol('Parent',rightPanel,...
        'Units','normalized',...
        'Position',[0.25    0.8    0.5  0.1],... 
        'Style','pushbutton',...
        'String','plot PSTH and raster',...
        'Tag','makeStrfDgGUI_processResponsePushbutton',...
        'Enable','on',...
        'Callback',@processResponsePushbuttonCallback);

  
    %%%%%% button to determine statistics %%%%%%%%
    uicontrol('Parent',rightPanel,...
        'Units','normalized',...
        'Position',[0.15    0.05    0.70  0.1],... 
        'Style','pushbutton',...
        'String','statistics of spike train',...
        'Tag','makeStrfDgGUI_StatisticsPushbutton',...
        'Enable','on',...
        'Callback',@determineStatisticsPushbuttonCallback); 

    uicontrol('Parent',leftPanel,...
        'Units','normalized',...
        'Position',[0.1    0.01    0.8  0.08],... 
        'Style','pushbutton',...
        'String','extract trial onsets by black frames',...
        'Tag','makeStrfDgGUI_extractOnsetsPushbutton',...
        'Enable','on',...
        'Callback',@extractOnsetsPushbuttonCallback); 
    uicontrol('Parent',rightPanel,...
        'Units','normalized',...
        'Position',[0.2    0.53  0.6  0.1],... 
        'Style','pushbutton',...
        'String','construct own spike train',...
        'Tag','makeStrfDgGUI_constructSTPushbutton',...
        'Enable','off',...
        'Callback',@constructSTPushbuttonCallback); 
  
   uicontrol('Parent',rightPanel,...
        'Units','normalized',...
        'Position',[0.2    0.67  0.6  0.1],... 
        'Style','pushbutton',...
        'String','calculate tuning curve',...
        'Tag','makeStrfDgGUI_constructSTPushbutton',...
        'Enable','on',...
        'Callback',@calculateTuningPushbuttonCallback); 
     
    %%%%%% button to determine information measures %%%%%%%%
    uicontrol('Parent',rightPanel,...
        'Units','normalized',...
        'Position',[0.2    0.22    0.60  0.1],... 
        'Style','pushbutton',...
        'String','information measures',...
        'Tag','makeStrfDgGUI_InfoPushbutton',...
        'Enable','on',...
        'Callback',@determineInfoPushbuttonCallback); 
    
        %%%%%% button to determine coherence between linear prediction and response %%%%%%%%
    uicontrol('Parent',rightPanel,...
        'Units','normalized',...
        'Position',[0.1    0.38    0.8  0.1],... 
        'Style','pushbutton',...
        'String','coherence predictor vs. response',...
        'Tag','makeStrfDgGUI_CoherencePushbutton',...
        'Enable','on',...
        'Callback',@determineCoherencePushbuttonCallback); 

        

catch
    %if error occurs here, the window is closed, the error is rethrown
    %    and then catched by the main window
    close(findobj('tag', ',makeStrfDgGUI'));
    rethrow(lasterror);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 %%%% FUNCTIONS %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function calculateTuningPushbuttonCallback(a,b)
global tuningVector
tempTrial=findobj('Tag','makeStrfDgGUI_selectedTrialDuration');
trialDuration=str2num(get(tempTrial(1),'String'));
tempBase=findobj('Tag','makeStrfDgGUI_selectedBaseDuration');
baseDuration=str2num(get(tempBase(1),'String'));
tempParameters=findobj('Tag','makeStrfDgGUI_selectedParameters');
selectedParameters=str2num(get(tempParameters(1),'String'));
tempResponse=findobj('Tag','makeStrfDgGUI_selectedResponseEntities');
selectedResponse=str2num(get(tempResponse(1),'String'));
global PSTH tuningVector
tuningVector=calculateTuning('stimulus',selectedParameters,'response',PSTH,'responseEntities',selectedResponse,'trialDuration',trialDuration,'baseDuration',baseDuration);
display('done calculation tuning curve');




function processResponsePushbuttonCallback(a,b)
global linearizedStimulus nsFiles idx PSTH
selectedResponse=str2num(get(findobj('Tag','makeStrfDgGUI_selectedResponseEntities'),'String'));
selectedEvent=str2num(get(findobj('Tag','makeStrfDgGUI_selectedEventEntity'),'String'));
estimationTrials=str2num(get(findobj('Tag','makeStrfDgGUI_selectedEstimationTrials'),'String'));
refreshRate=str2num(get(findobj('Tag','makeStrfDgGUI_selectedFrameDuration'),'String'));
trialDuration=str2num(get(findobj('Tag','makeStrfDgGUI_selectedTrialDuration'),'String'));
baseDuration=str2num(get(findobj('Tag','makeStrfDgGUI_selectedBaseDuration'),'String'));
[idx,PSTH]=processResponse('responseEntities',selectedResponse,'eventEntity',selectedEvent, 'trialDuration',trialDuration,'trials',estimationTrials,'baseDuration',baseDuration);
disp('done plotting data');


function extractOnsetsPushbuttonCallback(a,b)
selectedEvent=str2num(get(findobj('Tag','makeStrfDgGUI_selectedEventEntity'),'String'));
trigger=extractOnsets('analogEntityIndices',selectedEvent)




function determineStatisticsPushbuttonCallback(a,b)
global type preferredOri nsFile
selectedResponse=str2num(get(findobj('Tag','makeStrfDgGUI_selectedResponseEntities'),'String'));
for ii=1:length(selectedResponse)
for nn=1:length(unique(nsFile.Segment.UnitID{nsFile.Neural.EntityID==selectedResponse(ii)}))
    preferredOri{ii}(nn)=find(tuningVector==max(tuningVector));
end
end
type='Dg';
makeStrfCodingGUI;

function determineInfoPushbuttonCallback(a,b)
global preferredOri type nsFile
selectedResponse=str2num(get(findobj('Tag','makeStrfDgGUI_selectedResponseEntities'),'String'));
for ii=1:length(selectedResponse)
for nn=1:length(unique(nsFile.Segment.Data{nsFile.Neural.EntityID==selectedResponse(ii)}))
    preferredOri{ii}(nn)=find(tuningVector==max(tuningVector));
end
end
type='Dg';
makeStrfInfoGUI;

function determineCoherencePushbuttonCallback(a,b)
global preferredOri type linearPred
selectedResponse=str2num(get(findobj('Tag','makeStrfDgGUI_selectedResponseEntities'),'String'));
for ii=1:length(selectedResponse)
for nn=1:length(unique(nsFile.Segment.Data{nsFile.Neural.EntityID==selectedResponse(ii)}))
    preferredOri{ii}(nn)=find(tuningVector==max(tuningVector));
end
end
type='Dg';
makeStrfCohGUI;

