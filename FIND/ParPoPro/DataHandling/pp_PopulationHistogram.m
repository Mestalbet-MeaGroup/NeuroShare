function [PopHist,edges]=pp_PopulationHistogram(gdf,BinSizeMs,varargin);
% [PopHist,edges]=pp_PopulationHistogram(gdf,BinSizeMs,varargin) returns a population histogram of the gdf using the BinSize.
%   INPUT:  gdf    -   in gdf Format
%           BinSizeMs -   bin size (in ms)
%         
%   OPTIONS:    'UnitMs'    -   temporal Resolution of Data in ms
%               'DisplayUnit'  -   Unit to use for the y-axis. Either 'Hz' or
%                           'Counts'. Default is Counts.
%  
%
%   REMARKS:   gdf is assumed to start at t=0!!!
%              gdf-times are internally changed to units of ms 
%
%   Version 1.1
%   HISTORY:    12/02/06 - included PSTHUnit
%
%   Benjamin Staude, Berlin  12/02/06 (staude@neurobiologie.fu-berlin.de)
% Part of the ParaProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UnitMs=1;
PSTHUnit='Counts';
for i=1:2:length(varargin)
    switch varargin{i}
        case 'UnitMs'
            UnitMs=varargin{i+1};
        case 'DisplayUnit'
            DisplayUnit=varargin{i+1};
        otherwise
            error(['pp_PopulationHistogram: unknown option' varargin{i} ])
    end
end

gdfMs(:,2)=gdf(:,2)*UnitMs;
            
%%% Computaion  %%%
TimesMs=gdfMs(:,2);
TotalTimeMs=max(TimesMs);
edges=[0:BinSizeMs:ceil(TotalTimeMs/BinSizeMs)*BinSizeMs];
PopHist=histc(TimesMs,edges);


%%% Adjust Units %%%
switch DisplayUnit
    case 'Hz'
        NTrials=max(gdf(:,1))-min(gdf(:,1))+1;
        PopHist=PopHist/(BinSizeMs*NTrials)*1000;
end

%%% Display  %%%
PopHistFigure=figure;
bar(edges+1/2*BinSizeMs,PopHist)
title('Population histogram')
xlabel('Time in ms')
ylabel(DisplayUnit)
ylim([0 max(PopHist)+max(PopHist)/10])
xlim([0 max(edges)]);
