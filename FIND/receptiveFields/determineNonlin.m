function [linRMSE,linearPred,nonLinearity]=determineNonlin(varargin)
% calculates the mean spared error of the linear prediction and if stated
% the nonlinearity
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% stimulus: matrix of the stimulus
% psth: psth of the response   
% nTrials:number of trials
% responseEntities: analog entity of response channel which is to be analyzed
% mem: number of memorizable frames 
% STA: spike triggered average as the linear filter
% frameDuration:the duration of one frame in seconds
% trialDuration: duration of one trial in seconds
% baseDuration: duration of spontaneous activity recorded before and after
%           (!) the trials
%
% %%%%% Optional Parameters %%%%%%%
%
% rfCenters: the central coordinates of the receptive field, if the spike
%        triggered average can be made smaller
% nonlin: this has to be one if the nonlinearity should be calculated,
%       otherwise it returns the error of the linear prediction (DEFAULT=0)
%
% The nonlineartiy is called generator signal in this script:
% references: Simoncelli et al. (2001)
% Henriette Walz 05/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%

% obligatory argument names
obligatoryArgs={'stimulus','psth', 'nTrials','responseEntities','mem','STA','frameDuration','trialDuration','baseDuration'};           % 'analogEntityIndex'};

% optional arguments names with default values
optionalArgs={'rfCenters','nonlin'};
nonlin=0;
rfCenters=[];

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

posEntityIDs=[];
for j=1:length(responseEntities)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==responseEntities(j))];
end

nonLinearity_tmp=cell(length(posEntityIDs),1);
nonLinearity_tmpmp=cell(length(posEntityIDs),1);
nonLinearity=cell(length(posEntityIDs),1);

for c=1:length(posEntityIDs)
    nUnits=size(psth{c},1);
    nonLinearity_tmp{c}=cell(nUnits,1);
    for nn=1:nUnits
        thisPSTH=squeeze(psth{c}(nn,baseDuration/frameDuration+1:end-baseDuration/frameDuration));
        %%resize if there is a rfCenter for it
        if ~isempty(rfCenters)
            stimSquared=reshape(stimulus,[size(stimulus,1) sqrt(size(stimulus,2)) sqrt(size(stimulus,2))]);
            stim2use=stimSquared(:,rfCenters{c}(nn,1,1)-2:rfCenters{c}(nn,1,1)+2,rfCenters{c}(nn,2,1)-2:rfCenters{c}(nn,2,1)+2);
            stim2use=reshape(stim2use,[size(stimulus,1) 25]);
            staSquared=reshape(STA{c},[size(STA{c},1), size(STA{c},2), sqrt(size(STA{c},3)),sqrt(size(STA{c},3))]);
            sta2use=staSquared(nn,:,rfCenters{c}(nn,1,1)-2:rfCenters{c}(nn,1,1)+2,rfCenters{c}(nn,2,1)-2:rfCenters{c}(nn,2,1)+2);
            sta2use=reshape(sta2use,[size(sta2use,2),prod([size(sta2use,3),size(sta2use,4)])]);
        else
            stim2use=stimulus;
            sta2use=squeeze(STA{c}(nn,:,:));
        end
        mem=size(sta2use,1);
        %%calculate generator signal now for this unit
        for y=mem:size(stim2use,1)
            genSignal(y,:)=stim2use(y-mem+1:y)*sta2use;
        end
        genSignalSum=sum(genSignal,2);
        %%%scale from 0 to 1
        genSignalSum=genSignalSum/max(genSignalSum)*max(thisPSTH);

        %% first find unique generator signals
        [uniqueGenSig,x,y]=unique(genSignalSum);
        %%now determine spike rate for all unique pixels
        sr=zeros(length(uniqueGenSig),1);


        for jj=1:length(uniqueGenSig)
            nTimes=length(find(y==jj)); %%how often this generator signal occured
            sr(jj)=sum(thisPSTH(find(y==jj)))/nTimes;
        end
        nonLinearity_tmp{c}{nn}=[uniqueGenSig,sr];

        figure;
        %plot nonlinearity
        subplot(2,1,1); plot(uniqueGenSig,sr); hold on
        title(sprintf('nonlinearity for unit number %2i of channel %2i',nn,c));
        xlabel('linear prediction');
        ylabel('spike rate');
        uGen(nn)=length(uniqueGenSig);
        linearPred{c}(nn,:)=genSignalSum;

        %%% plot linear prediction to psth
        time2plot=[frameDuration:frameDuration:frameDuration*(size(linearPred{c},2))];
        subplot(2,1,2); plot(time2plot,squeeze(linearPred{c}(nn,:)),'r',time2plot,squeeze(thisPSTH),'b') ;

        legend('linear prediction','psth')
        xlabel('frames')
        ylabel('spike rate in Hz')

        if length(thisPSTH)~=length(linearPred{c}(nn,:))
            error('linear prediction size mismatches size of psth')
        else
            linRMSE{c}(nn)=sum(sqrt((thisPSTH-linearPred{c}(nn,:)).^2))/length(linearPred{c}(nn,:));

            text('position',[1,max(thisPSTH)-0.1*(max(thisPSTH)),1],'string',sprintf('rmse=%f2.2',linRMSE{c}(nn)),'FontSize',12)
        end

        if nonlin
            %%% because matrices become quite big it has to do this in a loop
            for ii=mem:size(stim2use,1)
                predFiringRate{c}(nn,ii)=nonLinearity{c}(nn,(find(nonLinearity{c}(nn,:,1)==linearPred{c}(nn,ii))),2);
            end
            if length(thisPSTH)~=length(predFiringRate{c}(nn,:))
                error('prediction size mismatches size of psth')
            else
                nonRMSE=sum(sqrt((thisPSTH-predFiringRate{c}(nn,:)).^2))/length(linearPred{c}(nn,:));
                text('position',[1,max(thisPSTH)-0.1*(max(thisPSTH)),1],'string',sprintf('rmse=%f2.2',nonRMSE{c}(nn)),'FontSize',12)
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
    


    %%bring all units to the same size
    maxUGen=max(uGen);
    nonLinearity{c}=zeros(nUnits,maxUGen,2);
    for nn=1:nUnits
        q=maxUGen-uGen(nn);
        if q
            nonLinearity{c}(nn,:,:)=[zeros(1,nPixel,q,2);nonLinearity_tmp{c}{nn}]
        else
            nonLinearity{c}(nn,:,:)=nonLinearity_tmp{c}{nn};
        end
    end
end








    
    
    
    