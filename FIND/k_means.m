function [pbm, idx_k] = k_means(varargin)
% calculates a kmeans clustering with determining the pbm index for cluster validation
%
% Returns the pbm value for all tested cluster numbers and the index vector
% for the best clustering. The greater the pbm index the better the
% clustering. For information on the PBM index see:
% Pakhira et al. Validity index for crisp and fuzzy clusters. Pattern Recognition 37 (2004) 487 – 501.
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% 'DataMatrix': The initial data which should be clustered, with rows as variables and
% columns as dimensions.
%
%
%
% %%%%% Optional Parameters %%%%%
%
% 'MaxCluster': The maximum number of clusters tested.
% Possible values:
%    From two to number of variables. It must not be number of variables,
%    because the pbm index then becomes inifinite.
%    Default: 15
%

% Further comments:
%
%   The clustering has to start with one cluster, since the pbm index needs
%   this. For that reason no MinCluster variable exists.
%
%
% Henriette Walz 01/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


% obligatory argument names
obligatoryArgs={'DataMatrix','clusterData','nClusters'};           % 'analogEntityIndex'};

% optional arguments names with default values
optionalArgs={'posEntityIDs','k_prompted'};

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% set defaults
posEntityIDs=0;
k_prompted=NaN;

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

global nsFile

%find how many wave form are to be clustered
m= size(clusterData,1);


MaxCluster=max(nClusters);
% if there should be more clusters than variables, return!
if MaxCluster>m
    disp('Warning: Maximum number of clusters greater than number of data vectors!')
    return
end

% initialize some important variables
pbm=zeros(1,MaxCluster);    % vaule of clustering goodness
all_idx=zeros(m, MaxCluster);   % assignment vector, which cluster the wave forms belong to

for k = [1,nClusters]
    
    %do it 50 times to avoid falling into local minima
    for pp=1:50
        
        % kmeans is sensitive to beginning point, initialize it randomly
        p = randperm(size(clusterData,1));      % centroid initialized randomly
        for ii=1:k
            c(ii,:)=clusterData(p(ii),:);
        end

        temp=zeros(m,1);

        while 1,    % cluster as long as it is not the minimum
            d=k_DistMatrix(clusterData,c);  % calculate objcets-centroid distances
            [z,g]=min(d,[],2);  % find assignment matrix g
            if g==temp,
                break;          % stop the iteration once nothing is changing
            else
                temp=g;         % copy group matrix to temporary variable
            end
            for i=1:k
                f=find(g==i);
                if f
                    c(i,:)=mean(clusterData(find(g==i),:),1);   %start clustering from center of clusters again
                end
            end
        end

        %assign values once the clustering is done, only assign them if
        %this clustering was better than the one before ()
        %for the first clustering the variables have to be created
        if k==1
            SumOfDistances=sum(z);
            FinalCentroids=c;
            FinalIndices=g;
            FinalDistances=z;
        end
        if sum(z)>SumOfDistances;
        else SumOfDistances=sum(z);
            FinalCentroids=c;
            FinalIndices=g;
            FinalDistances=z;
        end
    end
    %to keep track when clustering is very slow, I'm giving back this notice
    disp(['done with clustering with ',num2str(k), ' clusters!']);
    %%%%%%%%%%%%%%%%%cluster validation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %calculate sum of distances for one cluster only, needed for index
    %calculation
    if k==1
        e1=sum(z);
    end
    %assign the vectors for this number of clusters
    pbm(k)=k_pbm(k,FinalDistances,FinalIndices,e1,FinalCentroids);      %calculate index
    all_idx(:,k)=FinalIndices;
end


%%%%%%%%%%%%%%%plot index and spike shapes%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot pbm index
h1=figure; hold on;
set(h1,'name','PBM-Index','NumberTitle', 'off');
plot(pbm, '*-');
title('PBM value, maximal for best clustering');
xlabel('number of clusters','FontSize',14);
ylabel('arbitrary units','FontSize',14);
set(gca,'FontSize',14);

temp_idx=all_idx(:,find(pbm==max(pbm)));

%plot mean cluster wave form
h2=figure; hold on;
set(h2,'name','MeanSpikeShapesInClusters','Position',[780,678,560,420],'NumberTitle', 'off');
temp_UClusters=unique(temp_idx);
% WARNING: pay attention with pointing to data! postion in segment data
% does not imply the same position in analog data (if originating from those)

posAnalogEntityIDs=find(nsFile.Analog.DataentityIDs==nsFile.Segment.DataentityIDs(posEntityIDs));
if isempty(posAnalogEntityIDs)
    posAnalogEntityIDs=0;
end
if posEntityIDs && posAnalogEntityIDs
    % 2nd check to enshure that the requested SamplingRate is present and that the data originate from analog data
    time2plot=[1/nsFile.Analog.Info(posAnalogEntityIDs).SampleRate:1/nsFile.Analog.Info(posAnalogEntityIDs).SampleRate:size(DataMatrix,1)/nsFile.Analog.Info(posAnalogEntityIDs).SampleRate];
else
    time2plot=[1:size(DataMatrix,1)];
end
    
Cmap=hsv(length(temp_UClusters));
lh_legend=[];
for r=1:length(temp_UClusters)
    nn=find(temp_idx==temp_UClusters(r));
    if length(nn)>1
        lh=plot(time2plot,mean(DataMatrix(:,find(temp_idx==temp_UClusters(r))),2),'Color',Cmap(r,:));
        hold on;
    else
        lh=plot(time2plot,DataMatrix(:,find(temp_idx==temp_UClusters(r))),'Color',Cmap(r,:));
        hold on;
    end
    lh_legend=[lh_legend;lh];
end
legend(lh_legend,num2str(temp_UClusters))
title('clustering with maximal pbm value')
if posEntityIDs
    xlabel( 'time/s', 'FontSize',14)
else
    xlabel('Samples','FontSize',14);
end
%if voltage unit is stored in nsFile, get that one
if posEntityIDs && isfield(nsFile.Analog.Info,'Units') && posAnalogEntityIDs
    ylabel(['Voltage [' nsFile.Analog.Info(posAnalogEntityIDs(1)).Units ']']);
% elseif posEntityIDs 
%     ylabel(['Voltage [' nsFile.Analog.Info(posEntityIDs(1)).Units ']'],'FontSize',14);
else
    ylabel('Voltage [unknown units]','FontSize',14);
end
set(gca,'FontSize',14);

%plot all wave forms 
h3=figure;
NsubplotsX=ceil(sqrt(length(temp_UClusters)));
NsubplotsY=round(sqrt(length(temp_UClusters)));
set(h3,'name','AllSpikesInClusters','Position',[230,678,560,420],'NumberTitle', 'off');
pics=1;
for rr=1:length(temp_UClusters)
    subplot(NsubplotsY,NsubplotsX,pics);
    plot(time2plot,DataMatrix(:,find(temp_idx==temp_UClusters(rr))),'Color',Cmap(rr,:));
    pics=pics+1;
    if posEntityIDs
        xlabel( 'time/s','FontSize',14)
    else
        xlabel('Samples','FontSize',14);
    end

    if posEntityIDs && isfield(nsFile.Analog.Info,'Units') && posAnalogEntityIDs
        ylabel(['Voltage [' nsFile.Analog.Info(posAnalogEntityIDs).Units ']']);
        if posEntityIDs && isfield(nsFile.Analog.Info,'Units')&& ~isempty(nsFile.Analog.Info(posEntityIDs).Units)
            ylabel(['Voltage [' nsFile.Analog.Info(posEntityIDs).Units ']'],'FontSize',14);
        else
            ylabel('Voltage [unknown units]','FontSize',14);
        end
        set(gca,'FontSize',14)
    end
end
% give user the opportunity to choose cluster number him/herself
if isnan(k_prompted)
    prompt = {'Do you want to cluster again with different cluster number than maximal pbm value? If yes, enter prefered number! If no, enter 0! '};
    dlg_title = 'Input request';
    num_lines = 1;
    def = {''};
    temp_k = inputdlg(prompt,dlg_title,num_lines,def);
    k_prompted=str2double(temp_k{1});
end
%if user wants other cluster number than would be best from pbm value
if k_prompted==0
    idx_k=temp_idx;
else
    idx_k=all_idx( :,k_prompted);

    %plot cluster information for user specified number of clusters
    h4=figure; hold on;
    set(h4,'name','SpikeShapesInClusters','Position',[780,678,560,420],'NumberTitle', 'off');
    UClusters=unique(idx_k);
    Cmap=hsv(length(UClusters)+1);
    NumberOfClusters=length(UClusters);

    lh_legend=[];
    for t=1:length(UClusters)
        n=find(idx_k==UClusters(t));
        if length(n)>1
            lh2=plot(time2plot,mean(DataMatrix(:,find(idx_k==UClusters(t))),2),'Color',Cmap(t,:));
            lh_legend=[lh_legend;lh2(end)];
            hold on;
        else
            lh2=plot(time2plot,DataMatrix(:,find(idx_k==UClusters(t))),'Color',Cmap(t,:));
            lh_legend=[lh_legend;lh2(end)];
            hold on;
        end
    end
    legend(lh_legend,num2str(UClusters));
    title('clustering with maximal pbm value')
    if posEntityIDs
        xlabel( 'time/s')
    else
        xlabel('Samples')
    end

    if posEntityIDs && isfield(nsFile.Analog.Info,'Units') && posAnalogEntityIDs
        ylabel(['Voltage [' nsFile.Analog.Info(posAnalogEntityIDs).Units ']']);
    else
        ylabel('Voltage [unknown units]');
    end

    %plot all spike wave forms
    h5=figure;
    set(h5,'name','AllSpikesInClusters','Position',[230,678,560,420],'NumberTitle', 'off');
    %get number of subplots
    NsubplotsX=ceil(sqrt(NumberOfClusters));
    NsubplotsY=round(sqrt(NumberOfClusters));
    pics=1;
    for tt=1:length(UClusters)
        subplot(NsubplotsY,NsubplotsX,pics);
        plot(time2plot,DataMatrix(:,find(idx_k==UClusters(tt))),'Color',Cmap(tt,:));
        pics=pics+1;
        if posEntityIDs
            xlabel( 'time')
        else xlabel('Samples')
        end

        if posEntityIDs && isfield(nsFile.Analog.Info,'Units') && posAnalogEntityIDs
            ylabel(['Voltage [' nsFile.Analog.Info(posAnalogEntityIDs).Units ']']);
        else
            ylabel('Voltage [unknown units]');
        end
    end
end



