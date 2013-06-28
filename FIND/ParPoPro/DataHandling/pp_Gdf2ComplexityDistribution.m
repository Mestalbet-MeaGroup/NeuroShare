function [ComplDistr,X]=pp_GdfComplexityDistribution(gdf,BinSizeMs,varargin);
% [ComplDistr,X]=pp_GdfComplexityDistribution(gdf,BinSizeMs,varargin) returns 
% the complexity distribution of the gdf using the BinSizeMs such that there are ComplDistr(k)  bins with X(k) events.
%   INPUT:  gdf    -   in gdf Format
%           BinSizeMs -   bin size (in ms)
%         
%   OPTIONS:    'UnitMs'    -   temporal Resolution of Data in ms
%               
%		(('Type'          -    'Distribution' - normalized to area 1
%                               -    'Count'    -   raw counts (Default)
%                       NOT YET !!! ))
%
%
%   REMARKS:   gdf is assumed to start at t=0!!!
%               gdf-times are internally changed to units of ms 
%
%   Version 1.0
%   Part of the ParPoPro ToolBox
%   Benjamin Staude, Berlin  22/01/06 (staude@neurobiologie.fu-berlin.de)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UnitMs=1;
for i=1:2:length(varargin)
    switch varargin{i}
        case 'UnitMs'
            UnitMs=varargin{i+1};
        otherwise
            error(['pp_ComplexityDistribution: unknown option' varargin{i} ])
    end
end
gdf(:,2)=gdf(:,2)*UnitMs;
            
            

%%% Computaion  %%%
TimesMs=gdf(:,2);
TotalTimeMs=max(TimesMs);
edges=[0:BinSizeMs:TotalTimeMs];
PopHist=histc(TimesMs,edges);
X=[0:max(PopHist)];
ComplDistr=histc(PopHist,X);





