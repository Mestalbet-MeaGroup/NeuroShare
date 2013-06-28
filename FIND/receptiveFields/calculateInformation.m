function [Iss, S, kurt, Ibin, Isec,Ispike, Bias,E]=calculateInformation(varargin);  
% calculates information measures information per bins, information per second, information per spike, bias  
%
% Iss is the information per single spike (see Butts, 2007) just from the
% psth. S is Sparseness as the scaled activity fraction, kurt is the kurtosis. 
% Ibin is the information per bin, Isec same divided by the duration of the 
% bins, Ispike divided by the mean number of spikes inside bins.
%
%
% Parameters to be passed as parameter-value pairs:
%
% %% Obligatory Parameters
% 
% analogEntityIDs
%
% %% Optional Parameters
%
% trialDurationT: in seconds
% frameDuration: in seconds
% delta: time resolution inside bins for information calculation in seconds
% T: time of whole bins
% rep: how many times the stimulus iterates during one trial (in the case
% of a drifting grating for example)


% obligatory argument names
obligatoryArgs={'analogEntityIDs'};           

% optional arguments names with default values
optionalArgs={'trialDurationT','frameDurationT','delta','T','rep','sparse','baseDuration','preferredOri','nTrials'};
trialDurationT=9;
frameDurationT=0.0066667;
delta=0.0066667;
baseDuration=0;
T=0.0066667;
sparse=1;
info=1;
rep=1;
preferredOri=[];
nTrials=10;
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



posNeural=[];
posAnalog=[];
for t=1:length(analogEntityIDs)
    posNeural=[posNeural,find(nsFile.Neural.EntityID==analogEntityIDs(t))];
    posAnalog=[posAnalog,find(nsFile.Analog.DataentityIDs==analogEntityIDs(t))];
end

Ibin=cell(1,length(analogEntityIDs));
Isec=cell(1,length(analogEntityIDs));
Ispike=cell(1,length(analogEntityIDs));
Bias=cell(1,length(analogEntityIDs));
S=cell(1,length(analogEntityIDs));
kurt=cell(1,length(analogEntityIDs));
Iss=cell(1,length(analogEntityIDs));
E=cell(1,length(analogEntityIDs));
if ~isempty(posNeural)
for c=1:length(analogEntityIDs)
    nUnits=unique(nsFile.Segment.UnitID{posNeural(c)});
    for n=1%:nUnits
        sr=nsFile.Analog.Info(posAnalog(c)).SampleRate;
         if length(preferredOri)
            onsets=nsFile.Event.Data((preferredOri{c}(n)-1)*nTrials+1:preferredOri{c}(n)*nTrials);
            sp=nsFile.Neural.Data{c}(find(nsFile.Segment.UnitID{c}==n));
            theseSpikes=sp(sp>onsets(1)/sr&sp<(onsets(end)/sr+trialDurationT));
         else
             onsets=nsFile.Event.Data;
            theseSpikes=nsFile.Neural.Data{posNeural(c)}(find(nsFile.Segment.UnitID{posNeural(c)}==n));
        end
        trialDurationS=trialDurationT*sr/rep;
        nTrials=length(onsets)*rep;
        onsetsT=[];
        for yy=1:length(onsets)
            onsetsT=[onsetsT,onsets(yy),onsets(yy)+[1:(rep-1)]*trialDurationS];
        end
        %%% make psth on ms resolution
        edges=0.001:0.001:trialDurationT/rep;
        responseIDX=zeros(length(onsetsT),trialDurationT/rep*1000);
        for xy=1:length(onsetsT)
            tsp=theseSpikes(theseSpikes*sr>onsetsT(xy)&theseSpikes*sr<(onsetsT(xy)+trialDurationS))-onsetsT(xy)/sr;
            if ~isempty(tsp)
                responseIDX(xy,:)=histc(tsp,edges);
            end
        end
        psth=sum(responseIDX);



        %         for nT=1:length(onsetsT)
        %             tmp=round((theseSpikes(theseSpikes>onsetsT(nT)/sr&theseSpikes<onsetsT(nT)/sr+trialDurationT)-onsetsT(nT)/sr)*1000)+1;
        %             psth(tmp)=psth(tmp)+1;
        %             responseIDX(nT,tmp)=1;
        %         end


        %%% now Iss
        psth=psth/length(onsetsT);
        normPSTH=psth/mean(psth);
        Iss{c}(n)=mean(psth)*sum(normPSTH(find(normPSTH))./log2(normPSTH(find(normPSTH))));


        %%%calculate sparseness
        %%%first bin the psth to the frame refresh rate
        if sparse
            edgesFr=0:frameDurationT:trialDurationT/rep;
            idx_2frame=zeros(length(edgesFr),nTrials);
            for nt=1:nTrials
                tmp_theseSpikes=theseSpikes(theseSpikes>onsetsT(nt)/sr&theseSpikes<(onsetsT(nt)/sr+trialDurationT/rep))-onsetsT(nt)/sr;
                if ~isempty(tmp_theseSpikes)

                t_psth2frame=histc(tmp_theseSpikes,edgesFr);
                idx_2frame(:,nt)=t_psth2frame;
                end
            end
            psth2frame=sum(idx_2frame,2)/nTrials;
            S{c}(n)=(1-(mean(psth2frame).^2/(mean(psth2frame).^2+std(psth2frame).^2)))/(1-(1/length(psth2frame)));
            kurt{c}(n)=kurtosis(psth2frame);
        end

        if info
            %%%% mutual information
            %%% construct bins of delta t
            wL=T/delta;
            if wL==1
                nt=[round(nTrials/5),round(nTrials/4),round(nTrials/2),nTrials];
                for ntx=1:length(nt)
                    ntt=nt(ntx);
                    edgesInfo=0:delta:trialDurationT*1000/rep;
                    idxBins=zeros(ntt,length(edgesInfo));
                    for uu=1:ntt
                        
                        tmp_wholeBins=theseSpikes(theseSpikes*sr>onsetsT(uu)&theseSpikes*sr<(onsetsT(uu)+trialDurationT*sr))*sr-onsetsT(uu);
                        if ~isempty(tmp_wholeBins)
                        idxBins(uu,:)=histc(tmp_wholeBins,edgesInfo);
                    
                        end
                    end
                     wholeBins=reshape(idxBins,[1,size(idxBins,1)*size(idxBins,2)]);
                    allWords=unique(wholeBins);
                    pr=zeros(1,length(allWords));
                    for w=1:length(allWords)
                        pr(w)=length(find(wholeBins==allWords(w)))/length(wholeBins);
                        HHr(w)=pr(w)*log2(pr(w));
                    end
                    N=length(wholeBins);
                    biasHr=-1/(2*N*logm(2))*(length(find(wholeBins))-1);


                    for ww=1:size(idxBins,2)
                        theseWords=idxBins(:,ww);
                        theseWordsU=unique(theseWords);
                        prs=zeros(1,length(theseWordsU));
                        for yy=1:length(theseWordsU)
                            prs(yy)=length(find(theseWords==theseWordsU(yy)))/ntt;
                            tmp_HHrs(yy)=prs(yy)*log2(prs(yy));
                        end
                        Rs(ww)=length(find(theseWords));
                        %RS(ww)=bayescount(ntt,cc);
                        HHrs(ww)=sum(tmp_HHrs);
                        clear prs tmp_HHrs
                    end
                    %biasHrs=-1/(2*N*logm(2))*sum(RS-1);
                    %tmp_Bias=biasHr-biasHrs;


                    tmp_Hr(ntx)=-sum(HHr);
                    tmp_Hrs(ntx)=-mean(HHrs);
                    tmp_Ibin(ntx)=tmp_Hr(ntx)-tmp_Hrs(ntx);

                    

                end
                
                cHr=nlinfit(nt,tmp_Hr,@infoHr,[1,1,1]);
                Hr{c}(n)=cHr(3);
                cHrs=nlinfit(nt,tmp_Hrs,@infoHr,[1,1,1]);
                Hrs{c}(n)=cHrs(3);
                Bias{c}(n)=0;%tmp_Bias;
                Ibin{c}(n)=Hr{c}(n)-Hrs{c}(n);
                Isec{c}(n)=Ibin{c}(n)/delta*sr;
                Ispike{c}(n)=Ibin{c}(n)/mean(wholeBins);
                E{c}(n)=Ibin{c}(n)/Hr{c}(n);
            else % if wL==1
            end
        end

        %%% total entropy

    end %nUnits

end

else % if ~isempty(posNeural)
Ibin{1}(1)=0;
Isec{1}(1)=0;
Ispike{1}(1)=0;
Bias{1}(1)=0;
S{1}(1)=0;
kurt{1}(1)=0;
Iss{1}(1)=0;
E{1}(1)=0;
end




