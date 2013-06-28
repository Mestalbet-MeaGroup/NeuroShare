function gdf=pp_Cut(gdfcell,type,Id);
% Cut the the Data according to the type. 
%
%   INPUT: gdfcell - cell containing different Trials, gdfcell{i} contains
%                   a gdf of the ith trial
%          type -   'MultipleNeuronsSingleTrial':  use the Trial
%                   'SingleNeuronMultipleTrials':   use the channel
%	  Id	-   The Id of the trial/channel that is being extracted. Default is 1
%         
%         
%         
%
%   OUTPUT:   
%
%
%   USES: 
%   Version 1.1
%   HISTORY:	10.1.06 - Id-option entered
%   Benjamin Staude, Berlin  12/12/05 (staude@neurobiologie.fu-berlin.de)
% Part of the ParaProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3
	Id=1;
else
    switch type
        case 'MultipleNeuronsSingleTrial'
            if Id>length(gdfcell)
                error('pp_Cut: Id is larger than the number of trials')
            end
        case 'SingleNeuronMultipleTrials'
            if Id>max(gdfcell{1}(:,1))
                error('pp_Cut: Id is larger than the number of channels')
            end
        otherwise
            error(['pp_Cut: unknown type ' type ])
    end
end

gdf=[];
switch type
    case 'MultipleNeuronsSingleTrial'
        gdf=gdfcell{Id};
    case 'SingleNeuronMultipleTrials'
        for i=1:length(gdfcell)
            times=gdfcell{i}(find(gdfcell{i}(:,1)==Id),2);
            gdf=cat(1,gdf,cat(2,ones(size(times))*i,times));
        end
end
%keyboard;
gdf=sortrows(gdf,2);