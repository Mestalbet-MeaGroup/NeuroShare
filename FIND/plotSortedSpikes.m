function plotSortedSpikes(selected_Entities)
% Plot the individual spikes for each cluster and show the "MEAN" Spike per Cluster
%
% This function plots all spikes referring to one cluster in one subplot
% and shows additionally the "mean" spike as a dotted black line.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


global nsFile; %-% if needed

if ~isfield(nsFile,'Segment') || ~isfield(nsFile.Segment,'Data') ...
        || isempty(nsFile.Segment.Data)
    error('FIND:noSegmentData','No segment data found in nsFile variable.');
end

for tt=1:length(selected_Entities)
    posEntities(tt)=find(nsFile.Segment.DataentityIDs==selected_Entities(tt));
end

for ii = posEntities
    figure('Name','Sorted_Spikes_Clusters');

    NClusters=unique(nsFile.Segment.UnitID{ii});

    N=ceil(sqrt(length(NClusters)));

    for t=1:length(NClusters)
        thiscluster=NClusters(t);
        subplot(N,N,t);
        thesespikes=nsFile.Segment.Data{ii}(:,[find(nsFile.Segment.UnitID{ii}==thiscluster)]);
                  plot([1:size(thesespikes,1)] , thesespikes);
        hold on;
        colormap gray;
        if size(thesespikes,2)>1
            avg_wave=mean(thesespikes,2);
        else
            avg_wave=thesespikes;
            disp('found only ONE spike in this Cluster!');
        end
        plot([1:size(thesespikes,1)] ,avg_wave,'--','Color',[.3 .3 .3],'Linewidth',2);
        title(['Unit ID ' num2str(t)]);
        xlabel('[s]');
            ylabel('Voltage [unknown units]');   
        axis tight;

        %med_waves(t,:)=median(thesespikes,2);
        % std_waves(t,:)=std(thesespikes,2);
    end

end


