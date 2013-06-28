function [SingleProcessStats,TrialParameters,DisplayParameters,...
    DirectoryAndFileNames,CorrelatedProcessStats]=...
    ppgui_UpdateParameterValues(handles)
%
% Reads the parameter values from the gui and returns therir values in the
% respective structs
%
%  REMARKS: if the entries are empty, the corresponding fields are set to
%  Default Values (for optional paramters)
%  or to [] (for neccessary paramters) !!!
% Benjamin Staude 18/12/05
% staude@neurobiologie.fu-berlin.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% Default Values        %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%

SingleProcessStats.UnitMs=1;
SingleProcessStats.PrecisionMs=realmin;
TrialParameters.TrialOffset=0;
TrialParameters.StartOfExperiment=0;





%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% File/Diretory Names   %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%


DirectoryAndFileNames.WorkingDirectory=get(handles.WorkingDirectory,'String');
DirectoryAndFileNames.LoadParameterFileName=get(handles.LoadParameterFileName,'String');
DirectoryAndFileNames.SaveParameterFileName=get(handles.SaveParameterFileName,'String');
DirectoryAndFileNames.SaveDataName=get(handles.SaveDataName,'String');


%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% Single Process Params %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%

switch get(handles.ProcessType,'Value')
    case 1
        SingleProcessStats.ProcessType='StatPoisson';
    
    case 2
        SingleProcessStats.ProcessType='NonStatPoisson';
    case 3
        SingleProcessStats.ProcessType='Gamma';
        SingleProcessStats.Order=str2num(get(handles.Order,'String'));
        switch get(handles.GammaType,'Value')
            case 1
                SingleProcessStats.GammaType='Equilibrium';
            case 2
                SingleProcessStats.GammaType='Ordinary';
        end
end
SingleProcessStats.RateValue=get(handles.RateValue,'Value');
SingleProcessStats.RateFile=get(handles.RateFile,'Value');

switch SingleProcessStats.RateValue;
    case 1
        SingleProcessStats.Rate=str2num(get(handles.Rate,'String'));
    case 0
        SingleProcessStats.RateFileName=get(handles.RateFileName,'String');
        if isempty(SingleProcessStats.RateFileName)
            SingleProcessStats.Rate=[];
        else
            SingleProcessStats.Rate=load(SingleProcessStats.RateFileName);
        end
end 
if ~isempty(get(handles.UnitMs,'String'))
    SingleProcessStats.UnitMs=str2num(get(handles.UnitMs,'String'));
end
if ~isempty(get(handles.PrecisionMs,'String'))
    switch get(handles.PrecisionMs,'String')
    case 'realmin'
        SingleProcessStats.PrecisionMs=realmin;
    otherwise
        SingleProcessStats.PrecisionMs=str2num(get(handles.PrecisionMs,'String'));
    end
end

SingleProcessStats.Clipping=get(handles.Clipping,'Value')-1;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               %
%   Correlated Process Panel    %
%                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


CorrelatedProcessStats.RateValue=get(handles.RateValue2,'Value');
CorrelatedProcessStats.RateFile=get(handles.RateFile2,'Value');
CorrelatedProcessStats.CorrCoefficient=...
    str2num(get(handles.CorrelationCoefficient,'String'));

switch CorrelatedProcessStats.RateValue;
    case 1
        CorrelatedProcessStats.Rate=str2num(get(handles.Rate2,'String'));
    case 0
        CorrelatedProcessStats.RateFileName=get(handles.RateFileName2,...
            'String');
        if isempty(CorrelatedProcessStats.RateFileName)
            CorrelatedProcessStats.Rate=[];
        else
            CorrelatedProcessStats.Rate=...
                load(CorrelatedProcessStats.RateFileName);
        end
end 
if ~isempty(get(handles.UnitMs,'String'))
    CorrelatedProcessStats.UnitMs=str2num(get(handles.UnitMs,'String'));
end
if ~isempty(get(handles.PrecisionMs,'String'))
    switch get(handles.PrecisionMs,'String')
    case 'realmin'
        CorrelatedProcessStats.PrecisionMs=realmin;
    otherwise
        CorrelatedProcessStats.PrecisionMs=...
            str2num(get(handles.PrecisionMs,'String'));
    end
end

CorrelatedProcessStats.Clipping=get(handles.Clipping,'Value')-1;



%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% Trial Parameters      %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%
TrialParameters.NumberOfProcesses=str2num(get(handles.NumberOfProcesses,'String'));
TrialParameters.NumberOfTrials=str2num(get(handles.NumberOfTrials,'String'));

% initialize logical field isSingleProcess
if get(handles.SelectSingleProcess, 'Value') == 0
    TrialParameters.isSingleProcess = false;
else
    TrialParameters.isSingleProcess = true;
end

switch get(handles.TrialDurationUnit,'Value')
    case 1
        TrialParameters.TrialDurationUnit=1;        % in sec
    case 2
        TrialParameters.TrialDurationUnit=0.001;    %in sec
end
TrialParameters.TrialDuration=str2num(get(handles.TrialDuration,'String'));
TrialParameters.TrialDurationS=...
    TrialParameters.TrialDuration*TrialParameters.TrialDurationUnit;
TrialParameters.TrialDurationMs=TrialParameters.TrialDurationS*1000;

switch get(handles.TrialOffsetUnit,'Value')
    case 1
        TrialParameters.TrialOffsetUnit=1;          % in sec
    case 2
        TrialParameters.TrialOffsetUnit=0.001;       % in sec
end
if ~isempty(get(handles.TrialOffset,'String'))
    TrialParameters.TrialOffset=str2num(get(handles.TrialOffset,'String'));
end
TrialParameters.TrialOffsetS=...
    TrialParameters.TrialOffset*TrialParameters.TrialOffsetUnit;
TrialParameters.TrialOffsetMs=TrialParameters.TrialOffsetS*1000;

TrialParameters.Marker=str2num(get(handles.Marker,'String'));


switch get(handles.StartOfExperimentUnit,'Value')
    case 1
        TrialParameters.StartOfExperimentUnit=1;     % in sec
    case 2
        TrialParameters.StartOfExperimentUnit=0.001; % in sec
end
if ~isempty(get(handles.StartOfExperiment,'String'))
    TrialParameters.StartOfExperiment=str2num(get(handles.StartOfExperiment,'String'));
end
TrialParameters.StartOfExperimentS=...
    TrialParameters.StartOfExperiment*TrialParameters.StartOfExperimentUnit;
TrialParameters.StartOfExperimentMs=TrialParameters.StartOfExperimentS*1000;

%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% Display Parameters    %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%

switch get(handles.DisplayChannels,'Value')
        case 1
            DisplayParameters.DisplayChannels='MultipleNeuronsSingleTrial';
        case 2
            DisplayParameters.DisplayChannels='SingleNeuronMultipleTrials';
end
DisplayParameters.DotDisplay=get(handles.DotDisplay,'Value');  
if DisplayParameters.DotDisplay  
    switch get(handles.DotMarkerStyle,'Value')
        case 1
            DisplayParameters.DotMarkerStyle='Line';
        case 2
            DisplayParameters.DotMarkerStyle='Dot';
    end
end



%%%   ISI   %%%
DisplayParameters.ISI=get(handles.ISI,'Value');
if DisplayParameters.ISI
    DisplayParameters.ISIFirstProcess=str2num(get(handles.ISIFirstProcess,'String'));
    DisplayParameters.ISILastProcess=str2num(get(handles.ISILastProcess,'String'));
    DisplayParameters.ISIBinSizeMs=str2num(get(handles.ISIBinSizeMs,'String'));
    ISIValue=get(handles.ISIUnit,'Value');
    ISIUnit= get(handles.ISIUnit,'String');
    DisplayParameters.ISIUnit=ISIUnit{ISIValue};    
end


%%% Count Statistics   %%%
DisplayParameters.CountStatistics=get(handles.CountStatistics,'Value');
if DisplayParameters.CountStatistics
    switch get(handles.CountBinSizeUnit,'Value')
        case 1
            DisplayParameters.CountBinSizeUnit=0.001;     % in sec
        case 2
            DisplayParameters.CountBinSizeUnit=1;        % in sec
    end
    DisplayParameters.CountBinSizeMs=str2num(get(handles.CountBinSize,'String'))*DisplayParameters.CountBinSizeUnit*1000;
    DisplayParameters.CountDistributions=get(handles.CountDistributions,'Value');
    if DisplayParameters.CountDistributions
            DisplayParameters.CountFirstProcess=str2num(get(handles.CountFirstProcess,'String'));
            DisplayParameters.CountLastProcess=str2num(get(handles.CountLastProcess,'String'));
    end
    DisplayParameters.PopulationHistogram=get(handles.PopulationHistogram,'Value');
    PSTHUnitcell=get(handles.PSTHUnit,'String');
    DisplayParameters.PSTHUnit=PSTHUnitcell{get(handles.PSTHUnit,'Value')};
    DisplayParameters.ComplexityDistribution=get(handles.ComplexityDistribution,'Value');
    ComplDistrUnitcell=get(handles.ComplDistrUnit,'String');
    DisplayParameters.ComplDistrUnit=ComplDistrUnitcell{get(handles.ComplDistrUnit,'Value')};
end





