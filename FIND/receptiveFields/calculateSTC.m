function [STC,RawSTC,RawMean]=calculateSTC(varargin)
% calculates spike triggered covariance and returns those filters where
% eigenvectors are significant if stated
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% stimulus: the stimulus matrix in Time X Space, 2-dim!
% 
% spikeTrain: the PSTH of the response binned at 1 ms
%
% response entities that are to be analyzed
% 
% STA: the spike triggered average in the same dimensions as the stimulus
%   (time X space)
%
% rfCenters: the center coordinates of the receptive field of the cells for the STA to be scaled down 
%
%%%%% Optional Parameters %%%%%%%%
% 
% ifRaw: if the STC of the raw stimulus has not been analyzed before, this
%   should be one
%
%
% Henriette Walz 03/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%


% obligatory argument names
obligatoryArgs={'stimulus','responseEntities','STA','rfCenters','trialDuration'};       

% optional arguments names with default values
optionalArgs={'ifRaw'};
ifRawv=0;

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);
maxRows=1600;
global nsFile

posEntityIDs=[];
neuralPosEntityIDs=[];
for j=1:length(responseEntities)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==responseEntities(j))];
    neuralPosEntityIDs=[neuralPosEntityIDs,find(nsFile.Neural.EntityID==responseEntities(j))];
end
eventPosEntityID=find(nsFile.Analog.DataentityIDs==eventID);


stim_s=size(stimulus);

stimSquared=reshape(stimulus,[stim_s(1) sqrt(stim_s(2)) sqrt(stim_s(2))]);
for ff=1:length(neuralPosEntityIDs);
    
    nUnits=length(nsFile.Segment.UnitID{ff});

    %%%%%%%raw stimulus covariance
    for nn=1:nUnits
        stimSmall=stimSquared(:,rfCenters{ff}(nn,1,1)-2:rfCenters{ff}(nn,1,1)+2,rfCenters{ff}(nn,2,1)-2:rfCenters{ff}(nn,2,1)+2);
        stimSmall=reshape(stimSmall,[stim_s(1) 25]);
        staSquared=reshape(STA{ff},[size(STA{ff},1) size(STA{ff},2) sqrt(size(STA{ff},3)) sqrt(size(STA{ff},3))]);
        staSmall=staSquared(nn,1,rfCenters{ff}(nn,1,1)-2:rfCenters{ff}(nn,1,1)+2,rfCenters{ff}(nn,2,1)-2:rfCenters{ff}(nn,2,1)+2);
        
        edges=0:0.001:trialDuration;
        responseIDX=zeros(nTrials,trialDuration*1000);
        for oo=1:length(nsFile.Event.TimeStamp{eventPosEntityID})
            tsp=sp(sp>nsFile.Event.TimeStamp{eventPosEntityID}(oo)&sp<nsFile.Event.TimeStamp{eventPosEntityID}(oo)+trialDuration);
            tmp_idx=histc(tsp,edges+onsets(oo)/sr);
            responseIDX(oo,:)=tmp_idx(1:end-1);
        end
        spikeTrain=sum(responseIDX)/length(nsFile.Event.TimeStamp{eventPosEntityID});
        STC_temp=zeros(size(stimSmall,2));
        RawMean=zeros(size(stimSmall,2),1);
        RawSTC=zeros(size(stimSmall,2));
        
        thisSTE=[];
        for j=1:stim_s(1)
            ntimes=round(spikeTrain(j));
            for p=1:ntimes
                thisSTE =[thisSTE; stimSmall(j,:)];
            end
        end

        for ii=1:stim_s(1)/maxRows
            RawMean = RawMean + sum(stimSmall((ii-1)*maxRows+1:ii*maxRows,:))';
            RawSTC = RawSTC + stimSmall((ii-1)*maxRows+1:ii*maxRows,:)'*stimSmall((ii-1)*maxRows+1:ii*maxRows,:);

            STC_temp=STC_temp+thisSTE'*thisSTE;
        end

        numberSpikes=sum(spikeTrain);
        RawMean=RawMean/stim_s(1);
        RawSTC = RawSTC/(stim_s(1)-1)-RawMean'*RawMean*stim_s(1)/(stim_s(1)-1);
        STC(ff,nn,:,:)=STC_temp/(numberSpikes-1)-reshape(staSmall,[size(staSmall,3)^2,1])'*reshape(staSmall,[size(staSmall,3)^2,1])*numberSpikes/(numberSpikes-1);
        
        [v,d] = eig(squeeze(STC(ff,nn,:,:)));
        
        figure;
        plot(diag(d));
        title('eigenvalues of stc matrix')
        xlabel('number of eigenvalue')
        
        h=figure;
        set(h,'name','eigenvector')
        imagesc(reshape(v(:,1),[5,5]));
        cmap=[zeros(10,1) , [1:-0.1:0.1]' ,zeros(10,1);[0.1:0.1:1]', zeros(10,1),zeros(10,1)];
        colormap(cmap);
        colorbar;
    end
end



















