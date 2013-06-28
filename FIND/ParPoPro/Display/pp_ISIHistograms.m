function [h,ISI,EdgesMs,CV]=pp_ISIHistograms(gdf,BinSizeMs,varargin);
% [h,ISI,Edges]=pp_ISIHistograms(gdf,BinSizeMs,varargin) displays ISI Histograms of all processes in gdf, using a binning of
% BinSizeMs ms and returns the handle to the figure.
%
%   INPUT:  Data    -   in gdf Format, IN MS RESOLUTION!!!
%           BinSizeMs -   bin size (in ms)
%         
%   OPTIONS:    'UnitMs'    -       temporal Resolution of Data in ms
%               'DisplayUnit' -   y-labels of the Histogram, either
%                                   'Counts' or 'Probability'. Default is
%                                   'Probability'
%               'Plot':     - 1 to plot (Default), 0 mot to plot
%               
%
%   OUTPUT: h - handle to the figure  
%           ISI - cell containing ISI-Data, ISI{k} corresponds to kth
%                   process
%           Edges - cell containing the edges
%           CV    - array containing the CVs
% 
%   Remarks: Times are internally changed to units of ms 
%   USES: 
%   Version 1.1
%   HISTORY:    1.3.06  -   Included optional normalizations
%               18.06.20 - Included Optional plot, return CV
%   Benjamin Staude, Berlin  14/12/05 (staude@neurobiologie.fu-berlin.de)
% Part of the ParaProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yUnit='Probability';
UnitMs=1;
PlotOpt = 1;
for i=1:2:length(varargin)
    switch varargin{i}
        case 'UnitMs'
            UnitMs=varargin{i+1};
        case 'DisplayUnit'
            yUnit=varargin{i+1};
        case 'Plot'
            PlotOpt = varargin{i+1};
        otherwise
            error(['pp_ISIHist0grams: unknown option: ' varargin{i} ]);
    end
end
gdf(:,2)=gdf(:,2)*UnitMs;

ProcessIds=unique(gdf(:,1)); %vector containing the Process Ids
NumberOfProcesses=length(ProcessIds);
if NumberOfProcesses==0;
    error('pp_ISIHistograms: No spikes in input file!')
end
if NumberOfProcesses>12
    error('pp_ISIHistograms: Too Many ISIs to display ')
end



%%%  Computation  %%%%
ISI=cell(NumberOfProcesses,1);
EdgesMs=cell(NumberOfProcesses,1);
CV=[];
for k=1:NumberOfProcesses
    TimesMs=gdf(find(gdf(:,1)==ProcessIds(k)),2);   %Convert Times to Ms
    TimeDifferencesMs=diff(TimesMs);
    CV(k)=std(TimeDifferencesMs)/mean(TimeDifferencesMs);
    EdgesMs{k}=[0:BinSizeMs:max(TimeDifferencesMs)];
    ISI{k}=histc(TimeDifferencesMs,EdgesMs{k})';
    switch yUnit
        case 'Probability'
            ISI{k}=ISI{k}/sum(ISI{k});
    end
end


%%%% Display  %%%%
if PlotOpt==1
    if NumberOfProcesses==1
        PlotRows=1;
    elseif NumberOfProcesses<=4
        PlotRows=2;
    else
        PlotRows=3;
    end
    PlotColumns=ceil(NumberOfProcesses/PlotRows);
    %keyboard
    h=figure;
    for k=1:NumberOfProcesses
        subplot(PlotRows,PlotColumns,k);
        bar(EdgesMs{k},ISI{k})
        title(['Unit ' num2str(ProcessIds(k)) ', CV = ' num2str(round(CV(k)*100)/100) ]);
        xlim([0 max(EdgesMs{k})]);
        xlabel('ms')

        switch yUnit
            case 'Probability'
                ylabel('ISI probability')
            otherwise
                ylabel('ISI counts')
        end
    end
else
    h = [];
end