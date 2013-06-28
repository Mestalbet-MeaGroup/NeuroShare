function [rfCenters]=findStrf(varargin);   %[R,PSTH]=processResponse(varargin);
% looks in STAs for patterns which look like spatiotemporal receptive
% fields the user has to determine
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% STA: the spiketriggered averages, dimension should be units, time before spike
%       and space
% analogEntityIndex: the index of the entity which is to be analyzed; 
% valueThreshold: threshold of the values which should be exceded
% clusterThreshold: number of pixels which should excede the threshold in a
%       given field.
%
%%%%%%Optional Arguments
%
% noUnits: if the receptive fields should be found for sorting, the noUnits
%       parameter is 1
%
% Henriette Walz 02/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de



% obligatory argument names
obligatoryArgs={'STA','analogEntityIndex','valueThreshold','clusterThreshold'};


% optional arguments names with default values
optionalArgs={'noUnits'};
noUnits=0;

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting default values
pvpmod(varargin);

global nsFile 
%find position IDs of analog entities.
posEntityIDs=[];
neuralPosEntityIDs=[];
for j=1:length(analogEntityIndex)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==analogEntityIndex(j))];
    neuralPosEntityIDs=[neuralPosEntityIDs,find(nsFile.Neural.EntityID==analogEntityIndex(j))];
end


%%%assign the variable
putativeCentersFinal=cell(max(neuralPosEntityIDs),1);
%%%if the units should be sorted with this method, a new STA of all
%%% units together has to be calculated
if noUnits
    global linearizedStimulus
    selectedEvent=str2num(get(findobj('Tag','makeStrfGwnGUI_selectedEventEntity'),'String'));
    selectedMemory=str2num(get(findobj('Tag','makeStrfGwnGUI_selectedMemory'),'String'));
    trialDuration=str2num(get(findobj('Tag','makeStrfGwnGUI_selectedTrialDuration'),'String'));
    refreshRate=str2num(get(findobj('Tag','makeStrfGwnGUI_selectedRate'),'String'));
    global STA2 STA2_mean idx2 PSTH2
    [idx2,PSTH2]=processResponse('eventEntity',selectedEvent,'responseEntities', analogEntityIndex,'trialDuration',trialDuration, 'frequency',refreshRate,'ifplot',0,'noUnits',1);
    [STA2,STA2_mean]=calculateSTA('stimulus',linearizedStimulus,'spikeTrain',idx2,'responseEntities',analogEntityIndex,'mem',selectedMemory, 'ifplot',0);

end
for c=neuralPosEntityIDs
    cInd=find(neuralPosEntityIDs==c);
    
    if noUnits
        sta_s=size(STA2{cInd});
        staSquared=squeeze(reshape(STA2{cInd},[sta_s(1) sta_s(2) sqrt(sta_s(3)) sqrt(sta_s(3))]));
    else
        sta_s=size(STA{cInd});
        if prod(sta_s(3:end))==sta_s(3)
            staSquared=reshape(STA{cInd},[sta_s(1) sta_s(2) sqrt(sta_s(3)) sqrt(sta_s(3))]);
        elseif prod(sta_s(3:end))>sta_s(3)
            staSquared=squeeze(STA{cInd});
        end
    end


    %size of STA and nUnits, nFrames from this

    nUnits=sta_s(1);
    nFrames=sta_s(2);
    putativeCenters=cell(nUnits,1);
    % dimensionality in space of the STA is one dimension, should be
    % reshaped to xXy.

    for nn=1:nUnits
        %%assign the figure with colorbar etc.
        figure('Position',[-3          35        1600        1096],'name',sprintf('RFs with putative centers of Strfs for unit %2i',nn))
        xSubplots=ceil(sqrt(nFrames+1));
        ySubplots=floor(sqrt(nFrames+1));
        cmap=[zeros(10,1) , [1:-0.1:0.1]' ,zeros(10,1);[0.1:0.1:1]', zeros(10,1),zeros(10,1)];
        clist=hsv(nFrames);
        lh_legend=[];
        l_legend=[];



        for mm=1:nFrames
            putativeCentersThisFrame=[];
            %%%%%%%%% find putative centers of the receptive field:
            %first calculate mean and std of values to find significant ones later
           thisSTA=squeeze(staSquared(nn,mm,:,:));
            meanPixel=mean(mean(thisSTA));

            thisSTA=thisSTA-meanPixel;
            maxPixel=max(max(abs(thisSTA)));
            %now thisSTA is in relative numbers:
            thisSTA=thisSTA/maxPixel;

            %%now only show the ones which exceed threshold
            pctr=find(abs(thisSTA>valueThreshold));
            matr=zeros(size(thisSTA));
            matr(pctr)=1;

            %%now convolve to later detect a clustering of high numbers
            mmatr=conv2(matr,ones(3,3)/9,'same');
            if find(mmatr>clusterThreshold)
                [putativeCentersThisFrame(1,:),putativeCentersThisFrame(2,:)]=find(mmatr>clusterThreshold);
            else
                putativeCentersThisFrame=[0,0];
            end

            %%plot the whole thing
            subplot(ySubplots,xSubplots,mm);
            imagesc(thisSTA); hold on
            colormap(cmap);
            title(sprintf('STA %2i frames before spike with putative centers of a RF',mm))
            xlabel('xpixel');
            ylabel('ypixel');

            % plot the putative receptive field centers
            if find(mmatr>clusterThreshold)
                
                plot(putativeCentersThisFrame(2,:),putativeCentersThisFrame(1,:),'w+','MarkerSize',5);
                for ii=1:size(putativeCentersThisFrame,2)
                    x_text=sprintf('%2i',ii);
                    %%the text should go around the center, since close
                    %%centers become hardly readable
                    gmod=mod(ii,4);
                    switch gmod
                        case 1
                            text(putativeCentersThisFrame(2,ii),putativeCentersThisFrame(1,ii),x_text,'color','w','FontSize',15);
                        case 2
                            text(putativeCentersThisFrame(2,ii)-1,putativeCentersThisFrame(1,ii)-4,x_text,'color','w','FontSize',15);
                        case 3
                            text(putativeCentersThisFrame(2,ii)-5,putativeCentersThisFrame(1,ii),x_text,'color','w','FontSize',15);
                        case 0 
                            text(putativeCentersThisFrame(2,ii)-1,putativeCentersThisFrame(1,ii)+4,x_text,'color','w','FontSize',15);
                    end


                end
            end
            axis square
            colorbar;

            %%now plot all detected centers together to see if there are
            %%consistent ones throughout the frames
            if find(mmatr>clusterThreshold)
                subplot(ySubplots,xSubplots,nFrames+1);
                lh=plot(putativeCentersThisFrame(2,:),putativeCentersThisFrame(1,:),'+','color',clist(mm,:),'Markersize',3);
                axis([1 size(thisSTA,1) 1 size(thisSTA,2)]);
                set(gca, 'Ydir', 'reverse');
                axis square
                lh_legend=[lh_legend,lh];
                l_legend=[l_legend;sprintf('frame %2i',mm)];

                hold on;

            end
            if mm==nFrames
            legend(lh_legend,l_legend,'location','EastOutside');
            title('all putative Strfs plotted together')
            end
            tmp_putativeCenters{nn}{mm}=putativeCentersThisFrame;
        end
        
        %%ask the user to determine which are centers in his eyes
        prompt = {'Enter which putative centers you regard reliable for frame 1','for frame 2','for frame 3','for frame 4','for frame5'};
        dlg_title = sprintf('putative centers of unit number %2i',nn);
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        putativeCenters{nn}=[];
        for m=1:nFrames
            putativeCenters{nn}=[putativeCenters{nn},tmp_putativeCenters{nn}{m}(:,str2num(answer{m}))];
        end
        centerSize(nn,:)=size(putativeCenters{nn});
        if size(putativeCenters{nn},1)==1 & ~isempty(putativeCenters{nn})
            putativeCentersFinal{cInd}=reshape(putativeCenters{nn},[2,1])
        end
    end

    %%if units have different numbers of receptive fields they have to be
    %%zero padded
    if nUnits>1
        maxCenters=max(centerSize);
        putativeCentersFinal{cInd}=zeros(nUnits,maxCenters(1),maxCenters(2))
        for nn=1:nUnits
            q=maxCenters(2)-centerSize(nn,2);
            if q
                putativeCentersFinal{cInd}(nn,:,:)=[putativeCenters{nn},zeros(maxCenters(1),q)]
            else
                putativeCentersFinal{cInd}(nn,:,:)=putativeCenters{nn};
            end
        end
        %%% if only one rfCenter, it has to be reshaped to have 2 columns
        
    elseif nUnits==1
        putativeCentersFinal{cInd}(1,:,:)=squeeze(putativeCenters{1});
    end


    %%now plot recptive fields around the centers in a bigger plot
    for nn=1:nUnits
        indices=squeeze(putativeCentersFinal{cInd}(nn,:,:)');
        %%%get rid of zeros
        if find(indices==0)
            indices=indices(find(indices));
            indices=reshape(indices,[2,length(indices)/2]);
        end
        %% the receptive field is assumed to be around 4*4 pixel 
        allIndices=[indices(1,:)-2;indices(1,:)+2;indices(2,:)-2;indices(2,:)+2];
        if find(allIndices<0)
            allIndices(find(allIndices<0))=0;
        elseif find(allIndices>sqrt(size(STA{cInd},3)))
            allIndices(find(allIndices>sqrt(size(STA{cInd},3))))=sqrt(size(STA{cInd},3));
        end
        figure;
        set(gcf,'Position',[-19         950-(nn-1)*250        1604         170])
        for ii=1:size(allIndices,2)
            subplot(1,size(allIndices,2),ii); imagesc(squeeze(staSquared(nn,1,allIndices(1,ii):allIndices(2,ii),allIndices(3,ii):allIndices(4,ii))));
            colormap(cmap);
            hold on;
            if ii==size(allIndices,2)
                colorbar;
            end
        end
    end
end
rfCenters=putativeCentersFinal;
