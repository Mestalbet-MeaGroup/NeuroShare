% Script to initialize general FIND_GUI data. Is called from FIND_GUI.m.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


FIND_GUIdata.FINDpath=fileparts(which('FIND_GUI.m'));
% using fullfile to concatenate fillnames ensures proper directory
% separators are used on all platforms
FIND_GUIdata.DLLpath=fullfile(FIND_GUIdata.FINDpath,'');

if ispc
    FIND_GUIdata.KlustaExe=fullfile(FIND_GUIdata.FINDpath,'KlustaKwik', ...
        'KlustaKwik.exe');
else
    FIND_GUIdata.KlustaExe=fullfile(FIND_GUIdata.FINDpath,'KlustaKwik', ...
        'KlustaKwik');
end

FIND_GUIdata.filterSpecs={{'all'}};
FIND_GUIdata.displayOptions={'nsFile.EntityInfo.ItemCount', ...
    'nsFile.EntityInfo.EntityType','nsFile.EntityInfo.EntityID'};

% creating global variable nsFile in base workspace if it doesn't exist
% already.
nsFileVarInfo=evalin('base','whos(''nsFile'')');
if isempty(nsFileVarInfo)
    nsFileNotPresent=true;
    disp('FIND init: Creating global nsFile variable in base workspace.');
    evalin('base', 'global nsFile')
    % else: found nsFile, but is it global?
elseif nsFileVarInfo.global
    % nothing to do.
    nsFileNotPresent=false;
    disp('FIND init: Found global nsFile variable in base workspace. Using it.');
else
    error('Found non-global nsFile variable in base workspace - please either declare it global or remove it.');
end


if nsFileNotPresent
    %%%%%%%%%%%%%% DEFINE STRUCUTRE -->
    %%% generate an EMPTY NSFILE:

    % FILE INFO:
    nsFile.FileInfo.FileType=NaN;
    nsFile.FileInfo.EntityCount=NaN;
    nsFile.FileInfo.TimeStampResolution=NaN;
    nsFile.FileInfo.TimeSpan=NaN;
    nsFile.FileInfo.AppName=NaN;
    nsFile.FileInfo.Time_Year=NaN;
    nsFile.FileInfo.Time_Month=NaN;
    nsFile.FileInfo.Time_Day=NaN;
    nsFile.FileInfo.Time_Hour=NaN;
    nsFile.FileInfo.Time_Min=NaN;
    nsFile.FileInfo.Time_Sec=NaN;
    nsFile.FileInfo.Time_MilliSec=NaN;
    nsFile.FileInfo.FileComment=NaN;
    nsFile.FileInfo.Datatypespresent=[NaN NaN NaN NaN];


    % ANALOG Data and Info:

    nsFile.Analog.Data=[];
    nsFile.Analog.DataentityIDs=[];

    i=1;
    nsFile.Analog.Info(i).SampleRate=[];
    nsFile.Analog.Info(i).MinVal=[];
    nsFile.Analog.Info(i).MaxVal=[];
    nsFile.Analog.Info(i).Units=[];
    nsFile.Analog.Info(i).Resolution=[];
    nsFile.Analog.Info(i).LocationX=[];
    nsFile.Analog.Info(i).LocationY=[];
    nsFile.Analog.Info(i).LocationZ=[];
    nsFile.Analog.Info(i).LocationUser=[];
    nsFile.Analog.Info(i).HighFreqCorner=[];
    nsFile.Analog.Info(i).HighFreqOrder=[];
    nsFile.Analog.Info(i).HighFilterType=[];
    nsFile.Analog.Info(i).LowFreqCorner=[];
    nsFile.Analog.Info(i).LowFreqOrder=[];
    nsFile.Analog.Info(i).LowFilterType=[];
    nsFile.Analog.Info(i).ProbeInfo=[];
    nsFile.Analog.Info(i).EntityID=[];
    nsFile.Analog.Info(i).ItemCount=[];
    nsFile.Analog.Info(i).EntityLabel=[];

    % Events:
    nsFile.Event.TimeStamp{i}=[];
    nsFile.Event.Data{i}=[];
    nsFile.Event.DataSize{i}=[];
    nsFile.Event.EntityID=[];

    nsFile.Event.Info(i).EventType=[];
    nsFile.Event.Info(i).MinDataLength=[];
    nsFile.Event.Info(i).MaxDataLength=[];
    nsFile.Event.Info(i).CSVDesc=[];
    nsFile.Event.Info(i).EntityID=[];
    nsFile.Event.Info(i).ItemCount=[];
    nsFile.Event.Info(i).EntityLabel=[];

    % Neural stuff:
    nsFile.Neural.Data{i}=[];
    nsFile.Neural.EntityID=[];
     
    nsFile.Neural.Info(i).Label=[];
    nsFile.Neural.Info(i).Type=[];
    nsFile.Neural.Info(i).Count=[];
    nsFile.Neural.Info(i).EntityID=[];
    
    % Segment Stuff:

    nsFile.Segment.Data{i}=[];
    nsFile.Segment.TimeStamp{i}=[];
    nsFile.Segment.UnitID{i}=[];
    nsFile.Segment.SampleCount{i}=[];
    nsFile.Segment.DataentityIDs=[];

    
     % EntityInfo Stuff:
    
     nsFile.EntityInfo(i).EntityID=[];
     nsFile.EntityInfo(i).EntityLabel=('');
     nsFile.EntityInfo(i).EntityType=[];
     nsFile.EntityInfo(i).ItemCount=[];
          
    % end of nsFile Empty Strucutre
    
    clear i;
end

clear nsFileNotPresent;
clear nsFileVarInfo;