function pp_CountHistograms(gdf,BinSizeMs,varargin);
% Displays Count Histograms of all processes in Data, using a binning of
% BinSizeMs ms.
%
%   INPUT:  gdf    -   in gdf Format, IN MS RESOLUTION!!!
%           BinSizeMs -   bin size (in ms)
%         
%   OPTIONS:    UnitMs    -   temporal Resolution of Data in ms
%         
%
%   OUTPUT:   
%
%   USES: 
%
%   REMARKS:  gdf is assumed to be in ms and to start a 0!!!!!
%               gdf-times are internally changed to units of ms 
%
%   Version 1.0
%   Benjamin Staude, Berlin  14/12/05 (staude@neurobiologie.fu-berlin.de)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Switch varargin
UnitMs=1;
for i=1:length(varargin)
    switch varargin{i}
        case 'UnitMs'
            UnitMs=varargin{i+1};
    end
end


gdf(:,2)=gdf(:,2)*UnitMs;



TimeMinMs=0;  %min(gdf(:,2));
TimeMaxMs=max(gdf(:,2));
ProcessIds=unique(gdf(:,1)); %vector containing the Process Ids
NumberOfProcesses=length(ProcessIds);
if NumberOfProcesses==0;
    error('pp_CountHistograms: No spikes in input file!')
end
if NumberOfProcesses>12
    error('pp_CountHistograms: Too Many histograms to display ')
end



%%%  Computation  %%%%

[CountMat,x]=pp_Gdf2CountMat(gdf,BinSizeMs);
Edges=[0:max(max(CountMat))];
HistMat=histc(CountMat,Edges);
FF=var(CountMat)./mean(CountMat);

%%%% Display  %%%%
if NumberOfProcesses<=4
    PlotRows=2;
else 
    PlotRows=3;
end
PlotColumns=ceil(NumberOfProcesses/PlotRows);
%keyboard
figure
for k=1:NumberOfProcesses
    subplot(PlotRows,PlotColumns,k);
    bar(Edges,HistMat(:,k))
    title(['Process no. ' num2str(ProcessIds(k)) ', FF = ' num2str(round(FF(k)*100)/100) ]);
    xlim([0 max(Edges)]);
    xlabel('Number of events')
    ylabel('Counts')
end