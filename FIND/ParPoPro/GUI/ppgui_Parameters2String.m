function [ParameterString,CodeName,NumberOfLines]=...
    ppgui_Parameters2String(SingleProcessStats,CorrelatedProcessStats,...
    TrialParameters)
% Displays the Data according to the settings in the DisplayParameters
%
%   INPUT:  SingleProcessStats    -   struct containing the settings in
%                                     the 'Single Process Statistics' Panel
%           CorrelatedProcessStats - struct containing the settings in
%                                    the 'Correlated Process Statistics' 
%                                    Panel
%           TrialParamters    -   struct containing the settings in
%                                       the 'Trial Parameters'
%                                       Panel      
%
%   OUTPUT:   ParameterString: A string containing the name of the
%               paramters and their values
%             CodeName: Name of the code to produce .gdf
%             NumberOfLines -   the number of lines of the paramtersString
%
%   USES: 
%   Benjamin Staude, Berlin  16/12/05 (staude@neurobiologie.fu-berlin.de)
% Part of the ParaProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LineStart='%    ';
%ParameterString(1)={'%%% Parameter Settings  %%%'};
ParameterString(1)={'%'};
%LineId=length(ParamterString)+1;
CodeName(1)={'gdf = '};

RateValue = -1;

if TrialParameters.isSingleProcess

    %%% Neccessary Parameters  %%%
    switch SingleProcessStats.ProcessType
        case 'StatPoisson'
            ParameterString(2)={[LineStart 'Process Type: Stationary Poisson']};
            CodeName(1)={[CodeName{1} 'pp_PoissonData(' num2str(TrialParameters.NumberOfProcesses) ]};
        case 'NonStatPoisson'
            ParameterString(2)={[LineStart 'Process Type: Nontationary Poisson']};
            CodeName(1)={[CodeName{1} 'pp_PoissonData(' num2str(TrialParameters.NumberOfProcesses) ]};
        case 'Gamma'
            ParameterString(2)={[LineStart 'Process Type:' 'Gamma (' SingleProcessStats.GammaType '), Order = ' num2str(SingleProcessStats.Order) ]};
            CodeName(1)={[CodeName{1} 'pp_GammaData(' num2str(TrialParameters.NumberOfProcesses) ]};
    end
    
    switch SingleProcessStats.RateValue
        case 1
            ParameterString(3)={[LineStart 'Rate: ' num2str(SingleProcessStats.Rate) ' Hz']};
            CodeName(1)={[CodeName{1} ',' num2str(SingleProcessStats.Rate)]};
            RateValue=1;
        case 0
            ParameterString(3)={[LineStart 'Rate file: ' SingleProcessStats.RateFileName]};
            CodeName(1)={[CodeName{1} ',RATEFILE']};
            RateValue=0;
    end

else % SIP
    ParameterString(2)={[LineStart 'Process Type: SIP Poisson']};
    CodeName(1)={[CodeName{1} 'pp_SipData(' ...
        num2str(CorrelatedProcessStats.CorrCoefficient) ',' ...
        num2str(TrialParameters.NumberOfProcesses) ]};
    
    ParameterString(3)={[LineStart 'Rate: ' ...
        num2str(CorrelatedProcessStats.Rate) ' Hz']};
    CodeName(1)={[CodeName{1} ',' num2str(CorrelatedProcessStats.Rate)]};
            %RateValue=1;
end


ParameterString(4)={[LineStart 'Number of processes: ' num2str(TrialParameters.NumberOfProcesses) ]}; 
if strncmp(SingleProcessStats.ProcessType,'Gam',3)
    CodeName(1)={[CodeName{1} ',' num2str(SingleProcessStats.Order) ]};
end
%keyboard
ParameterString(5)={[LineStart 'Trial Duration: ' num2str(TrialParameters.TrialDurationS) ' seconds']};
CodeName(1)={[CodeName{1} ',' num2str(TrialParameters.TrialDurationS) ]};

if strncmp(SingleProcessStats.ProcessType,'Gam',3) & strncmp(SingleProcessStats.GammaType,'Ordi',4)
            CodeName(1)={[CodeName{1} ',''Type'',''ordinary''' ]};
end
LineId=6;



%%% Optional Paramters  %%%

%if TrialParameters.NumberOfTrials>1
%    ParameterString(LineId)={[LineStart 'Number of trials: ' num2str(TrialParameters.NumberOfTrials) ]};
%    if TrialParameters.TrialOffset>0
%        ParameterString(LineId+1)={[LineStart 'Trial Offset: ' num2str(TrialParameters.TrialOffsetMs) ' ms' ]};
%        LineId=LineId+1;
%    end
%   ParameterString(LineId+1)={[LineStart 'Marker: ' num2str(TrialParameters.Marker) ]};
%   LineId=LineId+1;
%end
% if TrialParameters.StartOfExperiment>0
%     ParameterString(LineId)={[LineStart 'Start of experiment: ' num2str(TrialParameters.StartOfExperimentS) ' seconds']};
%     LineId=LineId+1;
%     
% end
if SingleProcessStats.UnitMs~=1 | SingleProcessStats.PrecisionMs~=realmin | SingleProcessStats.Clipping~=0;
    %keyboard
    %CodeName(1)={CodeName};
    CodeName(2)={'gdf = pp_ConvertTimeSettings(gdf'};
    if SingleProcessStats.UnitMs~=1;
        ParameterString(LineId)={[LineStart 'Units: ' num2str(SingleProcessStats.UnitMs) ' ms']};
        LineId=LineId+1;
        CodeName(2)={[CodeName{2} ',''Unit'',' num2str(SingleProcessStats.UnitMs)]};
    end

    if SingleProcessStats.PrecisionMs~=realmin;
            ParameterString(LineId)={[LineStart 'Precision: ' num2str(SingleProcessStats.PrecisionMs) ' ms']};
            LineId=LineId+1;
            CodeName(2)={[CodeName{2} ',''Precision'',' num2str(SingleProcessStats.PrecisionMs)]};
    end
end
if SingleProcessStats.Clipping~=0;
        ParameterString(LineId)={[LineStart 'Clipping: on']};
        LineId=LineId+1;
        CodeName(3)={'gdf = pp_Clipping(gdf'};
end


if ~TrialParameters.isSingleProcess
    ParameterString(LineId)={[LineStart ...
        'Pairwise correlation coefficient: ' ...
        num2str(CorrelatedProcessStats.CorrCoefficient)]};
    LineId=LineId+1;
end
        
for k=1:length(CodeName)
    CodeName(k)={[CodeName{k} ');']};
end

if ~RateValue
    CodeName(end+1)={''};
    CodeName(end+1)={['% --- WARNING: YOU MUST HAVE THE ''RATEFILE'' IN YOUR WORKSPACE !!! --- ']};
end
NumberOfLines=LineId-1;



% ParameterString(1)={'kalle'};
% ParameterString(2)={'jens'};
