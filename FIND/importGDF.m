function txt_array=importGDF(varargin)
% Import spike data in GDF files to global variable nsFile.
%
% Obligatory arguments:
% 'fileName' : <STRING> of the file to be loaded
%
% Optional arguments: 
% 
% 'newNeuralEntityIDs': set EntityID for each source
%
% 'newEventEntityID': set EntityID to assign the trigger
% 
% 'loadMode': This argument controls what to do with previously loaded data
% when new data of the same type is loaded to the nsFile variable.
% Possible values:
%   'prompt' - this is the default setting. The user will be prompted about
%   whether the new data should be appended or the old data be overwritten.
%   With the next two options this behaviour can be set directly.
%
%   'append' - new data is automatically appended to the existing data.
%   This may require zero padding and in consequence additional memory. See
%   the argument 'zeroPadding' below, which controls the behaviour in this
%   case.
%
%   'overwrite' - overwrites existing data of the same type in nsFile.
%
% Example of usage:
% importGDF('fileName','mydata.gdf');
%
% Creates a Variable nsFile with defined structure.
% Should be identical to Data loaded from Vendors or
% created by simulateGamma(GUI).m
%
% major modifications kilias 04/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;

% obligatory argument names
obligatoryArgs={{'fileName', @(arg) ischar(arg)}};

% optional arguments names with default values
optionalArgs={'newNeuralEntityIDs','newEventEntityID','loadMode'};

% default parameters
loadMode='prompt';
newNeuralEntityIDs=[];
newEventEntityID=[];

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end
pvpmod(varargin);


%%%%%%%%%%%%%%%%%% load data %%%%%%%%%%%%%%%%%%

GDF_data=load(fileName);
% check which column contains sources and which contains data
if length(find(diff(unique(GDF_data(:,1)))>1))>1
    m=2; % marker in column 2
    d=1;
else
    m=1;
    d=2; % data in column 2
end


%%%%%%%%%%%%%%%%%% extract sources %%%%%%%%%%%%%%%%%%

% getting markers for each trial
% assume each file starts with a new trial, starts with a trialMarker
uniMarkers=unique(GDF_data(:,m));
trialMarkers=(find(GDF_data(:,m)==GDF_data(1,m)))';
nTrials=(length(trialMarkers));

%getting markers for each source
sourceIDmarkers=unique(GDF_data(:,m));
sourceIDmarkers=setdiff(sourceIDmarkers,GDF_data(1,m));
nSourceIDmarkers=length(sourceIDmarkers); % number of different sources/neurons

%%%%%%%%%%%%%%%%%% push into newdata structure %%%%%%%%%%%%%%%%%%

%%%% Data (extract data in order to the referring trial and source)
for iSource=1:nSourceIDmarkers
    newdata.Neural.Data{iSource}=GDF_data(find(GDF_data(:,m)==sourceIDmarkers(iSource)),d);
    NeuralDataOrigin{iSource}=['TrialMarkers_of_imported_GDF_file for Source ', num2str(sourceIDmarkers(iSource))];
end
% get the trigger (marker time points)
newdata.Event.TimeStamp{1}=GDF_data(trialMarkers,d);


%%%%%%%%%%%%%%%%%%%%%%%%%% store event data %%%%%%%%%%%%%%%%%%%%%%%%%%
% set new independent ID
if ~isempty(newEventEntityID)&& ~ismember(newEventEntityID,[nsFile.EntityInfo.EntityID])&&...
        ~ismember(newEventEntityID,[nsFile.Segment.DataentityIDs])&&...
        ~ismember(newEventEntityID,[nsFile.Neural.EntityID])&&...
        ~ismember(newEventEntityID,[nsFile.Event.EntityID])&&...
        ~ismember(newEventEntityID,[nsFile.Analog.DataentityIDs])
    newdata.Event.EntityID=newEventEntityID;
else
    newdata.Event.EntityID=max([nsFile.Segment.DataentityIDs,nsFile.Event.EntityID,nsFile.Analog.DataentityIDs,...
        nsFile.Neural.EntityID,[nsFile.EntityInfo.EntityID]])+1;
    disp(['no Event EntityID declared or double assined IDs - new event EntityID:', num2str(newdata.Event.EntityID)]);
end
% set Info
EventDataOrigin{1}='imported_GDF_Trigger';
%store
store_ns_neweventdata('newdata',newdata,'DataOrigin',EventDataOrigin);


%%%%%%%%%%%%%%%%%%%%%%%%%% store neural data %%%%%%%%%%%%%%%%%%%%%%%%%%
% set ID
if ~isempty(newNeuralEntityIDs) && ~ismember(newNeuralEntityIDs,[nsFile.EntityInfo.EntityID])&&...
        ~ismember(newNeuralEntityIDs,[nsFile.Segment.DataentityIDs])&&...
        ~ismember(newNeuralEntityIDs,[nsFile.Neural.EntityID])&&...
        ~ismember(newNeuralEntityIDs,[nsFile.Event.EntityID])&&...
        ~ismember(newNeuralEntityIDs,[nsFile.Analog.DataentityIDs])
    newdata.Neural.EntityID=newNeuralEntityIDs;
else
    newdata.Neural.EntityID=max([nsFile.Segment.DataentityIDs,nsFile.Event.EntityID,nsFile.Analog.DataentityIDs,...
        nsFile.Neural.EntityID,[nsFile.EntityInfo.EntityID]])+[1:nSourceIDmarkers];
    disp(['no Neural EntityID declared or double assined IDs - new neural EntityID:', num2str(newdata.Neural.EntityID)]);
end
% store
[usedIDs]=store_ns_newneuraldata('newdata',newdata,'DataOrigin',NeuralDataOrigin);

%%%% clean up
clear newdata;

% generate some Report
txt_array='Report: Data Import';
txt_array=strvcat(txt_array,' ');
txt_array=strvcat(txt_array,'filename:');
txt_array=strvcat(txt_array,fileName);
txt_array=strvcat(txt_array,' ');
txt_array=strvcat(txt_array,['# Sources: ', num2str(nSourceIDmarkers),'; # Trials: ',num2str(nTrials)]);
txt_array=strvcat(txt_array,'(TrialMarkers stored in nsFile.Event.TimeStamp)');


% ---> Here, the data is "moved" out of the GUI workspace...
evalin('base','global nsFile');  % shows the global variable in the base workspace


