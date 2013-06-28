function predFiringRate=determinePred(varargin)
% determines prediction from the linear filters and the determined
% nonlinearity; returns predicted rate function
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% 'stimulus': a matrix of grey values of the displayed stimulus, in
%    space x time dimension
% 'nonLinearity': the nolinear function of the linear filters
% 'linearFilters': a matrix of the spike triggered average and possibly
%   other linear filters
% 'analogEntityIndex': index of the entity analog number
%
% %%%% Optional Parameters %%%%%
% 
% 'rfCenters': indices of centers of the receptive fields if the stimulus
%   is bigger.
% 'frameDuration': duration of one frame in seconds
% 'baseDuration': duration of recorded spontaneous activity before and
%           after(!) the trials
% 'trialDuration':duration of one trial in seconds
%
%
% Henriette Walz 03/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%


% obligatory argument names
obligatoryArgs={'stimulus','nonLinearity','linearFilters','analogEntityIndices',};

% optional arguments names with default values
optionalArgs={'rfCenters','frameDuration','baseDuration','trialDuration'};
rfCenters=[];
frameDuration=0.0083;
baseDuration=0;
trialDuration=80;

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

global nsFile PSTH linearizedStimulus STA linearPred

posEntityIDs=[];
for l=1:length(analogEntityIndices)
     posEntityIDs=[posEntityIDs, find(nsFile.Analog.DataentityIDs==analogEntityIndices(l))];
end
cutPix=2;
predFiringRate=cell(length(posEntityIDs),1);

for c=1:length(posEntityIDs)
    nUnits=length(unique(nsFile.Segment.UnitID{c}));
    predFiringRate{c}=zeros(nUnits,size(stimulus,1));
    for nn=1:nUnits
        if ~isempty(rfCenters)
                stimSquared=reshape(stimulus,[size(stimulus,1), sqrt(size(stimulus,2)), sqrt(size(stimulus,2))]);
                stimSmall=stimSquared(:,rfCenters{c}(nn,1,1)-2:rfCenters{c}(nn,1,1)+2,rfCenters{c}(nn,2,1)-2:rfCenters{c}(nn,2,1)+2);
                stim2use=reshape(stimSmall,[size(stimulus,1) 25]);
                staSquared=reshape(linearFilters{c},[size(linearFilters{c},1) size(linearFilters{c},2) sqrt(size(linearFilters{c},3)) sqrt(size(linearFilters{c},3))]);
                staSmall=staSquared(nn,:,rfCenters{c}(nn,1,1)-2:rfCenters{c}(nn,1,1)+2,rfCenters{c}(nn,2,1)-2:rfCenters{c}(nn,2,1)+2);
                sta2use=reshape(staSmall,[size(staSmall,2) size(staSmall,3)*size(staSmall,4)]);
        else
            stim2use=stimulus;
            sta2use=squeeze(linearFilters{c}(nn,:,:));
        end

        mem=size(linearFilters{c},2);
        %%% because matrices become quite big it has to do this in a loop
        for ii=mem:size(stim2use,1)
            predFiringRate{c}(nn,ii)=nonLinearity{c}(nn,(find(nonLinearity{c}(nn,:,1)==linearPred{c}(nn,ii))),2);
        end

        figure;
        time2plot=[frameDuration:frameDuration:frameDuration*(size(linearPred{c},2))];
        psth2plot=squeeze(PSTH{1}(nn,:,baseDuration/frameDuration+1:end-baseDuration/frameDuration));
        plot(time2plot,squeeze(predFiringRate{c}(nn,:)),'r',time2plot,psth2plot,'b')
        legend('predicted response','psth to ten trials of stimulus');
        xlabel('frames of 50 ms duration');
        ylabel('firing rate');
        title(sprintf('prediction for firing rate  for unit %2i of channel %2i',nn,c));

    end
end







