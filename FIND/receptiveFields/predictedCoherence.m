function [normPredCoh,predCoh,expCoh,F1,F2]=predictedCoherence(varargin)
% calculates maximal expected coherence given the noise in the neural data
% and the predicted coherence between linear predictor (linearPred) and the
% neural data in the analogEntityID, coherence calculated by averaging over
% sliding windows of 3000ms length and 13ms shift. Caution: I had
% intracellularly recorded data to perform this. There might have to be
% done some changes for spiking data!
%
%%%% Obligatory Parameters %%%%%
%
% linearPred: time series of the predicted response obtained by multiplying receptive field and stimulus
%  analogEntityIDs: the entity ids the coherence shall be calculated for
%  eventEntityID: the ID of the trial onsets
%
%%%%% Optional Parameters %%%%%%
%
% windowSize: size of sliding window over which the data is averaged in ms (default 3000)
% windowShift: shift of the sliding window for averaging in ms (default 13) 
% ifplot: 1 if coherence plots shall be done
%
%%%% H. Walz
		   %  FIND-project: http://find.bccn-freiburg.de

% obligatory argument names
obligatoryArgs={'linearPred','neuralEntityIDs','eventEntityID'};           

% optional arguments names with default values
optionalArgs={'windowSize','windowShift','ifplot','method'};
windowSize=3000;
windowShift=13;
ifplot=1;
method='windows';
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

posAnalog=[];
posNeural=[];
posEvent=[];
for p=1:length(neuralEntityIDs)
    posNeural=[posNeural,find(nsFile.Neural.EntityID==neuralEntityIDs(p))];
    posAnalog=[posAnalog,find(nsFile.Analog.DataentityIDs==neuralEntityIDs(p))];
    try
        posEvent=[posEvent,find(nsFile.Analog.DataentityIDs==eventEntityID)];
    end
end
expCoh=cell(length(posNeural),1);
predCoh=cell(length(posNeural),1);
normPredCoh=cell(length(posNeural),1);
F1=cell(length(posNeural),1);
F2=cell(length(posNeural),1);
for c=posNeural
nUnits=length(unique(nsFile.Segment.Data{c}));
for n=1:nUnits
nTrials=length(nsFile.Event.Data);
trialDuration=mean(diff(nsFile.Event.Data));
if length(preferredOri)
    onsets=(nsFile.Event.TimeStamp{eventPosEntityID}((preferredOri{c}(n)-1)*nTrials+1:preferredOri{c}(n)*nTrials)).*sr;
    sp=nsFile.Neural.Data{c}(find(nsFile.Segment.UnitID{c}==n));
    sp=sp(sp>onsets(1)/sr-baseDuration&sp<(onsets(end)/sr+(trialDuration+2*baseDuration)));
else
    onsets=nsFile.Event.TimeStamp{eventPosEntityID};
    sp=nsFile.Neural.Data{c}(find(nsFile.Segment.UnitID{c}==n));
end
edges=0:0.001:trialDuration;
responseIDX=zeros(nTrials,trialDuration*1000);
for oo=1:length(onsets)
    tsp=sp(sp>onsets(oo)/sr&sp<onsets(oo)/sr+trialDuration);
    tmp_idx=histc(tsp,edges+onsets(oo)/sr);
    responseIDX(oo,:)=tmp_idx(1:end-1);
end
psth=sum(responseIDX)*1000/nTrials;

%%% expected Coherence
yexpC=zeros(nTrials/2,3000);
for ty=1:nTrials/2
texpC(ty,:)=calculateCoherence('signal1',mean(responseIDX(:,ty:nTrials/2+ty),2),'signal2',mean(responseIDX(:,setdiff([1:nTrials],[ty:nTrials/2+ty])),2),'method',method);
end
expC=mean(texpC);
expCoh{c}(n)=1./(1+0.5.*nTrials.*(sqrt(1./expC)-1));
%%%predicted Coherence
if length(linearPred)~=length(psth)
    error('linear prediction and psth must be of same size!!')
elseif size(linearPred)~=size(psth)
    linearPred=linearPred';
end

predC=calculateCoherence('signal1',linearPred,'signal2',psth,'method',method);
predCoh{c}(n)=predC.*(1+sqrt(1./expC))./(2-nTrials+nTrials.*sqrt(1./expC));
normPredCoh{c}(n)=predCoh{c}(n)./expCoh{c}(n);



F1{c}(n)=nsFile.Analog.Info(posAnalog).SampleRate/length(expC):nsFile.Analog.Info(posAnalog).SampleRate/length(expC):nsFile.Analog.Info(posAnalog).SampleRate;
F2{c}(n)=nsFile.Analog.Info(posAnalog).SampleRate/length(predC):nsFile.Analog.Info(posAnalog).SampleRate/length(predC):nsFile.Analog.Info(posAnalog).SampleRate;
if ifplot==1
    figure;
    grey=[0.5 0.5 0.5];
    rosa=[1 0.8 0.8];
    h1=area(F1,expCoh{c}(n));
    set(h1,'FaceColor',grey);
    hold on;
    h2=area(F2,predCoh{c}(n));
    set(h2,'FaceColor',rosa,'EdgeColor','none');
    legend([h1 h2],'Coh_{exp}','Coh_{pred}');
    title('coherence between linear predictor and response');
  xLim([0 70])
end
end
end


