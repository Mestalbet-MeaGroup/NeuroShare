function outgdf=pp_ExtrGdf(ingdf,varargin)
%extarcts those times/Processes specified from the input file
%
%USAGE:
%   gdf=ExtrGdf(gdf,'Time',tmax) returns the events before tmax (in
%           resolution of the input-gdf!!!)
%   gdf=ExtrGdf(gdf,'Time',[tmin,tmax]) returns the events between tmin and
%           tmax. If tmin is smaller than the earliest or tmax is larger thatn the
%           latest event, this is ignored (in
%           resolution of the input-gdf!!!)
%   gdf=ExtrGdf(gdf,'Processes',ProcessIds) returns the events of the Process
%                                           specified in the vector ProcessIds
%
% Version 1.0
% 2.12.05 (staude@neurobiologie.fu-berlin.de)
% Part of the PointProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OrigProcesses=ingdf(:,1);
MinProcess=min(OrigProcesses);
MaxProcess=max(OrigProcesses);
n_Processes=MaxProcess-MinProcess+1;
OrigTime=ingdf(:,2);
OrigTmin=min(OrigTime);
OrigTmax=max(OrigTime);

ExtractProcesses=0;
ExtractTime=0;
for i=1:2:length(varargin)
    %keyboard
    switch varargin{i}
        case {'Processes'}
            ExtrIds=unique(sort(varargin{i+1}));
            if length(ExtrIds)==0 | length(ExtrIds)>n_Processes | max(ExtrIds)>MaxProcess | min(ExtrIds)<MinProcess
                error('pp_ExtrGdf: Entries in ProcessIds do not match the channlel ids of input!!!')
            end
            ExtractProcesses=1;
        case {'Time'}
            TimesToExtract=varargin{i+1};
            ExtrTmax=TimesToExtract(end);
            if length(TimesToExtract)>2 | length(TimesToExtract)==0
                    error('pp_ExtrGdf: Times to be extracted misspecified!')
            elseif ExtrTmax==TimesToExtract(1)
                ExtrTmin=OrigTmin
            else 
                ExtrTmin=TimesToExtract(1);
            end
            if ExtrTmin>ExtrTmax
                error('pp_ExtrGdf: First time must be smaller than the second')
            end
            ExtractTime=1;
        otherwise
            error('pp_ExtrGdf: unspecified option')
    end
end


%%%%%%%%%%%%%%%% Extraction %%%%%%%%%%%%%%%%%%%%%%%
%Processes
outgdf=ingdf;
if ExtractProcesses
    %keyboard
    if all(diff(ExtrIds)==1)
        %keyboard
        idx=find((OrigProcesses>=ExtrIds(1))&(OrigProcesses<=ExtrIds(end)));
        outgdf=cat(2,OrigProcesses(idx),OrigTime(idx));
    else
        idx=[];
        for k=1:length(ExtrIds)
            idx=cat(1,idx,find(OrigProcesses==ExtrIds(k)));
        end
        outgdf=cat(2,OrigProcesses(idx),OrigTime(idx));
    end
end
%Time
if ExtractTime
    idx=find((outgdf(:,2)>=ExtrTmin)&(outgdf(:,2)<=ExtrTmax));
    outgdf=outgdf(idx,:);
end




