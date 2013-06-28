function varargout = ParPoPro(varargin)
% PARPOPRO M-file for ParPoPro.fig
%      PARPOPRO, by itself, creates a new PARPOPRO or raises the existing
%      singleton*.
%
%      H = PARPOPRO returns the handle to a new PARPOPRO or the handle to
%      the existing singleton*.
%
%      PARPOPRO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARPOPRO.M with the given input arguments.
%
%      PARPOPRO('Property','Value',...) creates a new PARPOPRO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ParPoPro_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ParPoPro_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
%
%
% Version 1.2
% HISTORY: 14/02/06 - allow one PoissonData-Script only !!!
%          27/02/06 - renamed ppgui_GenerateData to pp_GenerateData
%          13/04/07 - added a new panel for Single Interaction Process and
%                     2 new buttons to toggle between independent point
%                     process and SIP -- JB
% Benjamin Staude, (staude@neurobiologie.fu-berlin.de)
% Last Modified by GUIDE v2.5 04-Apr-2008 16:27:03
%
%
% Browse button issue under Linux:
%   If a browse button opens a dialog box but is unable to select a certain
%   file by displaying the error message "File does not exist", the user
%   has to execute the command "unset LANG" in the shell prompt before 
%   launching MATLAB. Certainly the alternatives could be to put this 
%   command to the MATLAB startup script or e.g. the .bashrc file. For 
%   details, please consult:
%
%   http://www.mathworks.com/support/solutions/data/1-VD2UO.html
%
% -- Jie Bao, Apr 12 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;  
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ParPoPro_OpeningFcn, ...
                   'gui_OutputFcn',  @ParPoPro_OutputFcn, ...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before ParPoPro is made visible.
function ParPoPro_OpeningFcn(hObject, eventdata, handles, varargin)
%% Apply startup settings %%
WorkingDirectory=pwd;
set(handles.WorkingDirectory,'String', WorkingDirectory);
set(handles.RateValue,'Enable','on');
set(handles.RateValue,'Value',1);
set(handles.RateValue,'Enable','inactive');
set(handles.RateFile,'Value',0); 
set(handles.RateFileName,'Enable','off');
set(handles.BrowseRateFile,'Enable','off');
handles.output = hObject;
guidata(hObject, handles)

% --- Outputs from this function are returned to the command line.
function varargout = ParPoPro_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           %
% Directory And File Names  %
%                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function WorkingDirectory_Callback(hObject, eventdata, handles)
function WorkingDirectory_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on button press in BrowseWorkingDirectory.
function BrowseWorkingDirectory_Callback(hObject, eventdata, handles)
WorkingDirectory = uigetdir(pwd);
if WorkingDirectory~=0
    set(handles.WorkingDirectory,'String',WorkingDirectory);
    cd(get(handles.WorkingDirectory,'String'));
end


%%% ChooseWorkingDirectory.
function ChooseWorkingDirectory_Callback(hObject, eventdata, handles)
cd(get(handles.WorkingDirectory,'String'));


%%% ChooseParameterFile.
function ChooseParameterFile_Callback(hObject, eventdata, handles)
[LoadParameterFileName,pathname,Index]=uigetfile('*.mat','Select Parameter File');
if Index~=0
    set(handles.LoadParameterFileName,'String',LoadParameterFileName);
    load([pathname LoadParameterFileName]);
    ppgui_Setup_FillParameter(handles,...
        SingleProcessStats,...
        TrialParameters,...
        DisplayParameters,...
        DirectoryAndFileNames);
end

function LoadParameterFileName_Callback(hObject, eventdata, handles)
function LoadParameterFileName_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- LoadParameterFile.
function LoadParameterFile_Callback(hObject, eventdata, handles)
if isempty(get(handles.LoadParameterFileName,'String'))
    error('No file specified !!!')
else
    LoadParameterFileName=get(handles.LoadParameterFileName,'String');
    load([LoadParameterFileName]);
    ppgui_Setup_FillParameter(handles,SingleProcessStats,TrialParameters,DisplayParameters,DirectoryAndFileNames);
end

%%% Save Parameter File Name  %%%
function SaveParameterFile_Callback(hObject, eventdata, handles)
SaveParameterFileName=get(handles.SaveParameterFileName,'String');
CurrentDirectory=pwd;
[SingleProcessStats,TrialParameters,DisplayParameters,DirectoryAndFileNames]=ppgui_UpdateParameterValues(handles);
[ErrorCount,WarningCount,TrialParameters]=...
    ppgui_CheckParameterCompatibilities(SingleProcessStats,TrialParameters,DisplayParameters,handles);
save([CurrentDirectory '/' SaveParameterFileName '.mat'], 'SingleProcessStats','TrialParameters','DisplayParameters','DirectoryAndFileNames','-mat');
 
function SaveParameterFileName_Callback(hObject, eventdata, handles)
function SaveParameterFileName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           %
%   Single Process Panel    %
%                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Process Type %%
function ProcessType_Callback(hObject, eventdata, handles)
switch get(handles.ProcessType,'Value');
    case 1
        set(handles.Order_txt,'Enable','off');
        set(handles.Order,'Enable','off');
        set(handles.GammaType,'Enable','off');
        set(handles.RateValue,'Value',1);
        set(handles.RateValue,'Enable','on');
        set(handles.Rate,'Enable','on');
        set(handles.RateFile,'Enable','on');
        set(handles.RateFile,'Value',0);
        set(handles.RateUnit,'Enable','on');
        set(handles.RateFileName,'Enable','off');
        set(handles.BrowseRateFile,'Enable','off');
    case 2
        set(handles.RateFile,'Value',1);
        set(handles.RateFileName,'Enable','on');
        set(handles.BrowseRateFile,'Enable','on');
        set(handles.RateValue,'Value',0);
        set(handles.RateValue,'Enable','off');
        set(handles.RateFile,'Enable','inactive');
        set(handles.Rate,'Enable','off');
        set(handles.RateUnit,'Enable','off');
        set(handles.Order_txt,'Enable','off');
        set(handles.Order,'Enable','off');
        set(handles.GammaType,'Enable','off');
    case 3
        set(handles.RateValue,'Enable','on');
        set(handles.RateValue,'Value',1);
        set(handles.RateValue,'Enable','inactive');
        set(handles.Rate,'Enable','on');
        set(handles.RateUnit,'Enable','on');
        set(handles.RateFile,'Value',0);
        set(handles.RateFile,'Enable','on');
        set(handles.RateFileName,'Enable','off');
        set(handles.BrowseRateFile,'Enable','off');
        set(handles.Order_txt,'Enable','on');
        set(handles.Order,'Enable','on');
        set(handles.GammaType,'Enable','on');
end
function ProcessType_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Rate %%
    function Rate_Callback(hObject, eventdata, handles)
    set(handles.RateValue,'Enable','on');
    set(handles.RateValue,'Value',1);
    set(handles.RateValue,'Enable','inactive');
    set(handles.RateFile,'Value',0);
    set(handles.RateFileName,'Enable','off');
    set(handles.BrowseRateFile,'Enable','off');


    function Rate_CreateFcn(hObject, eventdata, handles)
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function RateValue_Callback(hObject, eventdata, handles)
switch get(handles.RateValue,'Value')
    case 1
        set(handles.RateFile,'Value',0)
        set(handles.Rate,'Enable','on');
        set(handles.RateUnit,'Enable','on');
        set(handles.RateFileName,'Enable','off')
        set(handles.BrowseRateFile,'Enable','off');
        set(handles.RateValue,'Enable','inactive')
        set(handles.RateFile,'Enable','on')
end

function RateFile_Callback(hObject, eventdata, handles)
% USAGE: The dimensions of the Rate File 9Rate) determines the type of process
% (stationary or unstationary) to simulate. The columns of Rate determine the 
% rate of the processes, while the rows determine the rate over time: 
%       If the Rate file is a number, the processes are all
%               stationary with the same rate. 
%       If size(Rate File)=[1,NumberOfChannels], the processes
%               are stationary, with the k-th process havig rate Rate(k). 
%       If size(Rate File)=[Ts*1000,1], the processes are non-stationary with a
%               rate-profile given by Rate in ms-Resolution in Units of Hz.
%       If size(Rate File)=[Ts*1000,NumberOfChannels], the processes are
%               non-stationary with the k-th process having the rate profile
%               Rate(:,k) (ms-Resolution in Units of Hz).
switch get(handles.RateValue,'Value')
    case 1
        set(handles.RateValue,'Value',0)
        set(handles.Rate,'Enable','off');
        set(handles.RateUnit,'Enable','off');
        set(handles.RateFileName,'Enable','on');
        set(handles.BrowseRateFile,'Enable','on');
        set(handles.RateFile,'Enable','inactive');
        set(handles.RateValue,'Enable','on')
end
% --- Executes during object creation, after setting all properties.
function RateFileName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in BrowseRateFile.
function BrowseRateFile_Callback(hObject, eventdata, handles)
[filename,pathname,Index]=uigetfile('*.dat','Select Rate File','Location',[250 250]);
if Index~=0
    set(handles.RateFileName,'String',[pathname  filename]);
end




%% ORDER %%
function Order_Callback(hObject, eventdata, handles)
function Order_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% GammaType %%
function GammaType_Callback(hObject, eventdata, handles)
function GammaType_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% UnitMs %%
function UnitMs_Callback(hObject, eventdata, handles)
function UnitMs_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% PrecisionMs %%
function PrecisionMs_Callback(hObject, eventdata, handles)
function PrecisionMs_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Clipping %%
function Clipping_Callback(hObject, eventdata, handles)
function Clipping_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           %
%   Trial     Panel         %
%                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% NumberOFProcesses %%
function NumberOfProcesses_Callback(hObject, eventdata, handles)
function NumberOfProcesses_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% NumberOfTrials %%
function NumberOfTrials_Callback(hObject, eventdata, handles)
function NumberOfTrials_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% TrialDuration %%
function TrialDuration_Callback(hObject, eventdata, handles)
function TrialDuration_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% TrialDurationUnit %%
function TrialDurationUnit_Callback(hObject, eventdata, handles)
function TrialDurationUnit_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% TrialOffset %%
function TrialOffset_Callback(hObject, eventdata, handles)
function TrialOffset_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% TrialOffsetUnit %%
function TrialOffsetUnit_Callback(hObject, eventdata, handles)
function TrialOffsetUnit_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Marker_Callback(hObject, eventdata, handles)
function Marker_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StartOfExperiment_Callback(hObject, eventdata, handles)
function StartOfExperiment_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StartOfExperimentUnit_Callback(hObject, eventdata, handles)
function StartOfExperimentUnit_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           %
%   Display   Panel         %
%                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on selection change in DisplayChannels.
function DisplayChannels_Callback(hObject, eventdata, handles)
switch get(handles.DisplayChannels,'Value')
    case 1
        set(handles.ISIProcess_txt,'String','Process Id')
        set(handles.CountProcess_txt,'String','Process Id')
        set(handles.CountProcess_txt,'String','Process Id')
        set(handles.PopulationHistogram,'String','Population histogram (of first trial) in')
        set(handles.ComplexityDistribution,'String','Complexity distribution (of first trial)')
    case 2
        set(handles.ISIProcess_txt,'String','Trial Id')
        set(handles.CountProcess_txt,'String','Trial Id')
        set(handles.PopulationHistogram,'String','PSTH (of first process) in')
        set(handles.ComplexityDistribution,'String','Complexity distribution (of first process) in')
end
function DisplayChannels_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on button press in DotDisplay.
function DotDisplay_Callback(hObject, eventdata, handles)
switch get(handles.DotDisplay,'Value');
     case 1
        set(handles.DotMarkerStyle_txt,'Enable','on');
        set(handles.DotMarkerStyle,'Enable','on');
    case 0
        set(handles.DotMarkerStyle_txt,'Enable','off');
        set(handles.DotMarkerStyle,'Enable','off');
end

function DotMarkerStyle_Callback(hObject, eventdata, handles)
function DotMarkerStyle_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%%%%%%%%%%%%%    ISI     %%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in ISI.
function ISI_Callback(hObject, eventdata, handles)
switch get(handles.ISI,'Value')
    case 0
        set(handles.ISIProcess_txt,'Enable','off');
        set(handles.ISIFirstProcess,'Enable','off');
        set(handles.ISIto_txt,'Enable','off');
        set(handles.ISILastProcess,'Enable','off');
        set(handles.ISIBinSizeMs,'Enable','off');
        set(handles.ISIBinSize_txt,'Enable','off');
        set(handles.ISIBinSizeUnit_txt,'Enable','off');
        set(handles.ISIUnit,'Enable','off');
        set(handles.ISIUnit_txt,'Enable','off');
    case 1
        set(handles.ISIProcess_txt,'Enable','on');
        set(handles.ISIFirstProcess,'Enable','on');
        set(handles.ISIto_txt,'Enable','on');
        set(handles.ISILastProcess,'Enable','on');
        set(handles.ISIBinSize_txt,'Enable','on');
        set(handles.ISIBinSizeMs,'Enable','on');
        set(handles.ISIBinSizeUnit_txt,'Enable','on');
        set(handles.ISIUnit,'Enable','on');
        set(handles.ISIUnit_txt,'Enable','on');
end
function ISIFirstProcess_Callback(hObject, eventdata, handles)
function ISIFirstProcess_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ISILastProcess_Callback(hObject, eventdata, handles)
function ISILastProcess_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ISIBinSizeMs_Callback(hObject, eventdata, handles)
function ISIBinSizeMs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%%%%%%%%%  COUNT STATISTICS  %%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in CountStatistics.
function CountStatistics_Callback(hObject, eventdata, handles)
switch get(handles.CountStatistics,'Value');
    case 1
        set(handles.CountDistributions,'Enable','on');
        set(handles.CountBinSize_txt,'Enable','on');
        set(handles.CountBinSize,'Enable','on');
        set(handles.CountBinSizeUnit,'Enable','on');
        set(handles.PopulationHistogram,'Enable','on');
        set(handles.ComplexityDistribution,'Enable','on');
        %set(handles.PSTHUnit,'Enable','off');
        if get(handles.CountDistributions,'Value')
            set(handles.CountProcess_txt,'Enable','on');
            set(handles.CountFirstProcess,'Enable','on');
            set(handles.Countto_txt,'Enable','on');
            set(handles.CountLastProcess,'Enable','on');
        end
        if get(handles.PopulationHistogram,'Value')
            set(handles.PSTHUnit,'Enable','on');
        else
            set(handles.PSTHUnit,'Enable','off');
        end
        if get(handles.ComplexityDistribution,'Value')
            set(handles.ComplDistrUnit,'Enable','on');
        else
            set(handles.ComplDistrUnit,'Enable','off');
        end
    case 0
        set(handles.CountDistributions,'Enable','off');
        set(handles.CountBinSize_txt,'Enable','off');
        set(handles.CountBinSize,'Enable','off');
        set(handles.CountBinSizeUnit,'Enable','off');
        set(handles.CountProcess_txt,'Enable','off');
        set(handles.CountFirstProcess,'Enable','off');
        set(handles.Countto_txt,'Enable','off');
        set(handles.CountLastProcess,'Enable','off');
        set(handles.PopulationHistogram,'Enable','off');
        set(handles.PSTHUnit,'Enable','off');
        set(handles.ComplexityDistribution,'Enable','off');
        set(handles.ComplDistrUnit,'Enable','off');
end

function CountBinSize_Callback(hObject, eventdata, handles)
function CountBinSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CountBinSizeUnit.
function CountBinSizeUnit_Callback(hObject, eventdata, handles)
function CountBinSizeUnit_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CountDistributions.
function CountDistributions_Callback(hObject, eventdata, handles)
switch get(handles.CountDistributions,'Value')
    case 0
        set(handles.CountProcess_txt,'Enable','off');
        set(handles.CountFirstProcess,'Enable','off');
        set(handles.Countto_txt,'Enable','off');
        set(handles.CountLastProcess,'Enable','off');
    case 1
        set(handles.CountProcess_txt,'Enable','on');
        set(handles.CountFirstProcess,'Enable','on');
        set(handles.Countto_txt,'Enable','on');
        set(handles.CountLastProcess,'Enable','on');
end


function CountLastProcess_Callback(hObject, eventdata, handles)
function CountLastProcess_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function CountFirstProcess_Callback(hObject, eventdata, handles)
function CountFirstProcess_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PopulationHistogram.
function PopulationHistogram_Callback(hObject, eventdata, handles)
switch get(handles.PopulationHistogram,'Value')
    case 0
        set(handles.PSTHUnit,'Enable','off');
    case 1
        set(handles.PSTHUnit,'Enable','on');
end
% --- Executes on button press in ComplexityDistribution.
function ComplexityDistribution_Callback(hObject, eventdata, handles)
switch get(handles.ComplexityDistribution,'Value')
    case 0
        set(handles.ComplDistrUnit,'Enable','off');
    case 1
        set(handles.ComplDistrUnit,'Enable','on');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           %
% Simulate / Display Code   %
%                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%  Simulate  %%%
function Simulate_Callback(hObject, eventdata, handles)
    
[SingleProcessStats,TrialParameters,DisplayParameters,...
    DirectoryAndFileNames,CorrelatedProcessStats]=...
    ppgui_UpdateParameterValues(handles);

[ErrorCount,WarningCount,TrialParameters]=...
    ppgui_CheckParameterCompatibilities(SingleProcessStats,...
    CorrelatedProcessStats,TrialParameters,DisplayParameters,handles);

if ErrorCount==0
    Data=pp_GenerateData(SingleProcessStats,CorrelatedProcessStats,...
        TrialParameters);
    ppgui_Display(Data,DisplayParameters);
    %% Possibly Save %%
    if get(handles.SaveAfterSimulation,'Value')
        SaveDataName=get(handles.SaveDataName,'String');
        if isempty(SaveDataName)
            ppgui_ErrorWarnings('Name of data file not specified !!!');
            return
        else
            %
            %Check format to save
            %
            ReverseSaveName=SaveDataName(length(SaveDataName):-1:1);
            FullFileName=[DirectoryAndFileNames.WorkingDirectory '\' SaveDataName];
            if strncmp(ReverseSaveName,'tam.',4)
                Data.DirectoryAndFileNames=DirectoryAndFileNames;
                if ~handles.simulationSaved
                    save([FullFileName],'Data','-mat');
                else
                    save(SaveDataName,'Data','-mat');
                end
            elseif strncmp(ReverseSaveName,'fdg.',4)
                if ~handles.simulationSaved
                    save(FullFileName,'-struct','Data', 'gdf','-ascii');
                else
                    save(SaveDataName,'-struct','Data', 'gdf','-ascii');
                end
            else
                ppgui_ErrorWarnings(['Unknown ending of data file. I saved to ' SaveDataName '.mat !']);
                Data.DirectoryAndFileNames=DirectoryAndFileNames;
                if ~handles.simulationSaved
                    save([FullFileName '.mat'],'Data','-mat');
                else
                    save([SaveDataName '.mat'],'Data','-mat');
                end
            end
        end
    elseif  get(handles.importFIND,'Value')
        SaveDataName=get(handles.SaveDataName,'String');
        if isempty(SaveDataName)
            ppgui_ErrorWarnings('Name of data file not specified !!!');
            return
        else
            if exist(SaveDataName)==2;
                existingFile=questdlg('There is a file with an identical name on your MATLAB searchpath.',...
                    'Do you want to overwrite it?', ...
                    'overwrite','cancel','cancel');
                switch existingFile
                    case 'cancel'
                        return;
                end
            end
            ReverseSaveName=SaveDataName(length(SaveDataName):-1:1);
            if ~isfield(handles ,'simulationSaved')
                FullFileName=[DirectoryAndFileNames.WorkingDirectory '\' SaveDataName];
            else
                FullFileName=SaveDataName;
            end
            if strncmp(ReverseSaveName,'fdg.',4)
                global nsFile;
                loadMode='prompt';
                previousData=false;
                postMessage('Busy - please wait...');
                if ~isempty(nsFile.Analog.DataentityIDs)
                    previousData=true;
                    tempAnalogDataentityIDs=nsFile.Analog.DataentityIDs;
                end
                EntityID=setdiff(unique(Data.gdf(:,1)),Data.TrialParameters.Marker);
                if Data.TrialParameters.NumberOfTrials~=length(find(Data.gdf(:,1)==Data.TrialParameters.Marker))&& ...
                        Data.TrialParameters.NumberOfTrials~=1
                    ppgui_ErrorWarnings('ERROR while importin Data into FIND');
                    return
                end
                if Data.TrialParameters.NumberOfProcesses~=length(EntityID)
                    ppgui_ErrorWarnings('ERROR while importin Data into FIND');
                    return
                end

                save(FullFileName,'-struct','Data', 'gdf','-ascii');
                % import into FIND as gdf data
                txt_array=importGDF('fileName',[FullFileName]);
                % results in a nsFile.EntityInfo(i).EntityLabel='imported_GDF_Data'!!!
                txt_array=strvcat(txt_array,' ',['GDF data imported by using ', mfilename]);
                disp(txt_array);
                postMessage('...done.');
            else
                ppgui_ErrorWarnings('Unknown ending of data file.');
                return
            end
        end
    end
end

% --- Executes on button press in DisplayCode.
    function DisplayCode_Callback(hObject, eventdata, handles)
        ppgui_CodeDisplay(handles);


% --- Executes on button press in SaveAfterSimulation.
function SaveAfterSimulation_Callback(hObject, eventdata, handles)

% --- Executes on button press in SaveAfterSimulation.
function SaveDataName_Callback(hObject, eventdata, handles)
function SaveDataName_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in importFIND.
function importFIND_Callback(hObject, eventdata, handles)

% --- Executes on button press in SaveSimulation.
function SaveSimulation_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname,Index]=uiputfile({'*.mat';'*.gdf'},...
    'Save simulation as...','Location',[250 250]);
if Index~=0
    set(handles.SaveDataName,'String',[pathname  filename]);
    handles.simulationSaved = true;
end
guidata(hObject, handles); 



% --- Executes on selection change in PSTHUnit.
function PSTHUnit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function PSTHUnit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ISIUnit.
function ISIUnit_Callback(hObject, eventdata, handles)
% hObject    handle to ISIUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ISIUnit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ISIUnit


% --- Executes during object creation, after setting all properties.
function ISIUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ISIUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PSTHUnit.
function PopHistUnit_Callback(hObject, eventdata, handles)
% hObject    handle to PSTHUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PSTHUnit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PSTHUnit


% --- Executes during object creation, after setting all properties.
function PopHistUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSTHUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ComplDistrUnit.
function ComplDistrUnit_Callback(hObject, eventdata, handles)
% hObject    handle to ComplDistrUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ComplDistrUnit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ComplDistrUnit


% --- Executes during object creation, after setting all properties.
function ComplDistrUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ComplDistrUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               %
%   Correlated Process Panel    %
%                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Rate2_Callback(hObject, eventdata, handles)
% hObject    handle to Rate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rate2 as text
%        str2double(get(hObject,'String')) returns contents of Rate2 as a double
set(handles.RateValue2,'Enable','on');
set(handles.RateValue2,'Value',1);
set(handles.RateValue2,'Enable','inactive');
set(handles.RateFile2,'Value',0);
set(handles.RateFileName2,'Enable','off');
set(handles.BrowseRateFile2,'Enable','off');


% --- Executes during object creation, after setting all properties.
function Rate2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CorrelationCoefficient_Callback(hObject, eventdata, handles)
% hObject    handle to CorrelationCoefficient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CorrelationCoefficient as text
%        str2double(get(hObject,'String')) returns contents of CorrelationCoefficient as a double


% --- Executes during object creation, after setting all properties.
function CorrelationCoefficient_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CorrelationCoefficient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RateFileName2_Callback(hObject, eventdata, handles)
% hObject    handle to RateFileName2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RateFileName2 as text
%        str2double(get(hObject,'String')) returns contents of RateFileName2 as a double


% --- Executes during object creation, after setting all properties.
function RateFileName2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RateFileName2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseRateFile2.
function BrowseRateFile2_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseRateFile2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname,Index]=uigetfile('*.dat','Select Rate File');
if Index~=0
    set(handles.RateFileName2,'String',[pathname  filename]);
end


% --- Executes on button press in RateValue2.
function RateValue2_Callback(hObject, eventdata, handles)
% hObject    handle to RateValue2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RateValue2
switch get(handles.RateValue2,'Value')
    case 1
        set(handles.RateFile2,'Value',0)
        set(handles.Rate2,'Enable','on');
        set(handles.RateUnit,'Enable','on');
        set(handles.RateFileName2,'Enable','off')
        set(handles.BrowseRateFile2,'Enable','off');
        set(handles.RateValue2,'Enable','inactive')
        set(handles.RateFile2,'Enable','on')
end


% --- Executes on button press in RateFile2.
function RateFile2_Callback(hObject, eventdata, handles)
% hObject    handle to RateFile2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RateFile2
switch get(handles.RateValue2,'Value')
    case 1
        set(handles.RateValue2,'Value',0)
        set(handles.Rate2,'Enable','off');
        set(handles.RateUnit,'Enable','off');
        set(handles.RateFileName2,'Enable','on');
        set(handles.BrowseRateFile2,'Enable','on');
        set(handles.RateFile2,'Enable','inactive');
        set(handles.RateValue2,'Enable','on')
end


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                              %
%   Toggle between single and correlated process simulation    %
%                                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in SelectSingleProcess.
function SelectSingleProcess_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSingleProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectSingleProcess
if get(handles.SelectSingleProcess,'Value') ~= 0
    set(handles.RateValue2,'Enable','off');
    set(handles.RateFile2,'Enable','off');
    set(handles.RateFileName2,'Enable','off');
    set(handles.BrowseRateFile2,'Enable','off');

    set(handles.RateValue,'Enable','on');
    set(handles.ProcessType,'Enable','on');
    set(handles.RateFile,'Enable','on');
    set(handles.RateFileName,'Enable','on');
    set(handles.BrowseRateFile,'Enable','on');
end

set(handles.SelectCorrelatedProcess,'Value',0);


% --- Executes on button press in SelectCorrelatedProcess.
function SelectCorrelatedProcess_Callback(hObject, eventdata, handles)
% hObject    handle to SelectCorrelatedProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectCorrelatedProcess
if get(handles.SelectCorrelatedProcess,'Value') ~= 0
    set(handles.RateValue,'Enable','off');
    set(handles.ProcessType,'Enable','off');
    set(handles.RateFile,'Enable','off');
    set(handles.RateFileName,'Enable','off');
    set(handles.BrowseRateFile,'Enable','off');

    set(handles.RateValue2,'Enable','on');
    set(handles.RateFile2,'Enable','on');
    set(handles.RateFileName2,'Enable','on');
    set(handles.BrowseRateFile2,'Enable','on');
end

set(handles.SelectSingleProcess,'Value',0);





