function STA=calculateSTA(varargin)
%function [STA]=calculateSTA(varargin)
% calculates spike triggered average from linearized stimulus and spike
% time response
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% stimulus: the stimulus aligned as the memorable frames to each time point
%    for storage reasons the STA is calculated separately for different time
%    points before the spike
% spikeTrain: the response as spike times of a neuron, if several trials than
%    as T*Trials
% mem: number of memorable frames
% trialDuration: the duration of the trials in seconds
% baseDuration: the duration of base line activity before and after (!!)
%    the trials
% frameDuration: the duration of each frame in seconds
%
%
%%%%%%Optional Parameters
%
% ifplot: has to be 1 if the spike triggered averages should be plotted
%
%
% Henriette Walz 02/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%


% obligatory argument names
obligatoryArgs={'stimulus', 'responseEntities','mem','trialDuration','baseDuration','frameDuration'};           % 'analogEntityIndex'};

% optional arguments names with default values
optionalArgs={'ifplot'};
ifplot=1;

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end
% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

global nsFile;

posEntityIDs=[];
neuralPosEntityIDs=[];
for j=1:length(responseEntities)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==responseEntities(j))];
    neuralPosEntityIDs=[neuralPosEntityIDs,find(nsFile.Neural.EntityID==responseEntities(j))];
end
eventPosEntityID=find(nsFile.Analog.DataentityIDs==eventID);


STA=cell(length(neuralPosEntityIDs),1);
%STA_mean=cell(max(neuralPosEntityIDs),1);

maxStim=max(max(max(stimulus)));
minStim=min(min(min(stimulus)));

cmap=[zeros(10,1) , [1:-0.1:0.1]' ,zeros(10,1);[0.1:0.1:1]', zeros(10,1),zeros(10,1)];
%allSTA=cell(length(posEntityIDs));
for ff=neuralPosEntityIDs;
    ffi=find(neuralPosEntityIDs==ff);
    ffa=find(posEntityIDs==ff);

    %get sizes of stimulus and spikeTrain
    stim_s=size(stimulus);
    nUnits=length(unique(nsFile.Segment.UnitID{ffi}));
    nTrials=length(nsFile.Event.TimeStamp{eventPosEntityID});
    %initiate the variable for the STAs of individual trials and for the
    %average of those
    tmp_allSTA=zeros(nUnits,mem,nTrials,stim_s(2));
    sr=nsFile.Analog.Info(ffa).SampleRate;
    STA{ffi}=zeros(nUnits,mem,stim_s(2));
    % STA_mean{ffi}=zeros(nUnits,mem,stim_s(2));
    for n=1:nUnits

        edges=0:0.001:trialDuration;
        responseIDX=zeros(nTrials,trialDuration*1000);
        for oo=1:length(nsFile.Event.TimeStamp{eventPosEntityID})
            tsp=sp(sp>nsFile.Event.TimeStamp{eventPosEntityID}(oo)&sp<nsFile.Event.TimeStamp{eventPosEntityID}(oo)+trialDuration);
            tmp_idx=histc(tsp,edges+onsets(oo)/sr);
            responseIDX(oo,:)=tmp_idx(1:end-1);
        end
        %calculate STA for different frames before the spike, as far back
        %as is selected by the variable memory

        for trials=1:nTrials
            if (trialDuration+2*baseDuration)*1000==spikes_s(3)
                edges=1:frameDuration*1000:trialDuration*1000;
                thisSpikeTrain=hist(find(responseIDX(trials,baseDuration/frameDuration+1:end-baseDuration/frameDuration)),edges);
            elseif (trialDuration+2*baseDuration)/frameDuration==spikes_s(3)
                thisSpikeTrain=squeeze(responseIDX(trials,baseDuration/frameDuration+1:end-baseDuration/frameDuration));
            else
                error('spike train size mismatches stimulus size')
            end
            spikeTrainThisTrial=repmat(thisSpikeTrain',[1,stim_s(2)]);
            sumSpikes=sum(thisSpikeTrain);
            for mm=1:mem
                % the STA is calculated by multiplying the spike train with 
                % the stimulus. therefore the spike train has to be
                % transformed to a matrix the same size as the stimulus
                tmp_allSTA(n,mm,trials,:)=sum(spikeTrainThisTrial.*[zeros(mm-1,stim_s(2));stimulus(1:end-mm+1,:)])./sumSpikes;
            end
           
        end
    end
    STA{ffi}(:,:,:)=mean(tmp_allSTA,3);

    if ifplot
        for nn=1:nUnits
            %plot STAs for diffierent frames before spikes
            h=figure;
            set(h,'name',sprintf('spike triggered average for unit %2i of channel number %2i',nn,responseEntities(ffi)))
            xSubplots=ceil(sqrt(mem));
            ySubplots=floor(sqrt(mem));

            for f=1:mem
                subplot(ySubplots,xSubplots,f); imagesc(reshape(squeeze(STA{ffi}(nn,f,:)),[89,89]));
                xlabel('x/noisel');
                ylabel('y/noisel');
                axis square;
                title(sprintf('STA %2i frames before spike',f));
                colormap(cmap);
                caxis([minStim maxStim]);
                colorbar;
            end
        end
    end
end

disp('done calculating STA');






















    
