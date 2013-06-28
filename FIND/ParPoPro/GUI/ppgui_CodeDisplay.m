function ppgui_CodeDisplay(handles);
% Displays Code used to generate the Data, given the paramtersettings in
% the gui
%
%   INPUT:  handles -   
%         
%         
%
%   OUTPUT:   
%
%
%   USES: 
%   Benjamin Staude, Berlin  16/12/05 (staude@neurobiologie.fu-berlin.de)
% Part of the ParaProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[SingleProcessStats,TrialParameters,DisplayParameters,...
    DirectoryAndFileNames,CorrelatedProcessStats]=...
    ppgui_UpdateParameterValues(handles);
ErrorCount=ppgui_CheckParameterCompatibilities(SingleProcessStats,...
    CorrelatedProcessStats,TrialParameters,DisplayParameters,handles);
if ErrorCount>0
    return
end
%Construct the string to be displayed
FirstLine=['%' repmat('-',1,45) 'CUT HERE' repmat('-',1,45)];
%DisplayString(1)={FirstLine};
DisplayString(2)={'% The following code produces a .gdf OF ONE TRIAL STARTING AT 0,'};
DisplayString(3)={'%  using the following parameter values:'};
[ParameterString,CodeName,NumberOfLines]=...
    ppgui_Parameters2String(SingleProcessStats,CorrelatedProcessStats,...
    TrialParameters);
LineId=3;
%keyboard
for k=1:NumberOfLines
    DisplayString(LineId+1)={ParameterString{k}};
    LineId=LineId+1;
end
DisplayString(end+1)={''};
for i=1:length(CodeName)
    DisplayString(end+1)={['    ' CodeName{i}]};
end
DisplayString(end+1)={''};
%DisplayString(end+1)={['%' repmat('-',1,45) 'CUT HERE' repmat('-',1,45)]};
%keyboard

ppgui_CodeDisplayGui(DisplayString);
%keyboard