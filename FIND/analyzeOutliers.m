function analyzeOutliers(selected_Entities)
% Analysis of potential outliers after SpikeSorting within one cluster
% function analyzeOutliers(analogEntityIndices)
%
% Show a histogram of the within one clustered unit distances between the
% spike shapes (the cutouts stored in the segment data).
% This distribution provides hints on the sorting quality of this cluster.
% Bimodal or "tailed" distributions indicate bad clustering.
% Exteme spike shapes can be discarded.
%
%
% (0) R. Meier Feb 07 meier@biologie.uni-freiburg.de
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile; %-% if needed

if ~isfield(nsFile,'Segment') || ~isfield(nsFile.Segment,'Data') ...
        || isempty(nsFile.Segment.Data{1})
    error('FIND:noSegmentData','No segment data found in nsFile variable.');
end


for tt=1:length(selected_Entities)
    if ~isempty(nsFile.Segment.Data{find(nsFile.Segment.DataentityIDs==selected_Entities(tt))})

        posEntities(tt)=find(nsFile.Segment.DataentityIDs==selected_Entities(tt));
    else
        error('Call to missing entity!');
    end
end

figure('Name','analyzeOutliersWindow');

for ii=posEntities
    %keyboard;
    % call function euclidien Distance
    D=euclidDist(nsFile.Segment.Data{ii});
    [by bx]=hist(D(:),100);

    bar(bx,sqrt(by /2),'FaceColor',[.6 .6 .6]); axis tight;
    xlabel('Inter-cutout-distance')
    ylabel('#');
    ax=axis;
    hold on;
    prclist=[ 50 75 85 90 95 96 97 98 99 99.9];
    pr=prctile(D(:),prclist);
    clist=hsv(length(pr));
    Ystep=(ax(4)-ax(3)) / 20;
    for tt=1:length(pr)
        plot([pr(tt) pr(tt)],[ax(3) ax(4)],'color',clist(tt,:),'Linewidth',2);
        text(pr(tt), ax(4)-Ystep*ii,[num2str(prclist(tt)),'%'],'color',clist(tt,:),'Fontweight','bold','fontSize',14);
        % text(pr(ii), ax(3)+Ystep,[num2str(sum(D>pr(ii)))]);
    end

    axis tight;

    % get the distance to discard from the user
    prompt = {'Enter euclid. Distance to discard: '};
    dlg_title = 'Input request';
    num_lines = 1;
    def = {''};
    tempo = inputdlg(prompt,dlg_title,num_lines,def);
    THRES=str2num(tempo{1});
    %THRES=input('give DISTANCE VALUE to discard : ');

    DZ=zeros(size(D));
    DZ(find(D>THRES))=1;

    %[rw,cl]=ind2sub(find(D(:)>THRES),size(D));
    %
    c=1;
    for kk=1:size(D,1)
        for ll=1:size(D,2)
            if DZ(kk,ll)
                to_discard(c,:)=[ll kk];
                c=c+1;
            end
        end
    end

    all_spikes_to_remove=unique(to_discard(:));

    figure('Name','spikes considered as garbage');
    plot(nsFile.Segment.Data{ii}(:,all_spikes_to_remove));

end