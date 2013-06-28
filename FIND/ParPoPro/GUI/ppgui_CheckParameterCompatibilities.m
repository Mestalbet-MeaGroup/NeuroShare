function [ErrorCount,WarningCount,TrialParameters]=...
    ppgui_CheckParameterCompatibilities(SingleProcessStats,...
    CorrelatedProcessStats,TrialParameters,DisplayParameters,handles)
%
% Check and display, if the parameter combinations set in the GUI are compatible and
% returns the number of errors (ErrorCount) and warnings (WarningCount)
%
%
%
% Version 1.1
% HISTORY: 12/02/06 - checked for
%                       ratefile-process-type-trialduration-NumberOFProcess compatibilities
%                   - included handles as input to reset GUI-values of
%                       TrialDuration
%                   - TrialParamters are returned!!!
%          13/04/07 - added CorrelatedProcessStats as parameter to check if
%                     the assigned values are within range -- JB
% Berlin, 12.06.06 (staude@neurobiologie.fu-berlin.de)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ErrorCount=0;
WarningCount=0;

%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% Single Process Params %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%
RateFileMs=0;
switch(SingleProcessStats.RateValue)
    case 1
        if isempty(SingleProcessStats.Rate);
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'Rate not specified'};
        else
            if SingleProcessStats.Rate<=0
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'Rate must be > 0 !!!'};
            elseif SingleProcessStats.Rate>1000
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'Rate must be < 1000 !!!'};
            end
        end
    case 0
        if isempty(SingleProcessStats.Rate)
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'Rate fle not specified'};
        else
            [RateFileMs,RateFileProcesses]=size(SingleProcessStats.Rate);
            if RateFileMs==1
                if strncmp(SingleProcessStats.ProcessType,'Non',3)
                    ErrorCount=ErrorCount+1;
                    Errors_txt(ErrorCount)={['Process type is Nonstationary, but rate profile has only on row!']};
                end
            else
                if ~strncmp(SingleProcessStats.ProcessType,'Non',3)
                   ErrorCount=ErrorCount+1;
                    Errors_txt(ErrorCount)={['Process type is stationary, but rate profile has ' num2str(RateFileMs) ' rows (should have 1)!']};
                else
                    if isempty(TrialParameters.TrialDuration);
                        WarningCount=WarningCount+1;
                        Warnings_txt(WarningCount)={['Trial duration set to length of rate file (' num2str(RateFileMs/1000) 'sec)']};
                        set(handles.TrialDuration,'String',RateFileMs/1000);
                        set(handles.TrialDurationUnit,'Value',1);
                        TrialParameters.TrialDurationMs=RateFileMs;
                    elseif RateFileMs~=TrialParameters.TrialDurationMs
                        WarningCount=WarningCount+1;
                         Warnings_txt(WarningCount)={['Specified trial duration does not fit to the size of the rate vector. I used the latter, simulated for '...
                             num2str(RateFileMs/1000) 'sec and corrected the trial duration in the GUI']};
                         set(handles.TrialDuration,'String',RateFileMs/1000);
                         set(handles.TrialDurationUnit,'Value',1);
                         TrialParameters.TrialDurationMs=RateFileMs;
                    end
                end
            end
            if ~(RateFileProcesses==TrialParameters.NumberOfProcesses | RateFileProcesses==1)
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={['Columns of the rate file ('...
                    num2str(RateFileProcesses) ') does not match the number of processes to simulate ('...
                    num2str(TrialParameters.NumberOfProcesses) ') !']};
            end
        end
end


if strncmp(SingleProcessStats.ProcessType,'Gam',3)
    if isempty(SingleProcessStats.Order)
        ErrorCount=ErrorCount+1;
        Errors_txt(ErrorCount)={'Order not sepcified'};
    elseif (round(SingleProcessStats.Order)~=SingleProcessStats.Order) | (SingleProcessStats.Order<1)
        ErrorCount=ErrorCount+1;
        Errors_txt(ErrorCount)={'Order must be a positive integer'};
    end
end

if ~isempty(SingleProcessStats.UnitMs)&(SingleProcessStats.UnitMs<=0)
    ErrorCount=ErrorCount+1;
    Errors_txt(ErrorCount)={'Units must be positive'};
end

if ~isempty(SingleProcessStats.PrecisionMs)&(SingleProcessStats.PrecisionMs<=0)
    ErrorCount=ErrorCount+1;
    Errors_txt(ErrorCount)={'Precision must be positive'};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               %
%   Correlated Process Panel    %
%                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RateFileMs=0;
switch(CorrelatedProcessStats.RateValue)
    case 1
        if isempty(CorrelatedProcessStats.Rate);
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'Rate not specified'};
        else
            if CorrelatedProcessStats.Rate<=0
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'Rate must be > 0 !!!'};
            elseif CorrelatedProcessStats.Rate>1000
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'Rate must be < 1000 !!!'};
            end
        end
    %{
    case 0
        if isempty(CorrelatedProcessStats.Rate)
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'Rate fle not specified'};
        else
            [RateFileMs,RateFileProcesses]=size(CorrelatedProcessStats.Rate);
            if RateFileMs==1
                if strncmp(CorrelatedProcessStats.ProcessType,'Non',3)
                    ErrorCount=ErrorCount+1;
                    Errors_txt(ErrorCount)={['Process type is Nonstationary, but rate profile has only on row!']};
                end
            else
                if ~strncmp(SingleProcessStats.ProcessType,'Non',3)
                   ErrorCount=ErrorCount+1;
                    Errors_txt(ErrorCount)={['Process type is stationary, but rate profile has ' num2str(RateFileMs) ' rows (should have 1)!']};
                else
                    if isempty(TrialParameters.TrialDuration);
                        WarningCount=WarningCount+1;
                        Warnings_txt(WarningCount)={['Trial duration set to length of rate file (' num2str(RateFileMs/1000) 'sec)']};
                        set(handles.TrialDuration,'String',RateFileMs/1000);
                        set(handles.TrialDurationUnit,'Value',1);
                        TrialParameters.TrialDurationMs=RateFileMs;
                    elseif RateFileMs~=TrialParameters.TrialDurationMs
                        WarningCount=WarningCount+1;
                         Warnings_txt(WarningCount)={['Specified trial duration does not fit to the size of the rate vector. I used the latter, simulated for '...
                             num2str(RateFileMs/1000) 'sec and corrected the trial duration in the GUI']};
                         set(handles.TrialDuration,'String',RateFileMs/1000);
                         set(handles.TrialDurationUnit,'Value',1);
                         TrialParameters.TrialDurationMs=RateFileMs;
                    end
                end
            end
            if ~(RateFileProcesses==TrialParameters.NumberOfProcesses | RateFileProcesses==1)
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={['Columns of the rate file ('...
                    num2str(RateFileProcesses) ') does not match the number of processes to simulate ('...
                    num2str(TrialParameters.NumberOfProcesses) ') !']};
            end
        end
        %}
end


% check correlation coefficient
if ~TrialParameters.isSingleProcess
    if isempty(CorrelatedProcessStats.CorrCoefficient)

        ErrorCount=ErrorCount+1;
        Errors_txt(ErrorCount)={'Correlation coefficient missing'};

    elseif (CorrelatedProcessStats.CorrCoefficient < -1) || ...
            (CorrelatedProcessStats.CorrCoefficient > 1)

        ErrorCount=ErrorCount+1;
        Errors_txt(ErrorCount)={['Correlation coefficient must be between '...
            '-1 and 1']};

    end
end


if ~isempty(CorrelatedProcessStats.UnitMs)&(CorrelatedProcessStats.UnitMs<=0)
    ErrorCount=ErrorCount+1;
    Errors_txt(ErrorCount)={'Units must be positive'};
end

if ~isempty(CorrelatedProcessStats.PrecisionMs)&(CorrelatedProcessStats.PrecisionMs<=0)
    ErrorCount=ErrorCount+1;
    Errors_txt(ErrorCount)={'Precision must be positive'};
end



%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% Trial Parameters      %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(TrialParameters.NumberOfProcesses)
    ErrorCount=ErrorCount+1;
    Errors_txt(ErrorCount)={'Number of processes not specified'};
elseif (round(TrialParameters.NumberOfProcesses)~=TrialParameters.NumberOfProcesses) | (TrialParameters.NumberOfProcesses<0)
    ErrorCount=ErrorCount+1;
    Errors_txt(ErrorCount)={'Number of processes must be a positive integer'};
end

if isempty(TrialParameters.NumberOfTrials)
    ErrorCount=ErrorCount+1;
    Errors_txt(ErrorCount)={'Number of trials not specified'};
elseif (TrialParameters.NumberOfTrials<=0) | (round(TrialParameters.NumberOfTrials)~=TrialParameters.NumberOfTrials)
    ErrorCount=ErrorCount+1;
    Errors_txt(ErrorCount)={'Number of trials not a positive integer'};
elseif TrialParameters.NumberOfTrials>1
    if isempty(TrialParameters.Marker)
        ErrorCount=ErrorCount+1;
        Errors_txt(ErrorCount)={'Marker not specified'};
    elseif TrialParameters.Marker<=TrialParameters.NumberOfProcesses
        WarningCount=WarningCount+1;
        Warnings_txt(WarningCount)={['Marker (' num2str(TrialParameters.Marker) ') coincides with a process Id']};
    end
    if ~isempty(TrialParameters.TrialOffset) & (TrialParameters.TrialOffset<0)
        ErrorCount=ErrorCount+1;
        Errors_txt(ErrorCount)={'Trial offset mus be positive'};
    end
end

if isempty(TrialParameters.TrialDurationMs) & RateFileMs<2;
    ErrorCount=ErrorCount+1;
    Errors_txt(ErrorCount)={'Trial duration not specified'};
elseif TrialParameters.TrialDurationMs<=0
    ErrorCount=ErrorCount+1;
    Errors_txt(ErrorCount)={'Trial duration must be positive'};
end



if ~isempty(TrialParameters.StartOfExperiment) & (TrialParameters.StartOfExperiment<0)
    WarningCount=WarningCount+1;
    Warnings_txt(WaarningCount)={'Start of experiment is negative'};
end



%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% Display Parameters    %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%


% ISI Display
if strcmp(DisplayParameters.DisplayChannels,'MultipleNeuronsSingleTrial')
    if DisplayParameters.ISI
        if isempty(DisplayParameters.ISIFirstProcess) | isempty(DisplayParameters.ISILastProcess)
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'Process ids for ISI display not specified'};
        else
            if DisplayParameters.ISIFirstProcess>DisplayParameters.ISILastProcess
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'First process id for ISI display must be smaller than the last'};
            end
            if (DisplayParameters.ISIFirstProcess<=0) | ...
                (round(DisplayParameters.ISIFirstProcess)~=DisplayParameters.ISIFirstProcess) | ...
                (DisplayParameters.ISILastProcess<=0) | ...
                (round(DisplayParameters.ISILastProcess)~=DisplayParameters.ISILastProcess)
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'ISI process ids must be positive integers'};
            end
            if (DisplayParameters.ISILastProcess>TrialParameters.NumberOfProcesses)
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'Last ISI process ids exceeds the number of processes to simulate'};
            end
        end
        if isempty(DisplayParameters.ISIBinSizeMs)
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'ISI bin size not specified'};
        elseif DisplayParameters.ISIBinSizeMs<=0
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'ISI bin size must be positive'};
        end
    end
else
    if DisplayParameters.ISI
        if isempty(DisplayParameters.ISIFirstProcess) | isempty(DisplayParameters.ISILastProcess)
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'Trial ids for ISI display not specified'};
        else
            if DisplayParameters.ISIFirstProcess>DisplayParameters.ISILastProcess
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'First trial id for ISI display must be smaller than the last'};
            end
            if (DisplayParameters.ISIFirstProcess<=0) | ...
                (round(DisplayParameters.ISIFirstProcess)~=DisplayParameters.ISIFirstProcess) | ...
                (DisplayParameters.ISILastProcess<=0) | ...
                (round(DisplayParameters.ISILastProcess)~=DisplayParameters.ISILastProcess)
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'ISI trial ids must be positive integers'};
            end
            if (DisplayParameters.ISILastProcess>TrialParameters.NumberOfTrials)
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'Last ISI trial ids exceeds the number of trials to simulate'};
            end
        end
        if isempty(DisplayParameters.ISIBinSizeMs)
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'ISI bin size not specified'};
        elseif DisplayParameters.ISIBinSizeMs<=0
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'ISI bin size must be positive'};
        end
    end
end
        

% Count Display
if DisplayParameters.CountStatistics
    if isempty(DisplayParameters.CountBinSizeMs)
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'Count bin size not specified'};
        elseif DisplayParameters.CountBinSizeMs<=0
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'Count bin size must be positive'};
    end
    if DisplayParameters.CountDistributions
        if isempty(DisplayParameters.CountFirstProcess) | isempty(DisplayParameters.CountLastProcess)
            ErrorCount=ErrorCount+1;
            Errors_txt(ErrorCount)={'Process ids for count distributions not specified'};
        else
            if (DisplayParameters.CountFirstProcess<=0) | ...
                (round(DisplayParameters.CountFirstProcess)~=DisplayParameters.CountFirstProcess) | ...
                (DisplayParameters.CountLastProcess<=0) | ...
                (round(DisplayParameters.CountLastProcess)~=DisplayParameters.CountLastProcess)
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'Count process ids must be positive integers'};
            end
            if DisplayParameters.CountFirstProcess>DisplayParameters.CountLastProcess
                ErrorCount=ErrorCount+1;
                Errors_txt(ErrorCount)={'First process id for count distributions must be smaller than the last'};
            end
        end
        if strcmp(DisplayParameters.DisplayChannels,'MultipleNeuronsSingleTrial')
               if (DisplayParameters.CountLastProcess>TrialParameters.NumberOfProcesses)
                    ErrorCount=ErrorCount+1;
                    Errors_txt(ErrorCount)={'Last count process id exceeds the number of processes to simulate'};
               end
        else
            if (DisplayParameters.CountLastProcess>TrialParameters.NumberOfTrials)
                    ErrorCount=ErrorCount+1;
                    Errors_txt(ErrorCount)={'Last count trial id exceeds the number of trials to simulate'};
            end
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% Simulation / Display Code  %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% Display Warnings      %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%   
    
                
if ErrorCount>0;
   ErrorWarning_txt(1)={'ERRORS:'};
   ErrorWarning_txt=[ErrorWarning_txt Errors_txt];
   if WarningCount>0;
       ErrorWarning_txt(end+1)={''};
       ErrorWarning_txt(end+1)={'WARNINGS:'};
       ErrorWarning_txt=[ErrorWarning_txt Warnings_txt];
   end
elseif WarningCount>0
       ErrorWarning_txt(1)={'WARNINGS:'};
       ErrorWarning_txt=[ErrorWarning_txt Warnings_txt];
end


if ErrorCount>0 | WarningCount>0
    ppgui_ErrorWarnings(ErrorWarning_txt);
end



