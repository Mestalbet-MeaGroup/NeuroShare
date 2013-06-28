function centerSort(varargin);  
% sorts spikes according to different receptive fields in the spike triggered
% average
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% rfCenters: the centers of putative different receptive fields
%
% analogEntityIDs: analog entities of the response channels
%
% stimulus: the stimulus matrix time X space
% 
% frameDuration: duration of frames in seconds
%
% trialDuration: duration of trial in seconds
% 
% STA: spike triggered average in time X space
%
%%%%%% Optional Parameters %%%%
%
% 
%
% Henriette Walz 04/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%


% obligatory argument names
obligatoryArgs={'rfCenters','analogEntityIDs','stimulus','frameDuration','trialDuration','STA'};


% optional arguments names with default values
optionalArgs={''};

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting default values
pvpmod(varargin);

global nsFile;

%find position IDs of analog entities.
posEntityIDs=[];
for j=1:length(analogEntityIDs)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==analogEntityIDs(j))];
end
eventPosEntityID=find(nsFile.Analog.DataentityIDs==eventID);


triggers=[nsFile.Event.TimeStamp{eventPosEntityID};nsFile.Event.TimeStamp{eventPosEntityID}(end)+trialDuration];
stimulus=reshape(stimulus,[size(stimulus,1) sqrt(size(stimulus,2)) sqrt(size(stimulus,2))]);

%%% duration of the frames has to be in milliseconds:
frameDurationMS=frameDuration*1000;

for c=posEntityIDs

    neuralData=[];
    neuralDataIndices=[];

    for e=1:length(triggers)-1
        in_window=(nsFile.Neural.Data{c} > triggers(e))  + (nsFile.Neural.Data{c}<(triggers(e)+trialDuration)) ;
        neuralData=[neuralData;nsFile.Neural.Data{c}(find(in_window==2))- triggers(e)];
        neuralDataIndices=[neuralDataIndices;find(in_window==2)];
    end

    indices=squeeze(rfCenters{c}(1,:,:));
    allIndices=[indices(1,:)-4;indices(1,:)+4;indices(2,:)-4;indices(2,:)+4]


    frames=ceil(neuralData/frameDurationMS);
    stimScore=zeros(length(neuralData),size(rfCenters{c},3));
    for s=1:size(rfCenters{c},3)

        if find(allIndices < 0) | find(allIndices > size(stimulus,2))
            allIndices(find(allIndices<0|allIndices>size(stimulus,2)))=0;
        end




        for fr=1:length(frames)
            for mm=1:size(STA{c},2)
                if frames(fr)-(mm-1)>0
                    tmp_stimScore=sum(sum(squeeze(stimulus(frames(fr)-(mm-1),allIndices(1,s):allIndices(2,s),allIndices(3,s):allIndices(4,s))).*squeeze(STA{c}(1,mm,allIndices(1,s):allIndices(2,s),allIndices(3,s):allIndices(4,s)))));
                    stimScore(fr,s)=stimScore(fr,s)+tmp_stimScore;
                end
            end
        end
    end
    [y,ind]=max(stimScore,[],2);
    nsFile.Segment.UnitIDrf{c}=zeros(size(nsFile.Neural.Data{c}));
    nsFile.Segment.UnitIDrf{c}(neuralDataIndices)=ind;



    %plot mean cluster wave form
    h1=figure; hold on;
    set(h1,'name','MeanSpikeShapesInClusters','Position',[780,678,560,420]);
    temp_UClusters=unique(ind);
    Cmap=hsv(length(temp_UClusters));
    lh_legend=[];
    for r=1:length(temp_UClusters)
        nn=find(nsFile.Segment.UnitID{c}==temp_UClusters(r));
        if length(nn)>1
            lh=plot(mean(nsFile.Segment.Data{c}(:,find(ind==temp_UClusters(r))),2),'Color',Cmap(r,:));
            hold on;
        else
            lh=plot(nsFile.Segment.Data{c}(:,find(ind==temp_UClusters(r))),'Color',Cmap(r,:));
            hold on;
        end
        lh_legend=[lh_legend;lh];
    end
    legend(lh_legend,num2str(temp_UClusters))
    title('clustering with receptive field centers')
    xlabel( 'time')
    %if voltage unit is stored in nsFile, get that one
    if posEntityIDs && isfield(nsFile.Analog.Info,'Units') && ~isempty(nsFile.Analog.Info(c).Units)
        ylabel(['Voltage [' nsFile.Analog.Info(c).Units ']']);
    else
        ylabel('Voltage [unknown units]');
    end

    %plot all wave forms
    h2=figure;
    NsubplotsX=ceil(sqrt(length(temp_UClusters)));
    NsubplotsY=round(sqrt(length(temp_UClusters)));
    set(h2,'name','AllSpikesInClusters','Position',[230,678,560,420]);
    pics=1;
    for rr=1:length(temp_UClusters)
        subplot(NsubplotsY,NsubplotsX,pics);
        plot(nsFile.Segment.Data{c}(:,find(ind==temp_UClusters(rr))),'Color',Cmap(rr,:));
        pics=pics+1;
        xlabel( 'time')

        if posEntityIDs && isfield(nsFile.Analog.Info,'Units')&& ~isempty(nsFile.Analog.Info(c).Units)
            ylabel(['Voltage [' nsFile.Analog.Info(c).Units ']']);
        else
            ylabel('Voltage [unknown units]');
        end
    end
end

















