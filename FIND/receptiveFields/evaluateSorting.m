function centerSort(varargin);  
% evaluates the sorting done with the receptive field centers
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% analog Entity Index: Index of the analog entity which is being sorted
%
%
%
%
%
%
% Henriette Walz 04/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%


% obligatory argument names
obligatoryArgs={'analogEntityIDs'};


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



for c=posEntityIDs



    nUnits=length(unique(nsFile.Segment.UnitID{c}));
    nUnitsRf=max(unique(nsFile.Segment.UnitIDrf{c}));
   

    %%%%%calculate normal probability functions for the different clusters
    %%%%%of spikes
    %for all dimensions
    pdfKmeans=zeros(nUnits,size(nsFile.Segment.Data{c},1),size(nsFile.Segment.Data{c},2));
    pdfKmeans=zeros(nUnits,size(nsFile.Segment.Data{c},1),size(nsFile.Segment.Data{c},2));    
    for id=1:size(nsFile.Segment.Data{c},1)
        baseData=nsFile.Segment.Data{c}(id,:);
        %%for clusters done with kmeans
        for nn=1:nUnits
            data=nsFile.Segment.Data{c}(id,nsFile.Segment.UnitID{c}==nn);
            pdfKmeans(nn,id,:)= normpdf(baseData,mean(data),std(data));
        end
        %%%for clusters done with centers of rf
        for nr=1:nUnitsRf
            data=nsFile.Segment.Data{c}(id,nsFile.Segment.UnitIDrf{c}==nr);
            pdfCenter(nr,id,:)=normpdf(baseData,mean(data),std(data));

            
        end
        %%%somehow getting all combinations of two of the distributions
        count=1;
        ind=1;
        for ff=1:factorial(nUnitsRf)/factorial(nUnitsRf-2)/factorial(2)
            ind=ind+1;
            tmp_alphaCenter(id,ff)=ttest(pdfCenter(count,:,:),pdfCenter(ind,:,:));
            if ind==4
                count=count+1;
                ind=count;
            end
        end

       for ff=1:factorial(nUnits)/factorial(nUnits-2)/factorial(2)
            ind=ind+1;
            tmp_alphaKmeans(id,ff)=ttest(pdfKmeans(count,id),pdfCenter(ind,id));
            if ind==4
                count=count+1;
                ind=count;
            end
       end
        
        
        
    end
        
    tmp_alphaKmeans2=prod(tmp_alphaKmeans);
    tmp_alphaCenter2=prod(tmp_alphaCenter);
    alphaKmeans=zeros(nUnits);
    alphaCenter=zeros(nUnitsRf);
    for fig=1:length(tmp_alphaKmeans2)
        alphaKmeans(fig)=tmp_alphaKmeans2(fig);
    end
    for fig=1:length(tmp_alphaCenter2)
        alphaCenter(fig)=tmp_alphaCenter2(fig);
    end
    figure;
    subplot(1,2,1); imagesc(alphaKmeans);
    subplot(1,2,2); imagesc(alphaCenter);



end




