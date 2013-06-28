function ppgui_Setup_FillParameter(handles,SingleProcessStats,TrialParameters,DisplayParameters,DirectoryAndFileNames);
%
%   Input: handles
%          SingleProcessStats
%          TrialParamters
%          DirectoryAndFileNames
%   Set the values of the gui parameters specified in in the input
%   structures.
%
% REAMRKS: Display Values are beeing cleared !!!
% Benjamin Staude (staude@neurobiologie.fu-berlin.de)
% 8.12.05
% Part of the Point Process ToolBox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% File/Diretory Names   %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(DirectoryAndFileNames,'WorkingDirectory')
    set(handles.WorkingDirectory,'String',...
        DirectoryAndFileNames.WorkingDirectory);
else
    set(handles.WorkingDirectory,'String',pwd);
end



%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% Single Process Panel  %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.RateValue,'Enable','on');
set(handles.RateFile,'Enable','on');
if ~isfield(SingleProcessStats,'ProcessType')
  display('Please check process type');
   set(handles.ProcessType,'Value',1); 
   %set(handles.RateValue,'Value',1);
   set(handles.Order,'Enable','off');
   set(handles.Order_txt,'Enable','off');
   set(handles.GammaType,'Enable','off');
else
  switch SingleProcessStats.ProcessType
      case 'StatPoisson'
          set(handles.ProcessType,'Value',1);
          set(handles.RateValue,'Value',SingleProcessStats.RateValue);
          set(handles.RateFile,'Value',SingleProcessStats.RateFile);
          set(handles.Order,'Enable','off');
          set(handles.Order_txt,'Enable','off');
          set(handles.GammaType,'Enable','off');
      case'NonStatPoisson'
          set(handles.ProcessType,'Value',2);          
          set(handles.RateValue,'Value',SingleProcessStats.RateValue);
          set(handles.RateFile,'Value',SingleProcessStats.RateFile);
          set(handles.RateValue,'Value',0);
          set(handles.RateValue,'Enable','off');
          set(handles.Rate,'Enable','off');
          set(handles.RateUnit,'Enable','off');
          set(handles.ProcessType,'Value',2);
          set(handles.Order,'Enable','off');
          set(handles.Order_txt,'Enable','off');
          set(handles.GammaType,'Enable','off');
      case 'Gamma'
          set(handles.ProcessType,'Value',3);
          set(handles.RateValue,'Value',SingleProcessStats.RateValue);
          set(handles.RateFile,'Value',SingleProcessStats.RateFile);
  end
end
switch SingleProcessStats.RateValue
    case 1
        set(handles.RateValue,'Enable','on');
        set(handles.RateUnit,'Enable','on');
        set(handles.Rate,'Enable','on');
        set(handles.Rate,'String',num2str(SingleProcessStats.Rate));
        set(handles.RateFile,'Value',0);
        set(handles.BrowseRateFile,'Enable','off');
        set(handles.RateFileName,'Enable','off');
    case 0
        set(handles.RateFile,'Enable','on');
        set(handles.BrowseRateFile,'Enable','on');
        set(handles.RateUnit,'Enable','off');
        set(handles.RateFileName,'String',num2str(SingleProcessStats.RateFileName));
end

% if isfield(SingleProcessStats,'Rate')
%     set(handles.Rate,'String',SingleProcessStats.Rate);
% else
%     set(handles.Rate,'String','');
% end

if isfield(SingleProcessStats,'Order')
    set(handles.Order,'String',SingleProcessStats.Order);
else
    set(handles.Order,'String','');
end

if isfield(SingleProcessStats,'UnitMs') & (SingleProcessStats.UnitMs~=1)
    set(handles.UnitMs,'String',SingleProcessStats.UnitMs);
else
    set(handles.UnitMs,'String','');
end

%keyboard
if isfield(SingleProcessStats,'PrecisionMs') & (SingleProcessStats.PrecisionMs~=realmin)
   set(handles.PrecisionMs,'String',SingleProcessStats.PrecisionMs);
else
   set(handles.PrecisionMs,'String','');
end

if isfield(SingleProcessStats,'Clipping')
    %switch SingleProcessStats
    set(handles.Clipping,'Value',SingleProcessStats.Clipping+1);
else
    set(handles.Clipping,'Value',1)
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
% Trial Panel           %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(TrialParameters,'NumberOfProcesses')
    set(handles.NumberOfProcesses,'String',...
        TrialParameters.NumberOfProcesses);
else
    set(handles.NumberOfProcesses,'String','');    
end

if isfield(TrialParameters,'NumberOfTrials')
    set(handles.NumberOfTrials,'String',...
        TrialParameters.NumberOfTrials);
else
    set(handles.NumberOfTrials,'String',''); 
end

if isfield(TrialParameters,'TrialDuration')
    set(handles.TrialDuration,'String',TrialParameters.TrialDuration);
else
    set(handles.TrialDuration,'String','');
end
if isfield(TrialParameters,'TrialDurationUnit')
    if TrialParameters.TrialDurationUnit==1
        set(handles.TrialDurationUnit,'Value',1)
    else
        set(handles.TrialDurationUnit,'Value',2)
    end
end

if isfield(TrialParameters,'TrialOffset')
    set(handles.TrialOffset,'String',TrialParameters.TrialOffset);
else
    set(handles.TrialOffset,'String','');
end
if isfield(TrialParameters,'TrialOffsetUnit')
    if TrialParameters.TrialOffsetUnit==1
        set(handles.TrialOffsetUnit,'Value',1)
    else
        set(handles.TrialOffsetUnit,'Value',2)
    end
end



if isfield(TrialParameters,'Marker')
    set(handles.Marker,'String',TrialParameters.Marker);
else
    set(handles.Marker,'String','');
end

if isfield(TrialParameters,'StartOfExperiment')
    set(handles.StartOfExperiment,'String',TrialParameters.StartOfExperiment);
else
    set(handles.StartOfExperiment,'String','');
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
%  Display Panel        %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%



if isfield(DisplayParameters,'DotDisplay')
    set(handles.DotDisplay,'Value',DisplayParameters.DotDisplay);
else
    set(handles.DotDisplay,'Value',0);    
end
if get(handles.DotDisplay,'Value')
    set(handles.DotMarkerStyle,'Enable','on')
    set(handles.DotMarkerStyle_txt,'Enable','on')
else
    set(handles.DotMarkerStyle,'Enable','off')
    set(handles.DotMarkerStyle_txt,'Enable','off')
end

% ISI
if isfield(DisplayParameters,'ISI')
    set(handles.ISI,'Value',DisplayParameters.ISI);
else
    set(handles.ISI,'Value',0);
end
% Enable/Disable corresponding GUI fields fo ISI
if get(handles.ISI,'Value')
    set(handles.ISIProcess_txt,'Enable','on');
    set(handles.ISIFirstProcess,'Enable','on');
    set(handles.ISIto_txt,'Enable','on');
    set(handles.ISILastProcess,'Enable','on');
    set(handles.ISIBinSizeMs,'Enable','on');
    set(handles.ISIBinSize_txt,'Enable','on');
    set(handles.ISIBinSizeUnit_txt,'Enable','on');
else
    set(handles.ISIProcess_txt,'Enable','off');
    set(handles.ISIFirstProcess,'Enable','off');
    set(handles.ISIto_txt,'Enable','off');
    set(handles.ISILastProcess,'Enable','off');
    set(handles.ISIBinSizeMs,'Enable','off');
    set(handles.ISIBinSize_txt,'Enable','off');
    set(handles.ISIBinSizeUnit_txt,'Enable','off');
end
if isfield(DisplayParameters,'ISIFirstProcess')
    set(handles.ISIFirstProcess,'String',DisplayParameters.ISIFirstProcess);
else
    set(handles.ISIFirstProcess,'String','');
end
if isfield(DisplayParameters,'ISILastProcess')
    set(handles.ISILastProcess,'String',DisplayParameters.ISILastProcess);
else
    set(handles.ISILastProcess,'String','');
end
if isfield(DisplayParameters,'ISIBinSizeMs')
    set(handles.ISIBinSizeMs,'String',DisplayParameters.ISIBinSizeMs);
else
    set(handles.ISIBinSizeMs,'String','');
end


%% Count Statistics %%
if isfield(DisplayParameters,'CountStatistics')
    set(handles.CountStatistics,'Value',DisplayParameters.CountStatistics);
else
    set(handles.CountStatistics,'Value',0);
end
if get(handles.CountStatistics,'Value')
    set(handles.CountBinSize_txt,'Enable','on');
    set(handles.CountBinSize,'Enable','on');
    %set(handles.CountBinSize,'String',num2str(DisplayParameters.BinSize));
    set(handles.CountBinSizeUnit,'Enable','on');
    set(handles.CountDistributions,'Enable','on');
    set(handles.PopulationHistogram,'Enable','on');
    set(handles.ComplexityDistribution,'Enable','on');
    if isfield(DisplayParameters,'CountDistributions')
        set(handles.CountDistributions,'Value',DisplayParameters.CountDistributions)
    else
        set(handles.CountDistributions,'Value',0)
    end
    if get(handles.CountDistributions,'Value')
        set(handles.CountProcess_txt,'Enable','on');
        set(handles.CountFirstProcess,'Enable','on');
        set(handles.Countto_txt,'Enable','on');
        set(handles.CountLastProcess,'Enable','on');
    else
        set(handles.CountProcess_txt,'Enable','off');
        set(handles.CountFirstProcess,'Enable','off');
        set(handles.Countto_txt,'Enable','off');
        set(handles.CountLastProcess,'Enable','off');
    end  
else
    set(handles.CountBinSize_txt,'Enable','off');
    set(handles.CountBinSize,'Enable','off');
    set(handles.CountProcess_txt,'Enable','off');
    set(handles.CountFirstProcess,'Enable','off');
    set(handles.Countto_txt,'Enable','off');
    set(handles.CountLastProcess,'Enable','off');
    %set(handles.CountBinSize,'String',num2str(DisplayParameters.BinSize));
    set(handles.CountBinSizeUnit,'Enable','off');
    set(handles.CountDistributions,'Enable','off');
    set(handles.PopulationHistogram,'Enable','off');
    set(handles.ComplexityDistribution,'Enable','off');
end

    
if isfield(DisplayParameters,'CountBinSizeMs')
    set(handles.CountBinSize,'String',num2str(DisplayParameters.CountBinSizeMs))
else
    set(handles.CountBinSize,'String','')
end
if isfield(DisplayParameters,'CountFirstProcess')
    set(handles.CountFirstProcess,'String',num2str(DisplayParameters.CountFirstProcess))
else
    set(handles.CountFirstProcess,'String','')
end
if isfield(DisplayParameters,'CountLastProcess')
    set(handles.CountLastProcess,'String',num2str(DisplayParameters.CountLastProcess))
else
    set(handles.CountLastProcess,'String','')
end





