function [ComplDistr,X]=pp_ComplexityDistribution(gdf,BinSizeMs,varargin);
% pp_ComplexityDistribution(gdf,BinSizeMs,varargin) Computes and plots a complexity distribution of the gdf using the BinSizeMs.
% [ComplDistr,X]=pp_ComplexityDistribution(gdf,BinSizeMs,varargin) computes
% the complexity distribution and returns the position of the bars in X.
%
% INPUT:  gdf    -   in gdf Format
%           BinSizeMs -   bin size (in ms)
%         
%   OPTIONS:    'UnitMs'    -   temporal Resolution of Data in ms
%               'DisplayUnit'   -    'Probability' - normalized to area 1
%                               -    'Counts'    -   plots the raw counts (Default)  
%               
%   OUTPUT:   
%
%   REMARKS:   gdf is assumed to start at t=0!!!
%               gdf-times are internally changed to units of ms 
%
%   Version 1.2
%   HISTORY:    1.3.06: included DisplayUnit
%               10.3.06: make Diplay optional
%   Benjamin Staude, Berlin  13/12/05 (staude@neurobiologie.fu-berlin.de)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UnitMs=1;
DisplayUnit='Count';
for i=1:2:length(varargin)
    switch varargin{i}
        case 'UnitMs'
            UnitMs=varargin{i+1};
        case 'DisplayUnit'
            DisplayUnit=varargin{i+1};
        otherwise
            error(['pp_ComplexityDistribution: unknown option' varargin{i} ])
    end
end
gdf(:,2)=gdf(:,2)*UnitMs;
            
            

%%% Computaion  %%%
TimesMs=gdf(:,2);
TotalTimeMs=max(TimesMs);
edges=[0:BinSizeMs:ceil(TotalTimeMs/BinSizeMs)*BinSizeMs];
%edges=[min(TimesMs):BinSizeMs:TotalTimeMs];
PopHist=histc(TimesMs,edges);
PopHist=PopHist(1:end-1);
X=[min(PopHist):max(PopHist)];
ComplDistr=histc(PopHist,X);

switch DisplayUnit
    case 'Probability'
        ComplDistr=ComplDistr/sum(ComplDistr);
        FigureTitle='Complexity Distribution';
    otherwise
        FigureTitle='Complexity Histogram';            
end




%%%  Display %%%
if nargout==0
    ComplDistrFigure=figure;
    bar(X,ComplDistr)

    title(FigureTitle)
    xlabel('Number of events')
    ylabel(DisplayUnit)
    xlim([min(X)-.5 max(X)+.5])
    ylim([0 max(ComplDistr)+max(ComplDistr)/10])
end
