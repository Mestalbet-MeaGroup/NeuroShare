function outgdf=pp_Clipping(ingdf)
% outgdf=pp_Clipping(ingdf) returns outgdf, where double spikes of single
% neurons are removed
%
% 
%
% Version 1.0
% 15/12/05 (staude@neurobiologie.fu-berlin.de)
% Part of the PointProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FirstChannel=min(ingdf(:,1));
LastChannel=max(ingdf(:,1));
N=LastChannel-FirstChannel+1;
outgdf=[];
for k=FirstChannel:LastChannel
    times=ingdf(find(ingdf(:,1)==k),2);
    idx=find(diff(times)==0);
    times(idx)=[];
    outgdf=cat(1,outgdf,cat(2,ones(size(times))*k,times));
end
outgdf=sortrows(outgdf,2);