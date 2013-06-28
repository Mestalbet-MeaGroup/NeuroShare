function plotPSTH(varargin)
% function plotPSTH
% This visulaisation tool enables the user to estimate the spike rate by
% convoluting the spike train with a defined kernel.
% Using the option 'normalised' the max spike rate is normalised to 1.
% If different Units are present in the data the PSTHs are calculated
% separately for each. Otherwise for unsorted spikes an unique UnitID
% is assumed.
% (plotPSTH calls the function makeKernel.m)
%
% %%%%% Obligatory Parameters %%%%%
%
% 'neuronID'      : define Spikes to show using Segment.DataentityIDs or
%                   Neural.EntityID
% 'eventID'       : EntityID of the trigger
% 'KernelSize'    : define the standard deviation of the kernel
%                   distribution
%
%
% %%%%% Optional Parameters %%%%%
%
% 'selectedNorm'  : norm max spike rate to 1
% 'selectedKernel': choose kernel distribution ('BOX' as default)
%                   (BOX - boxcar, TRI - triangle, GAU - gaussian,
%                   EPA - epanechnikov, EXP - exponential,
%                   ALP - alpha function implemented)
% 'selectedDirect': aymmetric kernel forms assume paramter 'direction'
%                   (default 1 - right side)
%
%
% Notes:
%
% Example Call:
%   plotPSTH('neuronID',nsFile.Segment.DataentityIDs(1:3),...
%              'eventID',nsFile.Event.EntityID(3),...
%              'KernelSize',[0.01],'sectedNorm','normalised',...
%               'selectedDirect',(-1));
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%
% (1.1) A. Kilias, kilias@bccn.uni-freiburg.de 11/08.

global nsFile;

% obligatory argument names
obligatoryArgs={'neuronID','KernelSize'};

% optional arguments names with default values
optionalArgs={'selectedNorm','eventID','triggerNR','preTrigger','postTrigger',...
    {'selectedKernel', @(val) ismember(upper(val),{'BIN','BOX','TRI','GAU','EPA','EXP','ALP'})},...
    {'selectedDirect', @(val) ismember(val,[1,-1])}};


% set defaults
selectedNorm='Rate';
selectedKernel='BOX';
selectedDirect=1;
eventID=[];
triggerNR=[];
preTrigger=[0.01];
postTrigger=[0.1];

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,'');
end
pvpmod(varargin);

overview=1;
% check for event data
if ~isfield(nsFile,'Event') || ~isfield(nsFile.Event,'TimeStamp') ...
        ||  sum(cellfun(@isempty, nsFile.Event.TimeStamp))==size(nsFile.Event.TimeStamp,2) %all cells are empty
    %  error('FIND:missingEvents','Please load event data first or use preview function (BrowseEntities->Data).');
    triggers{1}=[];
elseif isempty(eventID)
    triggers{1}=[];
elseif ~isempty(eventID) && isempty(triggerNR)
    for pp=1:length(eventID)
        posEvents=find(nsFile.Event.EntityID==eventID(pp));
        triggers{pp}=nsFile.Event.TimeStamp{posEvents};
    end
else
    overview=0;
    for pp=1:length(eventID)
        posEvents=find(nsFile.Event.EntityID==eventID(pp));
        triggers{pp}=nsFile.Event.TimeStamp{posEvents};
    end
end

try
    clist=colormap(lines);

    if overview~=0
        % create for all unitIDs PSTH
        for ii=neuronID
            tempPos=[];
            Units=[];
            allSpikes=[];

            tempPos=find(nsFile.Segment.DataentityIDs==ii); % check for segment data
            if isempty(tempPos) % check for neural data
                tempPos=find(nsFile.Neural.EntityID==ii);
                Units=ones(size(nsFile.Neural.Data{tempPos}));
                if isempty(tempPos)
                    disp(['PSTH plotting for ID ',num2str(ii),'failed (missing data)']);
                    postMessage(['no PSTH for ID: ',num2str(ii), ' possible (missing data) ']);
                    continue;
                else
                    allSpikes=nsFile.Neural.Data{tempPos};
                end
            else
                allSpikes=nsFile.Segment.TimeStamp{tempPos};
                if length(unique(nsFile.Segment.UnitID{tempPos}))==1 && unique(nsFile.Segment.UnitID{tempPos})==0
                    Units=ones(size(nsFile.Segment.UnitID{tempPos}));
                else
                    Units=nsFile.Segment.UnitID{tempPos};
                end
            end

            %% collect spikes
            nUnits=length(unique(Units));% assumes continuity within units
            scrsz = get(0,'ScreenSize');
            if nUnits>2
                fh=figure('Name',['PSTH - neuronID',num2str(ii)],'NumberTitle','off','Position',[0 scrsz(4) scrsz(3) scrsz(4)]);
            else
                fh=figure('Name',['PSTH - neuronID',num2str(ii)],'NumberTitle','off');
            end

            if ~strcmp(selectedKernel,'BIN')
                for uu=1:nUnits
                    tmpSpikes=allSpikes(find(Units==uu),1);

                    subplot((nUnits+1),3,[1+3*(uu-1):3*uu]);

                    [k,norm,median_idx]=makeKernel('form',selectedKernel, ...
                        'sigma',KernelSize,'TimeStampResolution',nsFile.FileInfo.TimeStampResolution,...
                        'direction',selectedDirect);

                    spikeMS=round(tmpSpikes*1000);
                    tmpMat=zeros(max(spikeMS),1);
                    tmpMat(spikeMS)=1;
                    tmpMat=[zeros(length(k),1);tmpMat];
                    % + perform convolution, use Matlab's 'filter' or 'conv'
                    % -> with 'filter' : padd sufficient number of zeros at end of input vector
                    % -> for 'filter' the convention is causal. The filter shape is prepared for
                    % use with 'filter' or 'conv' since MATLAB conv is using filter. Note: older
                    % versions of Matlab had different definitions for zero padding in filter
                    % and conv.
                    r=filter(k,1,tmpMat)*norm;
                    % discard first length(kernel)-1 elements which considered zero
                    % entries (border effect)
                    r=r(length(k):end);
                    if strcmp(selectedNorm,'normalised')
                        r=r./max(r);
                    end

                    t=((1:length(r))./1000);
                    ph=plot(t,r,'k');
                    hold on;
                    title({['NeuronID: ',num2str(ii),' - UnitID: ',num2str(uu)]});
                    set(gca,'linewidth',.5,'fontsize',10);
                    set(gca,'box','on','tickdir','in');
                    ylabel('spike rate [1/s]');
                    xlabel('time [s]','Position',[max(t),-0.6,0],'FontSize',10);
                    hold on;

                    for tt=1:length(eventID)
                        plot(triggers{tt},ones(length(triggers{tt}),1)*tt*(-0.05),...
                            'Marker','o','LineStyle','none','MarkerSize',4,'MarkerFaceColor',clist(tt+1,:));
                        legStr{tt}=num2str(eventID(tt));
                        hold on;
                    end

                    if strcmp(selectedNorm,'normalised')
                        ylabel('normal. rate');
                        ylim([(-0.05*tt)-0.05 1.05]);
                    else
                        ylabel('spike rate [1/s]');
                        ylim([(-(1/20)*max(r)) (max(r)+((1/20)*max(r)))]);
                    end

                end

                subplot((nUnits+1),3,3*(nUnits+1)-1);
                plot(((1:length(k))*nsFile.FileInfo.TimeStampResolution),k,'k');
                title({['Kernel : ', selectedKernel]});
                xlabel('KernalSize [ms]');
                axis tight;

                subplot((nUnits+1),3,3*(nUnits+1)-2);

                for hh=1:length(eventID)
                    plot(0.3,hh,...
                        'Marker','o','LineStyle','none','MarkerSize',4,'MarkerFaceColor',clist(hh+1,:));
                    text(0.4, hh, {['EventID : ',num2str(eventID(hh))]});
                    hold on;
                end
                text(0.4, hh+1,'Trigger Legend','FontWeight','bold');
                ylim([0.5 length(eventID)+1.5]);
                xlim([0.2 1]);
                axis off;


            else
                for uu=1:nUnits
                    tmpSpikes=allSpikes(find(Units==uu),1);

                    subplot(nUnits,1,uu);

                    % bin with ms precision:
                    TIME_VEC=[0:KernelSize*1000:max(tmpSpikes)*1000+1];
                    spVec=histc(tmpSpikes*1000,TIME_VEC);

                    if strcmp(selectedNorm,'normalised')
                        spVec=spVec./max(spVec);
                    end
                    bar(TIME_VEC./1000,spVec);

                    title({['NeuronID: ',num2str(ii),' - UnitID: ',num2str(uu)]});
                    set(gca,'linewidth',.5,'fontsize',10);
                    set(gca,'box','on','tickdir','in');
                    hold on;
                    xlim([0 max(TIME_VEC)/1000+(max(TIME_VEC)/20000)]);
                    for tt=1:length(eventID)
                        plot(triggers{tt},ones(length(triggers{tt}),1)*tt*(-0.05),...
                            'Marker','o','LineStyle','none','MarkerSize',4,'MarkerFaceColor',clist(tt+1,:),'MarkerEdgeColor',clist(tt+1,:));
                        legStr{tt}=num2str(eventID(tt));
                        hold on;
                        if strcmp(selectedNorm,'normalised')
                            ylabel('normal. rate');
                            ylim([(-0.05*tt)-0.05 1.05]);
                            xlabel('time [s]','Position',[max(TIME_VEC)/1000,-0.02,0],'FontSize',10);
                        else
                            ylabel('spike rate [1/s]');
                            ylim([(-(1/20)*max(spVec)) (max(spVec)+((1/20)*max(spVec)))]);
                            xlabel('time [s]','Position',[max(TIME_VEC)/1000,(-0.05*tt)-0.5,0],'FontSize',10);
                        end
                    end
                end
            end
        end


        %%%%%%%%%%%%%%%%%%% calculate PSTH for selected trigger %%%%%%%%%%%%%%%%%%%
    else

        % create for all trigger channels for all unitIDs rasterplots
        for kk=eventID
            for ii=neuronID
                h=[];
                neuralData=0;
                eventData=0;
                Units=[];
                allSpikes=[];

                tempPos=find(nsFile.Segment.DataentityIDs==ii); % check for segment data
                if isempty(tempPos) % check for neural data
                    tempPos=find(nsFile.Neural.EntityID==ii);
                    Units=ones(size(nsFile.Neural.Data{tempPos}));
                    if isempty(tempPos)
                        disp(['PSTH plotting for ID ',num2str(ii),'failed (missing data)']);
                        postMessage(['no PSTH for ID: ',num2str(ii), ' possible (missing data) ']);
                        continue;
                    else
                        allSpikes=nsFile.Neural.Data{tempPos};
                    end
                else
                    allSpikes=nsFile.Segment.TimeStamp{tempPos};
                    if length(unique(nsFile.Segment.UnitID{tempPos}))==1 && unique(nsFile.Segment.UnitID{tempPos})==0
                        Units=ones(size(nsFile.Segment.UnitID{tempPos}));
                    else
                        Units=nsFile.Segment.UnitID{tempPos};
                    end
                end

                %% collect spikes
                nUnits=length(unique(Units));% assumes continuity within units
                scrsz = get(0,'ScreenSize');
                if nUnits>2
                    fh=figure('Name',['PSTH - neuronID',num2str(ii)],'NumberTitle','off','Position',[0 scrsz(4) scrsz(3) scrsz(4)]);
                else
                    fh=figure('Name',['PSTH - neuronID',num2str(ii)],'NumberTitle','off');
                end

                if ~strcmp(selectedKernel,'BIN')
                    for uu=1:nUnits
                        spikes=allSpikes(find(Units==uu),1);
                        tmpMat=zeros((preTrigger+postTrigger)*1000,1);
                        for pp=1:length(triggerNR)
                            triggerP=[];
                            posEvents=find(nsFile.Event.EntityID==kk);
                            triggerP=nsFile.Event.TimeStamp{posEvents}(triggerNR(pp));
                            tmpSpikes=[];
                            in_window=(spikes - triggerP> - preTrigger) +( spikes - triggerP< postTrigger) ;
                            tmpSpikes=spikes(find(in_window==2))-triggerP+preTrigger; % all spikes around the trigger subsummed. 0 denotes pretrigger onset.
                            spikeMS=round(tmpSpikes*1000);
                            tmpMat(spikeMS)=tmpMat(spikeMS)+1;
                        end

                        [k,norm,median_idx]=makeKernel('form',selectedKernel, ...
                            'sigma',KernelSize,'TimeStampResolution',nsFile.FileInfo.TimeStampResolution,...
                            'direction',selectedDirect);
                        tmpMat=[zeros(length(k),1);tmpMat];
                        r=filter(k,1,tmpMat)*(norm/1000);
                        r=r(length(k):end);

                        if strcmp(selectedNorm,'normalised')
                            r=r./max(r);
                        end

                        subplot((nUnits+1),3,[1+3*(uu-1):3*uu]);
                        t=(-preTrigger:(postTrigger+preTrigger)/(length(r)-1):postTrigger);
                        ph=plot(t,r,'k');
                        hold on;
                        title({['NeuronID: ',num2str(ii),' - UnitID: ',...
                            num2str(uu)];[ 'min TriggerNr: ', num2str(min(triggerNR)),...
                            ' -  max TriggerNr: ',num2str(max(triggerNR))]});
                        set(gca,'linewidth',.5,'fontsize',10);
                        set(gca,'box','on','tickdir','in');
                        ylabel('spike rate [1/s]');
                        xlabel('time [s]','Position',[max(t),-0.6,0],'FontSize',10);
                        hold on;

                    end

                    subplot((nUnits+1),3,3*(nUnits+1)-1);
                    plot(((1:length(k))*nsFile.FileInfo.TimeStampResolution),k,'k');
                    title({['Kernel : ', selectedKernel]});
                    xlabel('KernalSize [ms]');
                    axis tight;
                else
                    for uu=1:nUnits
                        spikes=allSpikes(find(Units==uu),1);
                        tmpMat=zeros((preTrigger+postTrigger)*1000,1);
                        tmpSpikes=[];
                        for pp=1:length(triggerNR)
                            triggerP=[];
                            posEvents=find(nsFile.Event.EntityID==kk);
                            triggerP=nsFile.Event.TimeStamp{posEvents}(triggerNR(pp));

                            in_window=(spikes - triggerP> - preTrigger) +( spikes - triggerP< postTrigger) ;
                            tmpSpikes=[tmpSpikes;[spikes(find(in_window==2))-triggerP+preTrigger]]; % all spikes around the trigger subsummed. 0 denotes pretrigger onset.
                        end

                        subplot(nUnits,1,uu);
                        % bin with ms precision:
                        TIME_VEC=[0:KernelSize*1000:(postTrigger+preTrigger)*1000+1];
                        spVec=histc(tmpSpikes*1000,TIME_VEC);

                        if strcmp(selectedNorm,'normalised')
                            spVec=spVec./max(spVec);
                        else
                            spVec=spVec./numel(triggerNR);
                        end

                        bar(-preTrigger:(preTrigger+postTrigger)/(length(spVec)-1):postTrigger,spVec);

                        title({['NeuronID: ',num2str(ii),' - UnitID: ',...
                            num2str(uu)];[ 'min TriggerNr: ', num2str(min(triggerNR)),...
                            ' -  max TriggerNr: ',num2str(max(triggerNR))]});
                        set(gca,'linewidth',.5,'fontsize',10);
                        set(gca,'box','on','tickdir','in');
                        if strcmp(selectedNorm,'normalised')
                            ylabel('norm. spike rate [1/s]');
                        else
                            ylabel('spike rate [1/s]');
                        end
                        xlabel('time [s]','FontSize',10);
                        hold on;
                        xlim([-preTrigger postTrigger]);
                    end
                end
            end
        end
    end
catch
    rethrow(lasterror)
end