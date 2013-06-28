function [R,psth]=processResponseDg(varargin);   %[R,PSTH]=processResponse(varargin);
% calculates spike triggered average from linearized stimulus and spike
% time response
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% stimulus: the stimulus aligned as the memorable frames to each time point
%
% response: the response as spike times of a neuron, if several trials than
% as PSTH
%
%
%
%
% Henriette Walz 02/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%


% obligatory argument names
obligatoryArgs={'eventEntity','responseEntities', 'trialDuration'};           % 'analogEntityIndex'};

% optional arguments names with default values
optionalArgs={'binSizeS', 'baseDuration', 'trials','Parameters'};
binSizeS=0.001;
baseDuration=0;
trials=0;
Parameters=0;

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
eventPosEntityID=find(nsFile.Event.EntityID==eventEntity);

% find trial onsets and duration times
trialOnsets=nsFile.Event.TimeStamp{eventPosEntityID}*nsFile.Analog.Info(1).SampleRate;
trialDuration_samples=trialDuration*nsFile.Analog.Info(1).SampleRate;
baseDuration_samples=baseDuration*nsFile.Analog.Info(1).SampleRate;
wholeTrialDuration=2*baseDuration+trialDuration;
wholeTrialDuration_samples=trialDuration_samples+2*baseDuration_samples;

%assign some variables
%psth
psth_temp=cell(length(responseEntities),1);
R_temp=cell(length(responseEntities),1);
nParameters=length(Parameters);
%binsize for gwn refresh rate of monitor
binsize=nsFile.Analog.Info(1).SampleRate*binSizeS;
edges=[1:binsize:(wholeTrialDuration_samples+1)];

Trials=length(trialOnsets)/length(Parameters);


for c=1:length(posEntityIDs)
    units=length(unique(nsFile.Segment.UnitID{c}));
    psth_temp{c}=zeros(units,nParameters,length(edges)-1);
    R{c}=zeros(units,Trials,length(edges)-1);
    for t=1:units
        %get indices of spike times
        %neuralData;
        tmp_neuralEventData=nsFile.Neural.Data{c}(find(nsFile.Segment.UnitID{c}==t))*nsFile.Analog.Info(posEntityIDs(c)).SampleRate;
        %%now sum up over trials
        for ii=1:nParameters
            for tt=1:Trials
                tti=(ii-1)*Trials+tt;
                tmp_neuralEventDataThisTrial=tmp_neuralEventData(find(tmp_neuralEventData>(trialOnsets(tti)-baseDuration_samples)&tmp_neuralEventData<(trialOnsets(tti)+trialDuration_samples+baseDuration_samples)))-trialOnsets(tti)+baseDuration_samples;

                %now bin data to refresh rate of stimulus or for Drifting Grating
                %just to one msec
                if isempty(tmp_neuralEventDataThisTrial)
                    tmp_neuralEventDataThisTrial=0;
                end
                neuralEventDataThisTrial=histc(tmp_neuralEventDataThisTrial,edges);
                R_temp{c}(t,tti,:)=neuralEventDataThisTrial(1:end-1);%sum(neuralEventDataThisTrial([int32(edges(j)):int32(edges(j+1)-1)]));
                if tt==Trials
                    psth_temp{c}(t,int16(ii),:)=sum(R_temp{c}(t,tti-Trials+1:tti,:))/Trials/binSizeS;
                end
            end

        end
    end
end

R=R_temp;
psth=psth_temp;


%%%%%%%%%%%%%%%plot data%%%%%%%%%%%%%%%%%


for q=1:length(posEntityIDs)
    for units=1:size(psth{q},1)
        h=figure;
        set(h,'name',sprintf('psth over 9 trials for a sequence of white noise for channel number %2i',nsFile.Analog.DataentityIDs(q)));
        for ii=1:length(Parameters)
            subplot(length(Parameters),1,ii)
            kernelWin=window(@triang,50);
            psth2plot=conv(squeeze(psth{c}(units,ii,:)),kernelWin);
            firingrate=psth2plot(25:end-25)/sum(kernelWin);
            lh=plot(edges(1:end-1)/25,firingrate);
            legend(lh,sprintf('unit %3i',units));
            title(sprintf('psth for  %2i',Parameters(ii)));
            xlabel('time/ms');
            ylabel('frequency in Hz')
            hold on
            plot([baseDuration_samples/25 baseDuration_samples/25],[0 max(firingrate)],'r', 'LineWidth', 2)
            hold on
            plot([(baseDuration_samples+trialDuration_samples)/25 (baseDuration_samples+trialDuration_samples)/25],[0 max(firingrate)],'r', 'LineWidth', 2)
        end
    end
end
lh_raster=rasterPlot('eventID',eventEntity,'neuralIDs',responseEntities,'preTrigger',baseDuration,'postTrigger',trialDuration+baseDuration,'trialDuration',trialDuration);
