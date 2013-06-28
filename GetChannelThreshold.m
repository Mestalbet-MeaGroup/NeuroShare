function SpikeThreshold=GetChannelThreshold(hfile,i)

[ss, ss, Data, ss, ss] = ns_GetSegmentData(hfile, i, 1:100);

for i=1:length(Data(1,:))
    b(i)=Data(101,i);
end
SpikeThreshold=max(b);

% vars=whos;
% i=1;
% if vars(i).name(end-2:end)=='ost'
%     
%     if vars(i).size(1)==4
%         eval(['ic=' vars(i).name ';'])
%     else
%         eval(['t=' vars(i).name ';'])
%     end
%     
% end
% 
% vars(i).name(end-2:end)=='pre'