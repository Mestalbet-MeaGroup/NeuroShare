function [rel,relFrac,Prec,PrecFirst,PrecHalf,XcorrWidth, CorrCoef,FFevents,FF]=calculateReliability(varargin);
% calculates the reliability and precision of a response according to the
% methods used in Mainen and Seijnowski (1995) and Kumbhani et al. (2007)
% Returns negative values if no events are recognized!!!
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% eventEntity: the analog index of the entity in event
% responseEntities: the analog index of the entity in neural which is to be
%   analyzed 
%
% %%%% Optional Parameters %%%%
%
% threshFactor: the factor with which the mean spike rate is multiplied to
%   determine events, if zero, events are seperated by n points of
%   zero activity, n is determined in baseLine
% if threshFactor is set as 0, baseLine: the number of baseline points which seperate events
% preferredOri: If the data is in response to drifting gratings of different orientation, this is the number of the orientation to which the response was biggest (example: unit 1 of entity 1 responded most to orientation No. 5, unit 2 to 6, this would be pO{1}=[5,6])
% nTrials: number of trials the stimulation was done. For drifting gratings how often each orientation was presented.
% kernelSize: size of kernel with which the psth is smoothed for calculating events and plotting (in sample points).
% baseDuration: time of baseline activity without stimulation before and after stimulus presentation (in sec)
% trialDuration: time of stimulation in sec.
% ifplot: if 1, the psth with raster plots on top is plotted.
% timeWindows: the size of the sliding windows over which the fano factor is calculated
% The following parameters determine whether certain calculations are performed or not. If they are set 1, this means:
% events: events are calculated and all measures depending on events.
% width: the width of the mean crosscorrelation between trials is calculated, i.e. the time at which a fitted exponential decay reaches 1/e times its maximum.
% correlationCoefficient: The mean correlation coefficient between any combination of trials is calculated
% reliability: The mean inner productbetween any combination of trials in calculated and multiplied by 100, so percentage data!
% fanoFactor: the fano factor in different sizes of sliding windows is calculated
%
% Henriette Walz
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


% obligatory argument names
obligatoryArgs={'eventEntity','responseEntities'};

% optional arguments names with default values
optionalArgs={'threshFactor','preferredOri','kernelSize','baseDuration','trialDuration','baseLine','ifplot','timeWindows',...
    'events','width','correlationCoefficient','reliability','fanoFactor','nTrials','xcorrCut'};

threshFactor=0;
preferredOri=[];
nTrials=10;
kernelSize=50;
baseDuration=0;
trialDuration=9;
baseLine=20;
ifplot=1;
timeWindows=[1,5,10,25,50,250,500,1000,3000,9000];
events=1;
width=1;
correlationCoefficient=1;
reliability=1;
fanoFactor=1;
xcorrCut=100;
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

%find position IDs of analog entities.
posEntityIDs=[];
neuralPosEntityIDs=[];
for j=1:length(responseEntities)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==responseEntities(j))];
    neuralPosEntityIDs=[neuralPosEntityIDs,find(nsFile.Neural.EntityID==responseEntities(j))];
end
eventPosEntityID=find(nsFile.Analog.DataentityIDs==eventEntity);

Prec=cell(length(posEntityIDs),1);
PrecFirst=cell(length(posEntityIDs),1);
PrecHalf=cell(length(posEntityIDs),1);
FFevents=cell(length(posEntityIDs),1);
CorrCoef=cell(length(posEntityIDs),1);
XcorrWidth=cell(length(posEntityIDs),1);
rel=cell(length(posEntityIDs),1);
kernelWin=window(@triang,kernelSize);
stdFirstSpikeInEvent=cell(length(posEntityIDs));
FF=cell(length(responseEntities),1);
relFrac=cell(length(posEntityIDs),1);
for c=neuralPosEntityIDs
    cInd=find(c==neuralPosEntityIDs);
    nUnits=1;%length(unique(nsFile.Segment.UnitID{c}));
    for n=1:nUnits
        sr=nsFile.Analog.Info(posEntityIDs).SampleRate;
        if length(preferredOri)
            onsets=(nsFile.Event.TimeStamp{eventPosEntityID}((preferredOri{c}(n)-1)*nTrials+1:preferredOri{c}(n)*nTrials)).*sr;
            sp=nsFile.Neural.Data{c}(find(nsFile.Segment.UnitID{c}==n));
            sp=sp(sp>onsets(1)/sr-baseDuration&sp<(onsets(end)/sr+(trialDuration+2*baseDuration)));
        else
            onsets=nsFile.Event.TimeStamp{eventPosEntityID};
            sp=nsFile.Neural.Data{c}(find(nsFile.Segment.UnitID{c}==n));
        end
        edges2plot=0:0.001:trialDuration+2*baseDuration;
        responseIDX2plot=zeros(nTrials,(trialDuration+2*baseDuration)*1000);
        edges=0:0.001:trialDuration;
        responseIDX=zeros(nTrials,trialDuration*1000);
        for oo=1:length(onsets)
            % for plotting the baseline activity is taken as well, therefore calculation of a psth for plotting seperately
            tsp2plot=sp(sp>(onsets(oo)/sr-baseDuration)&sp<onsets(oo)/sr+trialDuration+2*baseDuration);
            tmp_idx2plot=histc(tsp2plot,(edges2plot+onsets(oo)/sr-baseDuration));
            responseIDX2plot(oo,:)=tmp_idx2plot(1:end-1);
            tsp=sp(sp>onsets(oo)/sr&sp<onsets(oo)/sr+trialDuration);
            tmp_idx=histc(tsp,edges+onsets(oo)/sr);
            responseIDX(oo,:)=tmp_idx(1:end-1);
        end
        PSTH2plot=sum(responseIDX2plot)*1000/nTrials;
        PSTH=sum(responseIDX)*1000/nTrials;

        if events
            nTrials=size(responseIDX,1);
            %%find 'events'
            if threshFactor
                smoothedPSTH=conv(PSTH,kernelWin);
                smoothedPSTH=smoothedPSTH(kernelSize/2:end-kernelSize/2)/sum(kernelWin);
                maxPSTH=max(smoothedPSTH);
                Threshold=threshFactor*maxPSTH;
                temp=smoothedPSTH>Threshold;
                eventBeginnings{n}=find(diff([0,temp])==1);
                eventEndings{n}=find(diff([temp,0])==-1);
            elseif threshFactor==0
                smoothedPSTH=conv(PSTH,kernelWin);
                smoothedPSTH=smoothedPSTH(kernelSize/2:end-kernelSize/2)/sum(kernelWin);
                Threshold=0.4*max(smoothedPSTH);
                temp=find([smoothedPSTH,1]);
                tmpDiff=diff(temp);
                base=find(tmpDiff>baseLine);
                tmp_eventBeginnings{n}=temp(base(1:end-1)+1);
                tmp_eventEndings{n}=temp(base(2:end));
                if tmp_eventBeginnings{n}(end)==(length(smoothedPSTH)+1)
                    tmp_eventBeginnings{n}=tmp_eventBeginnings{n}(1:end-1);
                elseif tmp_eventBeginnings{n}(end)~=(length(smoothedPSTH)+1)
                    tmp_eventEndings{n}=[tmp_eventEndings{n},length(smoothedPSTH)];
                end
                maxPSTH=max(smoothedPSTH);
                eventBeginnings{n}=[];
                eventEndings{n}=[];
                for o=1:length(tmp_eventBeginnings{n})
                    if max(smoothedPSTH(tmp_eventBeginnings{n}(o):tmp_eventEndings{n}(o)))>0.1*maxPSTH
                        eventEndings{n}=[eventEndings{n},tmp_eventEndings{n}(o)];
                        eventBeginnings{n}=[eventBeginnings{n},tmp_eventBeginnings{n}(o)];
                    end
                end

            end



            %%%now find spikes in events
            if length(eventBeginnings{n})~=length(eventEndings{n})
                error('the number of detected event beginnings does not equal the number of detected endings')
            end
            [spikesI,spikesJ]=find(squeeze(responseIDX));
            spikesIJ=find(squeeze(responseIDX));
            spikesInEvent=zeros(size(responseIDX,1),size(responseIDX,2));
            spikesInEvent(spikesIJ)=1;
            spikeCount=zeros(length(eventBeginnings{n}),size(responseIDX,1));
            stdSpikesInEvent=[];


            firstSpikes=[];
            for k=1:length(eventBeginnings{n})
                in_window=(spikesJ - eventBeginnings{n}(k)>=0) +(spikesJ <= eventEndings{n}(k)) ;
                spikesInEvent(spikesIJ(find(in_window==2)))=1+k;
                if find(in_window==2)
                    %%%Precision of first spike
                    theseSpikes=spikesJ(find(in_window==2));
                    theseSpikesTrials=spikesI(find(in_window==2));
                    for uu=1:nTrials
                        tmp_spikesPerTrial{uu}=theseSpikes(theseSpikesTrials==uu);
                    end
                    spikesPerTrial=cell2mat(tmp_spikesPerTrial);

                    medianInEvent=median(theseSpikes);
                    medianFirstHalf=median(theseSpikes(theseSpikes<medianInEvent));
                    medianSecondHalf=median(theseSpikes(theseSpikes>medianInEvent));
                    interquartileRange(k)=medianSecondHalf-medianFirstHalf;


                    %%%%reliability
                    spikeCount(k,:)=histc(spikesI(in_window==2),1:size(responseIDX,1));
                    meanSpikeCount(k)=mean(spikeCount(k,:));
                    varSpikeCount(k)=var(spikeCount(k,:));

                    tmp_std=0;
                    tj=0;
                    t=sort(unique(spikeCount(k,:)));
                    for y=1:length(t)
                        tj(y)=length(find(spikeCount(k,:)>=t(y)));
                    end

                    tmp_maxSpikeCount=t(tj>=0.5*10);
                    firstSpikes=[firstSpikes,spikesPerTrial(:,1)];
                    maxSpikeCount(k)=max(tmp_maxSpikeCount);
                    %%%first spike jitter
                    if maxSpikeCount(k)>0
                        stdFirstSpikeInEvent{n}(k)=std(spikesPerTrial(find(spikesPerTrial(:,1)),1));
                        stdSpikesInEvent=[stdSpikesInEvent,std(spikesPerTrial(find(spikesPerTrial)))];
                    end
                   
                   
                end
            end
            relFrac{n}=length(spikesInEvent>1)/length(spikesInEvent>0);
            if ifplot
                %plot to see if everything is fine

                h=figure;
                set(h,'name','events');
                smosmoothedPSTH=conv(PSTH2plot,kernelWin)/sum(kernelWin);
                a1=area(smosmoothedPSTH,'FaceColor',[0.4 0.4 0.4],'EdgeColor','none'); hold on
                ll=plot(squeeze(eventBeginnings{n}+baseDuration*1000),max(smoothedPSTH)/10*ones(length(eventBeginnings{n}),1),'g.',squeeze(eventEndings{n})+baseDuration*1000,max(smoothedPSTH)/10*ones(length(eventBeginnings{n}),1),'k.');

                %            title(['file from ',header,' psth and events of channel ',num2str(c),' and unit ',num2str(n)]);
                xlabel('time [ms]')
                ylabel('rate [Hz]')
                xlim([0 length(smoothedPSTH)]); hold on
                fac=max(smoothedPSTH)/nTrials;
                for q=1:size(spikesInEvent,1)
                    lh=plot([find(spikesInEvent(q,:)==1)+baseDuration*1000; find(spikesInEvent(q,:)==1)+baseDuration*1000],[ones(1,length(find(spikesInEvent(q,:)==1)))*fac*q ;ones(1,length(find(spikesInEvent(q,:)==1)))*q*fac+fac*0.5],'r');
                    ospJ=find(responseIDX2plot(q,:));
                    lh=[lh;plot([ospJ(ospJ<baseDuration*1000),ospJ(ospJ>(trialDuration+baseDuration)*1000); ospJ(ospJ<baseDuration*1000),ospJ(ospJ>(trialDuration+baseDuration)*1000)],[ones(1,length([find(ospJ<baseDuration*1000),ospJ(ospJ>(trialDuration+baseDuration)*1000)]))*fac*q ;ones(1,length([find(ospJ<baseDuration*1000),ospJ(ospJ>(trialDuration+baseDuration)*1000)]))*q*fac+fac*0.5],'r')];
                    hold on
                    lh1=plot([find(spikesInEvent(q,:)>1)+baseDuration*1000; find(spikesInEvent(q,:)>1)+baseDuration*1000],[ones(1,length(find(spikesInEvent(q,:)>1)))*fac*q; ones(1,length(find(spikesInEvent(q,:)>1)))*fac*q+0.5*fac],'k'); hold on
                    lh2=plot([firstSpikes(q,:)+baseDuration*1000;firstSpikes(q,:)+baseDuration*1000],[ones(1,size(firstSpikes,2))*q*fac; ones(1,size(firstSpikes,2))*q*fac+0.5*fac],'b'); hold on
                    
                end
                    if q==size(spikesInEvent,1)
                        if isempty(lh) & ~isempty(lh1)
                            legendh=legend([a1,ll(1),ll(2),lh1(end)],'PSTH','ev. beginnings','ev. endings','sp. in ev.')
                        elseif isempty(lh1) & ~isempty(lh)
                            legendh=legend([a1,ll(1),ll(2),lh],'PSTH','ev. beginnings','ev. endings','sp. outside ev.')
                        elseif isempty(lh1) & isempty(lh)
                        elseif ~isempty(lh1) & ~isempty(lh)
                            legendh=legend([a1,ll(1),ll(2),lh(end),lh1(end),lh2(end)],'PSTH','ev. beginnings','ev. endings','sp. outside ev.','sp. in ev.','first sp. in ev.');
                        end
                    end
                    set(legendh,'Location','SouthEastOutside','FontSize',9);
                if baseDuration
                    plot([baseDuration*1000 baseDuration*1000],[0 max(smoothedPSTH)],'m',[(baseDuration+trialDuration)*1000 (baseDuration+trialDuration)*1000],[max(smoothedPSTH) max(smoothedPSTH)],'m');
                end
                xlim([0 6000]);
%                 ylim([0 q+1]);
                xlabel('time [ms]')
                ylim([0 fac*nTrials])
                ylabel(['rate [Hz] / trials (n=',num2str(size(spikesInEvent,1)),')']);
            end

            %%%precision of all spikes


            if ~isempty(eventBeginnings{n}) & ~isempty(stdSpikesInEvent)
                Prec{cInd}(n)=mean(stdSpikesInEvent);
                PrecHalf{cInd}(n)=median(interquartileRange(find(interquartileRange>0)));
                PrecFirst{cInd}(n)=mean(stdFirstSpikeInEvent{n}(stdFirstSpikeInEvent{n}>=0));
                FFevents{cInd}(n)=mean(varSpikeCount./meanSpikeCount);
            else
                Prec{cInd}(n)=-1;
                PrecFirst{cInd}(n)=-1;
                FFevents{cInd}(n)=-1;
                PrecHalf{cInd}(n)=-1;
            end

        end

        if reliability % as inner product
            isi=diff(nsFile.Neural.Data{c})*1000;
            if ~isempty(isi)
                kernwin=gausswin(50,1/min(isi));
                for ll=1:nTrials
                    tmp_sp=conv(responseIDX(ll,:),kernwin);
                    respXC(ll,:)=tmp_sp(length(kernwin)/2:end-length(kernwin)/2)./sum(kernwin);
                end

                ij=0;
                for t=1:nTrials
                    if find(respXC(t,:))
                        for tt=(t+1):nTrials
                            if find(respXC(tt,:))
                                ij=ij+1;
                                tmp_xC(ij)=100*respXC(t,:)*respXC(tt,:)'/sqrt(sum(respXC(t,:).^2)*sum(respXC(tt,:).^2));

                            end
                        end
                    end
                end
                rel{cInd}(n)=mean(tmp_xC);
            else rel{cInd}(n)=0;
            end
        end

        %%%calculate correlation coefficient as a measure of precision
        if correlationCoefficient
            allCorrCoeff=[];
            nTrials=length(onsets);
            for t=1:nTrials
                for tt=(t+1):nTrials
                    if length(find(responseIDX(t,:))) & length(find(responseIDX(tt,:)))
                        ctmp =corrcoef(squeeze(responseIDX(t,:)),squeeze(responseIDX(tt,:)));
                        allCorrCoeff=[allCorrCoeff,ctmp(1,2)];
                    end
                end
            end
            CorrCoef{cInd}(n)=mean(allCorrCoeff);
        end
        %%%calculate crosscorrelation between all trials and the time lag
        %%%where the correlation decreases as a measure of precision and
        %%%the value at 0 divided by all spikes as a measure of
        %%%reliability.
        if width
            ij=0;
            for t=1:nTrials
                for tt=(t+1):nTrials
                    if length(find(responseIDX(t,:))) & length(find(responseIDX(tt,:)))

                        
                        [tmp1,tmp2]=xcorr(squeeze(responseIDX(t,:)),squeeze(responseIDX(tt,:)),xcorrCut,'coef');
                      
                        if isempty(find(isnan(tmp1)))
                            ij=ij+1;
                            C(ij,:)=tmp1;
                            lags(ij,:)=tmp2;
                        end
                    end
                end

            end
            xMean=mean(C,1);
            yMean=mean(lags,1);
            yPos=yMean(find(yMean>=0));
            xPos=xMean(find(yMean>=0));
            try
            beta = nlinfit(yPos,xPos,@expDec,[ 1 1 1]);
            xModel=expDec(beta,yPos);
            halfTime1=find(xModel<(1/exp(1)*max(xModel)));
            halfTime=halfTime1(1);
            if ifplot
                figure; plot(yMean,xMean,'b.',yPos,xModel,'k','LineWidth',2);hold on
                plot([halfTime halfTime],[0 max(xModel)],'r');
                title('mean crosscorrelation between trials');
                xlabel('lag in sample points');
                ylabel('value of crosscorrelation')
                legend('crosscorrelation','normpdf fit','sigma of normpdf fit');
            end
            XcorrWidth{cInd}(n)=halfTime;
            catch
                XcorrWidth{cInd}(n)=NaN;
            end
        end

        %%%%calculate the fano factor in different sizes of a sliding
        %%%%window (sigma^2/mu)
        if fanoFactor
            FF{cInd}=zeros(length(timeWindows),1);
            for tw=1:length(timeWindows)
                mu=[];
                vari=[];
                idxFiltered=zeros(size(responseIDX,2)-timeWindows(tw)+1,size(responseIDX,1));
                %%% to slide in 1 ms steps
                for ii=1:size(responseIDX,1)
                    thisIDX=squeeze(responseIDX(ii,:));
                    tmp_idxFiltered=conv(thisIDX,ones(timeWindows(tw),1));
                    idxFiltered(:,ii)=tmp_idxFiltered(floor(timeWindows(tw)/2)+timeWindows(tw):end-ceil(timeWindows(tw)/2)+1);
                end
                mu=[mu,mean(idxFiltered')];
                vari=[vari,var(idxFiltered')];

                FFall(find(mu))=vari(find(mu))./mu(find(mu));
                
                FF{cInd}(tw)=mean(FFall(find(mu)));

            end

        end
    end



end





