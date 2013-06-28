function ppgui_Display(Data,DisplayParameters);
% Displays the Data according to the settings in the DisplayParameters.
% It Especially cuts the data according to
% DisplayParameters.DisplayChannels and removes the TrialMarkers
%
%   INPUT: Data, DisplayParameters
%         
%         
%         
%         
%
%   OUTPUT:   
%
%
%   USES: 
%   Version 1.1
%   HISTORY:    12/02/06 - included PSTHUnit
%   Benjamin Staude, Berlin  12/02/06 (staude@neurobiologie.fu-berlin.de)
% Part of the ParaProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Cut the Dataset
switch DisplayParameters.DisplayChannels
    case 'MultipleNeuronsSingleTrial'
        YLabel='Process Id';
    case 'SingleNeuronMultipleTrials'
        YLabel='Trial Id';
end
PlotGdf=pp_Cut(Data.gdfcell,DisplayParameters.DisplayChannels);


%%% Dot Display  %%%%
if DisplayParameters.DotDisplay
    DotFigure=pp_DotDisplay(PlotGdf,'DotMarkerStyle',DisplayParameters.DotMarkerStyle,...
        'UnitMs',Data.SingleProcessStats.UnitMs,...
        'ylabel',YLabel);
end

%%% ISI Histogramm %%%
if DisplayParameters.ISI
    ISIgdf=pp_ExtrGdf(PlotGdf,...
        'Processes',[DisplayParameters.ISIFirstProcess:DisplayParameters.ISILastProcess]);
    pp_ISIHistograms(ISIgdf,DisplayParameters.ISIBinSizeMs,...
        'UnitMs',Data.SingleProcessStats.UnitMs,...
        'DisplayUnit', DisplayParameters.ISIUnit);
end




%%% Count Statistics %%%
if DisplayParameters.CountStatistics
    %%%   Count Distributions   %%%
    if DisplayParameters.CountDistributions
        Countgdf=pp_ExtrGdf(PlotGdf,...
            'Processes',[DisplayParameters.CountFirstProcess:DisplayParameters.CountLastProcess]);
        pp_CountHistograms(Countgdf,DisplayParameters.CountBinSizeMs,...
            'UnitMs',Data.SingleProcessStats.UnitMs);
    end
    %%%  Population Histogramm %%%
    if DisplayParameters.PopulationHistogram
        pp_PopulationHistogram(PlotGdf,DisplayParameters.CountBinSizeMs,...
            'UnitMs',Data.SingleProcessStats.UnitMs,...
            'DisplayUnit',DisplayParameters.PSTHUnit);
    end
    %%%  Complexity Distribution   %%%
    if DisplayParameters.ComplexityDistribution
        pp_ComplexityDistribution(PlotGdf,DisplayParameters.CountBinSizeMs,...
            'UnitMs',Data.SingleProcessStats.UnitMs,...
            'DisplayUnit',DisplayParameters.ComplDistrUnit);
        
    end
end






    








