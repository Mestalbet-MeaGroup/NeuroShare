function simulateGamma(varargin)
% Simulate a stationary or piecewise stationary gamma process.
%
% simulateGamma generates series of successive points in time with the
% intervals in between drawn from the gamma distribution. It can also
% simulate non-stationary processes, i.e. processes where the rate is
% varying over time, for rates that are (approximated as) piecewise
% constant over equally sized time bins.
%
% Return value: Cell array, each entry is an array of event times of one
% realization.
%
% Parameters to be passed as parameter-value pairs:
%
% tMin: Start time.
% tMax: End time.
% rateVector: Vector containing the rates for each bin. The size of each
% bin is automatically determined as quotient of the total duration, tMin -
% tMax, and the number of entries in the rate vector.
% shapeParameter: The shape parameter of the gamma distribution.
% nRealizations: Number of realizations.
% [onsetType]: Either 'equilibrium' (default) or 'ordinary'. In the latter case,
% the process starts with an event at time onset.
%
% Further comments:
%
% For generating a non-stationary gamma process, see
%
% Spike train irregularity and count variability in cortical neurons,
% Nawrot et al., 2005 (...).
%
% The basic idea is to generate a stationary gamma process and then "warp"
% it according to the rate function. For piecewise constant rates this
% means that, to create a bin of given length in the non-stationary process,
% a segment of the stationary process with a length proportional to the
% rate is uniformly stretched/compressed towards the bin length. For
% example, if the rate is twice as high in a bin as compared to another, a
% segment twice as long is used from the stationary process.
%
% Notes:
%
% -The gamma distribution gamrnd provided by the MATLAB Statistics Toolbox
% uses parameters a and b, with shapeParam=a and rate=1/(ab).
%
% -To generate the stationary process, gamprc (originally by Stefan Rotter)
% is used. gamprc in turn makes use of gamrnd, hence currently the
% Statistics Toolbox is necessary for simulateGamma to run.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;

% obligatory argument names
obligatoryArgs={...
    {'tMin',@(val) length(val)==1}...
    {'tMax',@(val) length(val)==1}...
    {'rateVector',@(val) all(val>=0)},...
    {'shapeParameter',@(val) length(val)==1 && val>0},...
    {'nRealizations', @(val) length(val)==1 && val>=0 && mod(val,1)==0}...
    };

% optional arguments names with default values
optionalArgs={{'onsetType',@(val) ismember(val,{'equilibrium','ordinary'})},...
    'newNeuralEntityID','newEventEntityID'};

onsetType='equilibrium';
loadMode='prompt';
newNeuralEntityID=[];
newEventEntityID=[];

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

pvpmod(varargin);

%%%%%%%%%%%%%%%%%%%%%%%%%% run simulation %%%%%%%%%%%%%%%%%%%%%%%%%%

%%% CAUTION:
% SETs the SEED again! and uses the Mersenne Twister Random number
% generator !! If you have a better approach please let me know ...
%%%%%%%%%
rand('twister',sum(clock));

nBins = length(rateVector);
duration = tMax - tMin;
bin = duration / nBins;
warpedBins = bin*rateVector;
warpedDuration = sum(warpedBins);


% generate the nRealizations processes... might not be the fastest way and
% could possibly be optimized
newdata.Event.TimeStamp={[]};
newdata.Neural.Data={[]};
TrialSpace=0;

for iTrial = 1:nRealizations
    % generate stationary process for this trial
    statProcTmp = gamprc(0,warpedDuration,1,shapeParameter,1,onsetType);
    statProc = statProcTmp{1};
    nEvents = length(statProc);
    clear statProcTmp;

    % scaling to real time
    timeDepProc = zeros(1,nEvents);
    binEndTime = 0;
    for iBin = 1:nBins
        binStartTime = binEndTime;
        binEndTime = binEndTime + warpedBins(iBin);
        binLogicalIndeces = (statProc>=binStartTime) & (statProc<binEndTime);
        timeDepProc(binLogicalIndeces) = ...
            (statProc(binLogicalIndeces) ...
            - binStartTime) ...
            /warpedBins(iBin)*bin ...
            + (iBin - 1)*bin;
    end

    timeDepProc = (timeDepProc + tMin + TrialSpace)';
    % to make trials successive and put in virtuell space to separate
    % trials by include twice of trial length
    timeDepProc = [timeDepProc;(timeDepProc(end)+(tMax*2))];
    TrialSpace = (timeDepProc(end));
    % data into newdata Varialble
    newdata.Neural.Data{1}=[newdata.Neural.Data{1}; timeDepProc];
    newdata.Event.TimeStamp{1}=[newdata.Event.TimeStamp{1};TrialSpace];
end
newdata.Event.TimeStamp{1}=newdata.Event.TimeStamp{1}(1:(end-1));


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
EventDataOrigin{1}='simulated GammaProcess_trigger';
%store
store_ns_neweventdata('newdata',newdata,'DataOrigin',EventDataOrigin);


%%%%%%%%%%%%%%%%%%%%%%%%%% store neural data %%%%%%%%%%%%%%%%%%%%%%%%%%
% set ID
if ~isempty(newNeuralEntityID)&& ~ismember(newNeuralEntityID,[nsFile.EntityInfo.EntityID])&&...
        ~ismember(newNeuralEntityID,[nsFile.Segment.DataentityIDs])&&...
        ~ismember(newNeuralEntityID,[nsFile.Neural.EntityID])&&...
        ~ismember(newNeuralEntityID,[nsFile.Event.EntityID])&&...
        ~ismember(newNeuralEntityID,[nsFile.Analog.DataentityIDs])
    newdata.Neural.EntityID=newNeuralEntityID;
else
        newdata.Neural.EntityID=max([nsFile.Segment.DataentityIDs,nsFile.Event.EntityID,nsFile.Analog.DataentityIDs,...
        nsFile.Neural.EntityID,[nsFile.EntityInfo.EntityID]])+1;
    disp(['no Neural EntityID declared or double assined IDs - new neural EntityID:', num2str(newdata.Neural.EntityID)]);
end
% set Info
NeuralDataOrigin{1}='simulated GammaProcess_data';
% store
[usedIDs]=store_ns_newneuraldata('newdata',newdata,'DataOrigin',NeuralDataOrigin);

% store additional neural infos
for rr=1:length(usedIDs)
    posID=find(nsFile.Neural.EntityID==usedIDs(rr));
    nsFile.Neural.Info(posID).Tmin=tMin;
    nsFile.Neural.Info(posID).Tmax=newdata.Neural.Data{rr}(end,1);
    nsFile.Neural.Info(posID).l_rate=rateVector;
    nsFile.Neural.Info(posID).k_DistShape=shapeParameter;
end

clear newdata;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  comments=['gamprc: tMin=' num2str(tMin) ', tMax=' num2str(tMax) ...
%         ', rateVector=' num2str(rateVector) ' , shapeParameter=' ...
%         num2str(shapeParameter) ' ,# Trials=' num2str(nRealizations) ];
%     nsFile.Neural.Info(nsFile.Analog.DataentityIDs(posEntityID)).ProbeInfo=comments;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
