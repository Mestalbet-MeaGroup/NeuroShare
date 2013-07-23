% Plot Spikes on One Channel

x=3;
i=1;
timeWithinSample = (1:200)./10000;

[nsresult] = ns_SetLibrary('nsMCDlibrary64.dll');
[nsresult, hfile] = ns_OpenFile('E:\AstroStimArticleDataSet\Melanopsin-Mcherry\MCD Files\3620_GcAMPmel_baseline0001.mcd');
[nsresult,entity] = ns_GetEntityInfo(hfile,x);
[nsresult,segment] = ns_GetSegmentInfo(hfile,x);
[nsresult, segmentsource] = ns_GetSegmentSourceInfo(hfile,8,x);
hold all;
for i=1:entity.ItemCount
[nsresult,timestamp{i},temp,samplecount,unitid] = ns_GetSegmentData(hfile,3,i);
% data{i} = (temp-min(temp))./(max(temp)-min(temp));
data{i}=temp;
plot(timeWithinSample+timestamp{i},data{i});
end

xlim([355.9 356.42]);
ylim([-11E-05 4E-05]);
ylabel('uV','FontSize',18);
xlabel('Time [Sec]','FontSize',18);
set(gca,'FontSize',18,'PlotBoxAspectRatio',[10 1 1]);
% maximize(gcf);
print('RawElectrodeSpikes.png','-dpng','-r600');