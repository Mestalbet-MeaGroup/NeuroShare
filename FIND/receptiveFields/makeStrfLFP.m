function [LFP,meanLFP]=processResponse(varargin);   %[R,PSTH]=processResponse(varargin);
% calculates spike triggered average from linearized stimulus and spike
% time response
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% event entity: the stimulus aligned as the memorable frames to each time point
%
% response entities: the response as spike times of a neuron, if several trials than
% as PSTH
%
%
%
%
% Henriette Walz 05/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%


% obligatory argument names
obligatoryArgs={'eventEntity','responseEntities', 'trialDuration', 'sameTrials'};           % 'analogEntityIndex'};

% optional arguments names with default values
optionalArgs={ 'baseDuration', 'Parameters','ifplot'};
baseDuration=0;
Parameters=0;
ifplot=1;


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
warning off;

%find position IDs of analog entities.
posEntityIDs=[];
for j=1:length(responseEntities)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==responseEntities(j))];
end
posEntityEventID=find(nsFile.Event.EntityID==eventEntity);
lowPassFilterFrequency=1;
highPassFilterFrequency=150;
trialOnsets=nsFile.Event.TimeStamp{posEntityEventID}*nsFile.Analog.Info(posEntityIDs(1)).SampleRate;
time2plot=[1/25000:1/25000:trialDuration+2*baseDuration];
LFP=cell(length(posEntityIDs),1);
LFPmean=cell(length(posEntityIDs),1);
for c=1:length(posEntityIDs)
    hc=figure;
    trialDuration_Samples=trialDuration*nsFile.Analog.Info(posEntityIDs(c)).SampleRate;
    baseDuration_Samples=baseDuration*nsFile.Analog.Info(posEntityIDs(c)).SampleRate;
    %%%at first filter the data
    f=lowPassFilterFrequency/highPassFilterFrequency;
    [b,a]=cheby1(2,0.1,f);
    filtered_data=filtfilt(b,a,nsFile.Analog.Data(:,1));%posEntityID(c)));
    %%assign variable
    LFP{c}=zeros(size(sameTrials,1), size(sameTrials,2),trialDuration_Samples+2*baseDuration_Samples);
    meanDataTheseTrials=zeros(size(sameTrials,1),trialDuration_Samples+2*baseDuration_Samples);    
    for str=1:size(sameTrials,1)
        dataThisTrial=zeros(size(sameTrials,2),trialDuration_Samples+2*baseDuration_Samples);
        for tr=1:size(sameTrials,2)
            trialNumber=(str-1)*size(sameTrials,2)+tr;
            beginningThisTrial=trialOnsets(trialNumber)+1-baseDuration_Samples;
            endThisTrial=trialOnsets(trialNumber)+trialDuration_Samples+baseDuration_Samples;
            meanDataThisTrial=mean(filtered_data(beginningThisTrial:endThisTrial));
            stdDataThisTrial=std(filtered_data(beginningThisTrial:endThisTrial));
            dataThisTrial(tr,:)=(filtered_data(beginningThisTrial:endThisTrial)-meanDataThisTrial)/stdDataThisTrial;
            subplot(size(sameTrials,1),2,2*str-1);plot(time2plot,ones(size(time2plot),1)*tr*5+dataThisTrial(tr,:),'k'); hold on
            xlabel('time/s')
            ylabel('z-score')
            ylim([0 55]);
            if tr==1
                subplot(size(sameTrials,1),2,2*str-1);plot([baseDuration baseDuration],[1 100],'r'); hold on
                subplot(size(sameTrials,1),2,2*str-1);plot([baseDuration+trialDuration baseDuration+trialDuration],[1 100],'r'); hold on
                if str==1
                  title('single trials')
                end
            end
        end
        meanDataTheseTrials(str,:)=mean(dataThisTrial);
        subplot(size(sameTrials,1),2,2*str); plot(time2plot,meanDataTheseTrials(str,:));
        ylim([-2 2]);
        hold on 
        xlabel('time/s')
        ylabel('z-score')
        subplot(size(sameTrials,1),2,2*str);plot([baseDuration baseDuration],[min(meanDataTheseTrials(str,:)) max(meanDataTheseTrials(str,:))],'r'); hold on
        subplot(size(sameTrials,1),2,2*str);plot([baseDuration+trialDuration baseDuration+trialDuration],[min(meanDataTheseTrials(str,:)) max(meanDataTheseTrials(str,:))],'r'); hold on
        if str==1
            title('averaged over trials')
        end
        LFP{c}(str,:,:)=dataThisTrial;
        meanLFP{c}=meanDataTheseTrials;    
    end
    
end




