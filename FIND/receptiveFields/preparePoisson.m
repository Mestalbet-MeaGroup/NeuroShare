function simSpikes=preparePoisson(varargin)
%  calls the function pp_PoissonData from parpopro after preparing the
%  variables
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% rateFcn: a vector of spiking probability per frame
% frameDuration: in msec
%    
% %%%%% Optional Parameters %%%%%%
%   
% nTrials: how many trials should be simulated
%           default 10;
%
%
%
%
% Henriette Walz 03/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%



% obligatory argument names
obligatoryArgs={'rate','frameDuration'};  

% optional arguments names with default values
optionalArgs={'nTrials'};
nTrials=10;


% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

global nsFile

rateMS=zeros(frameDuration*1000*length(rate),1);
i=0;
for k=1:50:length(rate)+1
    i=i+1;
    rateMS(k:k+49)=rate(i);
end

totDuration=length(rateMS)/1000;
try
    if exist('pp_PoissonData.m','file')
        % it is there ?
        disp('simulating poisson process');
    else
        postMessage('ParPoPro not found...');
        answer=questdlg(...
            'ParPoPro Toolbox files need to be added to the MATLAB search path - continue?',...
            'Add ParPoPro to path',...
            'Yes',...
            'Cancel',...
            'Yes'); %last is default
        if strcmp(answer,'Yes')
            path(path,'ParPoPro');
              path(path,'ParPoPro\Concatination');
              path(path,'ParPoPro\CorrelatedProcesses');
              path(path,'ParPoPro\Data');
              path(path,'ParPoPro\GUI');
              path(path,'ParPoPro\DataHandling');
              path(path,'ParPoPro\Display');
              path(path,'ParPoPro\SingleProcesses');
            postMessage('Found ParPoPro, simulating Poisson Process.');
        end
    end
catch
    handleError(lasterror);
end

simSpikes=pp_PoissonData(nTrials,rateMS,totDuration);

%% create one long data trace with different trials starting at times in nsFile.Event 
trials=unique(simSpikes(:,1));
onset=1;
if ~isempty(nsFile.Neural.EntityID)
    c=length(nsFile.Neural.EntityID)+1;
    entityID=max(nsFile.Neural.EntityID)+1;
    nsFile.Neural.EntityID=[nsFile.Neural.EntityID,entityID];
    nsFile.Analog.DataentityIDs=[nsFile.Analog.DataentityIDs,entityID];
else
    c=1;
    nsFile.Neural.EntityID=1;
    nsFile.Analog.DataentityIDs=1;
end
nsFile.Neural.Data{c}=[];
% store all the trigger in the same ID as the neural data
newPos=size(nsFile.Event.TimeStamp,2);
if ~isempty(nsFile.Event.TimeStamp{1})
    newPos=newPos+1;
end
for t=1:length(trials)
    nsFile.Neural.Data{c}=[nsFile.Neural.Data{c};simSpikes(find(simSpikes(:,1)==trials(t)),2)+onset];
    nsFile.Event.TimeStamp{newPos}=[nsFile.Event.TimeStamp{newPos};onset];
    onset = onset+totDuration+1;
    nsFile.Event.DataSize{newPos}=size(nsFile.Event.TimeStamp{newPos});
end

%%%%assigning lots of nsFile things
%Events
if isfield(nsFile.Analog.Info,'SampleRate') & ~isempty(nsFile.Analog.Info(1).SampleRate)
nsFile.Event.Data{newPos}=nsFile.Event.TimeStamp{newPos}*nsFile.Analog.Info(1).SampleRate;
else
    nsFile.Event.Data{newPos}=nsFile.Event.TimeStamp{newPos}*1000;
end
nsFile.Segment.TimeStamp{1}=nsFile.Neural.Data{1};
disp('done creating one long trial with poisson spiking')


