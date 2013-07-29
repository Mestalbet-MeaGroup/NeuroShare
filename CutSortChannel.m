function [tNew,indexchannelNew]=CutSortChannel(t,indexchannel,tStart,tEnd);
%function [tNew,indexchannelNew]=CutSortChannel(t,indexchannel,tStart,tEnd);
%a function that cuts out a peace of a recording between timings tStart and
%tEnd

%Nov 16, 2003 - nadav
%Nov 18, 2003 - nadav - modify so if t of neuron is empty - make it NaN.

indexchannelNew=zeros(size(indexchannel));
indexchannelNew(1:2,:)=indexchannel(1:2,:);
tNew=[];
for i=1:length(indexchannel),
    tChannel=t(indexchannel(3,i):indexchannel(4,i));
    tCut=tChannel(find(tChannel>=tStart & tChannel<=tEnd));
    if isempty(tCut),
        tCut=[NaN];
    end
    tCut=[tCut, NaN];
    indexchannelNew(3,i)=length(tNew)+1;
    tNew=[tNew, tCut];
    indexchannelNew(4,i)=length(tNew);
end

    