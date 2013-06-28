function tuningVector=calculateTuning(varargin)
% calculates tuning properties of cells from spike trains to oriented
% drifting grating with variing orientation, spatial or temporal frequency.
%
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% stimulus: a vector of different parameters of the grating (either
%   modulated spatial or temporal frequencies or orientations of the
%   drifting gratings
%
% response: the response as spike times of a neuron, if several trials than
%    as PSTH
%
% responseEntities: the analog entities of the response 
%
% trialDuration: time in seconds of the grating
% 
% baseDuration: time in seconds of spontaneous activity, recorded before
%   and after the grating
%
%%%%% Optional Parameters
% 
% kernelSize: the response should be convolved with a kernel, but if that
%   is done before, this should be small (DEFAULT=50)
%
%
% Henriette Walz 02/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%



% obligatory argument names
obligatoryArgs={'stimulus','response','responseEntities','trialDuration','baseDuration'};           % 'analogEntityIndex'};

% optional arguments names with default values
optionalArgs={'kernelSize'};
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

global nsFile idx

%find position IDs of analog entities.
posEntityIDs=[];
neuralPosEntityIDs=[];
for j=1:length(responseEntities)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==responseEntities(j))];
    neuralPosEntityIDs=[neuralPosEntityIDs,find(nsFile.Neural.EntityID==responseEntities(j))];
end

for f=1:length(posEntityIDs)
    c=neuralPosEntityIDs(f);
    stim_s=size(stimulus);
    resp_s=size(response{c});

    nParameters=stim_s(2);
    nUnits=resp_s(1);

    wholeTrialDuration_samples=resp_s(3);
    baseDuration_samples=wholeTrialDuration_samples/(2*baseDuration+trialDuration);
    trialDuration_samples=wholeTrialDuration_samples-2*baseDuration_samples;

    SpontanAverage=zeros(nUnits,nParameters);
    temp_EvokedAverage=zeros(nUnits,nParameters);

    SpontanAverage=sum(response{c}(:,:,[1:baseDuration_samples,(baseDuration_samples+trialDuration_samples):wholeTrialDuration_samples]),3)/baseDuration/2;
    temp_EvokedAverage=sum(response{c}(:,:,[baseDuration_samples:(trialDuration_samples+baseDuration_samples)]),3)/trialDuration;

    global EvokedAverage;
    EvokedAverage=temp_EvokedAverage./SpontanAverage;
    h1=figure;
    count=1;
    set(gcf, 'name','Receptive Field Preferred orientation');

   
    for f=1:nUnits
        figure(h1);
        subplot(nUnits,1,count);
        hold on;
        ylabel('relative firing rate','FontSize',14);
        YLim([0 2]);
        xlabel('parameters of madulated drifting grating','FontSize',14);
        plot(stimulus,EvokedAverage(f,:),'-*');
        title(['unit ',num2str(f)],'FontSize',14);
        count=1+count;
   end

        for f=1:nUnits   
             %%% plot psth and raster for the preferred orientation
       h=figure;
        set(h,'name','psth' );
        subplot(2,1,1);
        kernelWin=window(@triang,kernelSize);
        psth2plot=conv(squeeze(response{c}(f,find(EvokedAverage(f,:)==max(EvokedAverage(f,:))),:)),kernelWin);
        firingrate=psth2plot(kernelSize/2:end-kernelSize/2)/sum(kernelWin);
        lh=plot(firingrate);
        legend(lh,sprintf('unit %3i',f));
        title(sprintf('psth for the preferred orientation convolved with a triangular kernel of size %2i',kernelSize));
        xlabel('time in ms','FontSize',14);
        ylabel('frequency in Hz','FontSize',14)
        hold on
        plot([baseDuration_samples baseDuration_samples],[0 max(firingrate)],'r', 'LineWidth', 2)
        hold on
        plot([(baseDuration_samples+trialDuration_samples) (baseDuration_samples+trialDuration_samples)],[0 max(firingrate)],'r', 'LineWidth', 2)
        set(gca,'FontSize',14);
            if size(idx)
        trials=size(idx{c},2)/size(response{c},2);
            subplot(2,1,2);
            thisIdx=squeeze(idx{c}(f,(find(EvokedAverage(f,:)==max(EvokedAverage(f,:)))-1)*trials+1:find(EvokedAverage(f,:)==max(EvokedAverage(f,:)))*trials,:));
            for k=1:size(thisIdx,1)
                spikes=squeeze(thisIdx(k,:));
                subplot(2,1,2);plot([find(spikes); find(spikes)],[ones(1,length(find(spikes)))*k ;ones(1,length(find(spikes)))*k+0.5],'k');
                hold on

                xlabel('time/ms','FontSize',14)
                ylabel(['trials (n=',num2str(size(spikes,1)),')'],'FontSize',14);
            end
            ylim([0.5 k+1]);
            xlim([0 size(idx{c},3)]);
            plot([baseDuration_samples baseDuration_samples],[0 k+1],'r', 'LineWidth', 2)
            hold on
            plot([(baseDuration_samples+trialDuration_samples) baseDuration_samples+trialDuration_samples],[0 k+1],'r', 'LineWidth', 2)
            set(gca,'FontSize',14);    
        end
    end
end

    tuningVector=EvokedAverage;










