function [pInd,pAmp]=correlatePsthSac(varargin)
% plots the peak in the psth to the length of the corresponding saccade.
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% Time: of saccades in bins of the size as the psth bins
% Dist: Euclidean Distance of moved image
% PSTH: of the response
% responseEntity: the entity for which this should be analyzed
%
% %%%% Optional Parameters %%%%
%
% 
% Henriette Walz 06/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de



% obligatory argument names
obligatoryArgs={'Time','Dist','PSTH','responseEntities'};  

% optional arguments names with default values
optionalArgs={'trialDuration','baseDuration','kernelSize'};
trialDurationS=10;
baseDurationS=1;
kernelSize=30;

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
neuralPosEntityIDs=[];
for j=1:length(responseEntities)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==responseEntities(j))];
    neuralPosEntityIDs=[neuralPosEntityIDs,find(nsFile.Neural.EntityID==responseEntities(j))];
end

for c=neuralPosEntityIDs
    nUnits=size(PSTH{find(neuralPosEntityIDs==c)},1);
    for nn=1:nUnits
    binSizeS=(trialDurationS+2*baseDurationS)/size(PSTH{find(neuralPosEntityIDs==c)},3);
    kernelWin=window(@triang,kernelSize);
    psth=conv(squeeze(PSTH{find(neuralPosEntityIDs==c)}(nn,:,:)),kernelWin);
    psth=psth(kernelSize/2:end-kernelSize/2)/sum(kernelWin);
    for j=1:length(Time)
        thisPsth=psth(Time(j):Time(j)+150/binSizeS/1000);  %%check 50 ms
        tmp_peaks=find(thisPsth==max(thisPsth));
        peaks(j)=tmp_peaks(1)+Time(j);
    end
    h1=figure;
    time2plot=[binSizeS:binSizeS:(trialDurationS+2*baseDurationS)];
    plot(time2plot,psth,'color',[0.6 0.6 0.6])
    hold on
    plot([time2plot(Time); time2plot(Time)],[zeros(1,length(Time)); max(psth)*ones(1,length(Time))],'k','LineWidth',1.3)
    plot(time2plot(peaks),squeeze(psth(peaks)),'r*');
    title('psth to natural stimulus');xlabel('time [s]');ylabel('firingrate [Hz]');
    k=findobj('Type','Line','Color','black');
    r=findobj('Type','Line','Color','red');
    b=findobj('Type','Line','Color',[0.6 0.6 0.6]);
    legend([k(1),r(1),b(1)],'sacc.','peak','psth');
    pInd{find(neuralPosEntityIDs==c)}(nn,:)=peaks;
    pAmp{find(neuralPosEntityIDs==c)}(nn,:)=time2plot(peaks);
    pLat{find(neuralPosEntityIDs==c)}(nn,:)=peaks-Time;
    h2=figure;plot(Dist,squeeze(pAmp{find(neuralPosEntityIDs==c)}(nn,:)),'k*');
    title('correlation size of saccade and psth');xlabel('euclidean distance [pixel]');ylabel('firingrate [Hz] of peak');
    h3=figure;plot(Dist,squeeze(pLat{find(neuralPosEntityIDs==c)}(nn,:)),'k*');
    title('correlation size of saccade and latency');xlabel('euclidean distance [pixel]');ylabel('latency of peak [ms]');
    xlim([0 12]);
    end
    
end
        





