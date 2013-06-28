function shifts=autoAlign(varargin)
% function autoAlign(varargin)
% Aligns different data streams automatically.
% e.g. usefull for alimenent of spike-rate functions accroding to onset of a rate response
%
% obligatory arguments:
% 'neuralIDs','eventID','preTrigger','postTrigger'
% (only single ID as input to eventID possible)
%
% (0) Ralph Meier, meier@biologie.uni-freiburg.de
%
% Example Analysis and further Information:
%   
%   Meier R, Egert U, Aertsen A, Nawrot M (2008)
%   FIND – a unified framework for neural data analysis
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;


% obligatory argument names
obligatoryArgs={{'neuralIDs', @(val) length(val)>1},...
    {'eventID', @(val) length(val)==1},...
    'preTrigger','postTrigger'};

% optional arguments names with default values
optionalArgs={};

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

% check if data is available
for ii=1:length(neuralIDs)
    isemptylist(ii)=isempty(nsFile.Neural.Data{ii});
end

% check neural
if ~isfield(nsFile,'Neural') || ~isfield(nsFile.Neural,'Data') ...
        || sum(isemptylist)~=0
    error('FIND:noNeuralData','No neural data found in nsFile variable.');
end

% check event
if ~isfield(nsFile,'Event') || ~isfield(nsFile.Event,'TimeStamp') ...
        || sum(ismember(nsFile.Event.EntityID,eventID))==0
    error('FIND:noEventData','No event timestamps found in nsFile variable.');
else
    SELECTED_EVENTS= find(nsFile.Event.EntityID==eventID);
    if isempty(nsFile.Event.TimeStamp{SELECTED_EVENTS})
        error('FIND:noEventData','No event timestamps found in nsFile variable.');
    end
end

% set parameters
n=20;
nl=-20;
nr=-nl;
ld=1;
m=1;
TIME_BIN_MS=1
SMOOTH_RATEFKTN=20;

% convert ID into position
SELECTED_NEURAL_IDS =find(nsFile.Neural.EntityID==neuralIDs); 
 
PRE_TIME=preTrigger;
PAST_TIME=postTrigger;


% Prepare a matrix of rate functions that is used for the alingment
% outcome: array of rates x time in variable ss

clear ss; 
elc=1;
for EL=1:length(SELECTED_NEURAL_IDS)

    thisEL=SELECTED_NEURAL_IDS(EL);
    %% collect spikes
    s=[];
    triggers=nsFile.Event.TimeStamp{SELECTED_EVENTS};
    
    spikes=nsFile.Neural.Data{thisEL};

    for ii=1:length(triggers)
        in_window=(spikes - triggers(ii)> - PRE_TIME) +( spikes - triggers(ii)< PAST_TIME) ;
        s=[s ; spikes(find(in_window==2))- triggers(ii)]; % all spikes around the trigger subsummed. 0 denotes trigger onset.
    end

    % bin with ms precision:
    TIME_VEC=[-PRE_TIME*1000:PAST_TIME*1000] + PRE_TIME*1000;
    spVec=histc(s*1000,TIME_VEC);
    ss(:,elc)=spVec;
    elc=elc+1;
end

ORIGINAL_SPIKES=ss;
% do the alignment
shifts=99999; cc=1;
while sum(abs(shifts))>10 && cc<10
    % iterate till shifts are small or too many iterations

    savgol = makeSavgol('n',n,'ld',ld,'m',m, ...
        'wf','Welch','h',1e-3);

    le=length(savgol);
    window = hanning(length(ss));

    ssfilt=ss.*repmat(window,1,size(ss,2));
    % filter spike trains
    fs = filter(fliplr(savgol),1,ssfilt);
    % cut away filter
    fs=fs(length(savgol):end,:);

    % get the relative shifts
    shifts = nShift('data',fs,'samplingRate',TIME_BIN_MS,'maxlagms',100,'normflag','coeff','parabolicflag','lin','parabolicsigma',nr);
    shifts=round(shifts-mean(shifts));

    %% realing the data  .. global again
    for ii=1:size(ss,2)
        realss(:,ii)=ss(:,ii).*hanning(length(ss)) + shifts(ii);
    end
    meanrate=mean(realss');

    latdev=estimateLatencyByDerivative('s',meanrate,'n',20);
    % get the absolute latencies
    latencies=(latdev - shifts + nr + PRE_TIME*1000) + (PRE_TIME * 1000);
    % REPORT about it
    disp(['========== Iteration: ' num2str(cc) ' =====================' ])
    disp('------- LATENCIES -------');
    disp(num2str(latencies'));
    disp('------- SHIFTS -------');
    disp(num2str(shifts'));
    disp('===============================')


    % apply the shift to the spike trains
    ss=realss;

    ITER_SHIFT(cc,:)=shifts;
    ITER_LAT(cc,:)=latencies;
    cc=cc+1;
end


shifts=sum(ITER_SHIFT);


%% Visualize the Result:

to_shift=sum(ITER_SHIFT);
%% re generate the rate functions:
for EL=1:length(SELECTED_NEURAL_IDS)

    thisEL=SELECTED_NEURAL_IDS(EL);
    %% collect spikes
    s=[];
    triggers=nsFile.Event.TimeStamp{SELECTED_EVENTS}; 
    spikes=nsFile.Neural.Data{thisEL};

    for ii=1:length(triggers)
        in_window=(spikes - triggers(ii)> - PRE_TIME) +( spikes - triggers(ii)< PAST_TIME) ;
        s=[s ; spikes(find(in_window==2))- triggers(ii)]; % all spikes around the trigger subsummed. 0 denotes trigger onset.
    end

    % bin with ms precision:
    TIME_VEC=[-PRE_TIME*1000:PAST_TIME*1000]; + PRE_TIME*1000;
    spVec_a=histc((s*1000 )+to_shift(EL),TIME_VEC);
    spVec_b=histc((s*1000 ),TIME_VEC);
    ss_a(:,elc)=spVec_a;
    ss_b(:,elc)=spVec_b;
    elc=elc+1;
end

cm=hsv(size(ss_a,2));
figure('Name', 'unaligned','NumberTitle','off'); hold on;
for ii=1:size(ss_a,2);
    tmp=conv(ss_a(:,ii),ones(SMOOTH_RATEFKTN,1)/SMOOTH_RATEFKTN);
    plot(TIME_VEC,tmp(SMOOTH_RATEFKTN:end),'k-','color',cm(ii,:),'linewidth',2);
end

axis tight;
ax=axis;
axis([-PRE_TIME*1000 PAST_TIME*1000 0 ax(4)]);
ylabel('1/s');
xlabel('t [ms]');
title('unaligned');


cm=hsv(size(ss_b,2));
figure('Name', 'realigned','NumberTitle','off'); hold on;
for ii=1:size(ss_b,2);
    tmp=conv(ss_b(:,ii),ones(SMOOTH_RATEFKTN,1)/SMOOTH_RATEFKTN);
    plot(TIME_VEC,tmp(SMOOTH_RATEFKTN:end),'k-','color',cm(ii,:),'linewidth',2);
end
title('realigned');


axis tight;
ax=axis;
axis([-PRE_TIME*1000 PAST_TIME*1000 0 ax(4)]);
ylabel('1/s');
xlabel('t [ms]');

