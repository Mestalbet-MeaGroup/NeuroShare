function [R,psth,psthEntityIDs]=processResponse(varargin);  
% calculates psth and cuts the spike train in different trials according to
% the trial onsets in nsFile.Event.Data
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% eventEntity: the analog index of the entity in event
% responseEntity: the analog index of the entity in neural
% trialDuration: duration of the trials in seconds
%
% %%%% Optional Parameters %%%%
%
% binSizeS: length of bins in seconds
% baseDuration: duration of grey before and after the trials
% trials: which trials should be taken into the analysis
% Parameters: a vector with the angles of gratings etc.
% ifplot
% noUnits: if the units should NOT be taken into account this should be ones!
%
% Henriette Walz 02/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%


% obligatory argument names
obligatoryArgs={'eventEntity','responseEntities', 'trialDuration'};           % 'analogEntityIndex'};

% optional arguments names with default values
optionalArgs={'binSizeSamples', 'baseDuration', 'trials','Parameters','ifplot','noUnits','kernelSize'};
binSizeSamples=0;
baseDuration=0;
trials=[1:10];
Parameters=0;
ifplot=1;
noUnits=0;
kernelSize=50;

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
neuralPosEntityIDs=[];
for j=1:length(responseEntities)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==responseEntities(j))];
    neuralPosEntityIDs=[neuralPosEntityIDs,find(nsFile.Neural.EntityID==responseEntities(j))];
end
eventPosEntityID=find(nsFile.Analog.DataentityIDs==eventEntity);

% find trial onsets and duration times
trialOnsets=nsFile.Event.TimeStamp{eventPosEntityID}*nsFile.Analog.Info(1).SampleRate;
trialDuration_samples=trialDuration*nsFile.Analog.Info(1).SampleRate;
baseDuration_samples=baseDuration*nsFile.Analog.Info(1).SampleRate;
wholeTrialDuration=2*baseDuration+trialDuration;
wholeTrialDuration_samples=trialDuration_samples+2*baseDuration_samples;

%assign some variables
%psth
R_temp=cell(length(responseEntities),1);
nParameters=length(Parameters);
%binsize 1 ms or specified
if ~binSizeSamples
    binSizeSamples=nsFile.Analog.Info(neuralPosEntityIDs(1)).SampleRate/1000;
end
binSizeS=binSizeSamples/nsFile.Analog.Info(neuralPosEntityIDs(1)).SampleRate;
edgesS=[binSizeS:binSizeS:wholeTrialDuration];
edges=[1:binSizeSamples:(wholeTrialDuration_samples+1)];
Trials=length(trials);

for c=1:length(neuralPosEntityIDs)
    if ~noUnits && ~isempty(nsFile.Segment.UnitID{neuralPosEntityIDs(c)})
    units=length(unique(nsFile.Segment.UnitID{neuralPosEntityIDs(c)}));
    elseif noUnits || isempty(nsFile.Segment.UnitID{end})
        units=1;
    end
    R{c}=zeros(units,Trials,length(edges)-1);
    for t=1:units
        %get indices of spike times
        if units~=1
            neuralData=nsFile.Neural.Data{neuralPosEntityIDs(c)}(find(nsFile.Segment.UnitID{neuralPosEntityIDs(c)}==t));
        else neuralData=nsFile.Neural.Data{neuralPosEntityIDs(c)};
        end
        tmp_neuralEventData=neuralData*nsFile.Analog.Info(neuralPosEntityIDs(c)).SampleRate;
        %%now sum up over trials
        summedNeuralEventData=zeros(wholeTrialDuration_samples, 1);
        for tt=1:length(trialOnsets)
                tmp_neuralEventDataThisTrial=tmp_neuralEventData(find(tmp_neuralEventData>(trialOnsets(tt)-baseDuration_samples)&tmp_neuralEventData<(trialOnsets(tt)+trialDuration_samples+baseDuration_samples)))-trialOnsets(tt)+baseDuration_samples;
                %now bin data to refresh rate of stimulus or for Drifting Grating
                %just to one msec
                if isempty(tmp_neuralEventDataThisTrial)
                    tmp_neuralEventDataThisTrial=0;
                end
                
                neuralEventDataThisTrial=histc(tmp_neuralEventDataThisTrial,edges);
                R_temp{c}(t,tt,:)=neuralEventDataThisTrial(1:end-1);

        end
    end
        psthEntityIDs(c)=nsFile.Analog.DataentityIDs(neuralPosEntityIDs(c));


end


R=R_temp;
for k=1:length(R)
    psth{k}=sum(R{k},2)/size(R{k},2)/binSizeS;
end


%%%%%%%%%%%%%%%plot data%%%%%%%%%%%%%%%%%

if ifplot
    for q=1:length(neuralPosEntityIDs)
        for units=1:size(psth{q},1)
            h=figure;
            %set(h, 'visible','off')
            set(h,'name','psth' );
            kernelWin=window(@triang,kernelSize);
            thisPsth2plot=conv(squeeze(psth{c}(units,:)),kernelWin);
            firingrate=thisPsth2plot(kernelSize/2:end-kernelSize/2)/sum(kernelWin);
            subplot(2,1,1);lh=plot(edgesS(1:end),firingrate);
            legend(lh,sprintf('unit %3i',units));
            title(sprintf('psth over %2i trials for channel number %2i, binned to the duration of one frame %2i of stimulus and convolved with a triangular kernel of size %2i',Trials,nsFile.Analog.DataentityIDs(posEntityIDs(q)),binSizeS,kernelSize),'FontSize',14);
            xlabel('time','FontSize',14);
            ylabel('frequency in Hz','FontSize',14)
            hold on
            plot([baseDuration baseDuration],[0 max(firingrate)],'r', 'LineWidth', 2)
            hold on
            plot([(baseDuration+trialDuration) (baseDuration+trialDuration)],[0 max(firingrate)],'r', 'LineWidth', 2)
            xlim([0 edgesS(end)]);
            set(gca,'FontSize',14);
            %raster plot
            for k=1:size(R{q},2)
                spikes=squeeze(R{q}(units,k,:));
                subplot(2,1,2);plot([find(spikes)'; find(spikes)'],[ones(1,length(find(spikes)))*k ;ones(1,length(find(spikes)))*k+0.5],'k');
                hold on

                xlabel('time/ms','FontSize',14)
                ylabel(['trials (n=',num2str(size(spikes,1)),')'],'FontSize',14);
            end
            set(gca,'FontSize',14);
            ylim([0.5 k+1]);
            xlim([0 size(R{q},3)]);
            plot([baseDuration_samples/binSizeSamples baseDuration_samples/binSizeSamples],[0 k+1],'r', 'LineWidth', 2)
            hold on
            plot([(baseDuration_samples+trialDuration_samples)/binSizeSamples (baseDuration_samples+trialDuration_samples)/binSizeSamples],[0 k+1],'r', 'LineWidth', 2)

        end
    end
end