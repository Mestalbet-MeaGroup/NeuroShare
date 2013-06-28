function h=rasterPlot(varargin)
% function h=rasterPlot(varargin);
% This plot functions can be used for spike trains/trials given by 
% nsFile.Neural.Data or by nsFile.Segment.TimeStamps. 
% The spikes are plotted with respect to their occurence after a trigger. 
% Further it is possible to refer spike trains to different stimuli sets. 
% If spikes are assined to Units there will be plots for every single unit.
% Otherwise one single unit is assumed.
%
% Recapitulating the function rasterPlot proviedes plots for each spike 
% train (Segment.TimeStamp or Neural.Data) of each discerned Unit 
% (Segment.UnitID) for each trigger set (Event.TimeStamp).
%
% %%%%% Obligatory Parameters %%%%%
%
% 'neuronID'    : Which Spikes to show
% 'eventID'     : Triggers for the trials used from this event
% 'preTrigger'  : show time before trigger (in seconds)
% 'postTrigger' : show time after trigger (in seconds)
%
% returns:
% h : a vector of handles to the figures plotted.
%
% Notes:
% 
% Example Call:
%   rasterPlot('neuronID',nsFile.Segment.DataentityIDs(1:3),...
%              'eventID',nsFile.Event.EntityID(3),...
%              'preTrigger',[0.1],'postTrigger',[0.8]);
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%
% (0) R. Meier, meier@biologie.uni-freiburg.de
% (1.1) A. Kilias, kilias@bccn.uni-freiburg.de 11/08

global nsFile;

% this function requires different units and single trigger

% obligatory argument names
obligatoryArgs={'neuronID','eventID','preTrigger','postTrigger'};

% optional arguments names with default values
optionalArgs={};

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,'');
end
pvpmod(varargin);

% check for event data
if ~isfield(nsFile,'Event') || ~isfield(nsFile.Event,'TimeStamp') ...
        || sum(cellfun(@isempty, nsFile.Event.TimeStamp))==size(nsFile.Event.TimeStamp,2) %all cells are empty
    error('FIND:missingEvents','Please load event data first or use preview function (BrowseEntities->Data).');
else
    for ii=1:length(eventID)
        posEventsList(ii)=isempty(find(nsFile.Event.EntityID==eventID(ii)));
    end
    if  sum(posEventsList)~=0
        error('FIND:missingEvents','Please load event data first or use preview function (BrowseEntities->Data).');
    end
end

TRIALSPACING=0.1;
preTrigger=abs(preTrigger);
postTrigger=abs(postTrigger);

% create for all trigger channels for all unitIDs rasterplots
for kk=eventID
    triggers=[];
    posEvents=find(nsFile.Event.EntityID==kk);
    triggers=nsFile.Event.TimeStamp{posEvents};

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
                disp(['raster plotting for ID ',num2str(ii),'failed (missing data)']);
                postMessage(['no rasterPlot for ID: ',num2str(ii), ' possible (missing data) ']);
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
        s=[];
        nUnits=length(unique(Units));
        % assumes continuity within units
        for uu=1:nUnits
            spikes=allSpikes(find(Units==uu),1);

            fh=figure;
            h=[h fh];
            for pp=1:length(triggers)
                in_window=(spikes - triggers(pp)> - preTrigger) +( spikes - triggers(pp)< postTrigger) ;
                tmp=spikes(find(in_window==2))- triggers(pp); % all spikes around the trigger subsummed. 0 denotes trigger onset.
                plot(tmp,ones(size(tmp))* pp * TRIALSPACING,'k.','MarkerSize',10); hold on;
            end
            xlabel('t [s]');
            ylabel(['trials (n=' num2str(length(triggers)) ')']);
            ylim([0 (length(triggers)+1)*TRIALSPACING]);
            xlim([-preTrigger-0.01 postTrigger+0.01]);
            set(gca,'ytick',[]);
            hold on;
            plot([0 0],[0 (length(triggers)+1)*TRIALSPACING],'r', 'LineWidth', 2);
            hold on;
            title(sprintf('EntityID:%3i ; UnitID:%3i ; EventID: %3i', ii,uu,kk));
            set(fh,'name',sprintf('Raster Plot of EntityID %3i',ii),'NumberTitle','off');
        end
    end
end
