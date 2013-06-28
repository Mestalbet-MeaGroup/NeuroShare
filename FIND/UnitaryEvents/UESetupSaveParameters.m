function UESetupMakeDefaultParameterFile()
% function UESetupMakeDefaultParameterFile()
% creates new UEParameters_Default.mat file
% ******************************************************************
% *                                                                *
% * Usage:   Function creates a new UEParameters_Default.mat file, *
% *          containing a handles structure with members set in    *
% *          the "Write new default Parameter File" section.       *
% *                                                                *
% * History:                                                       *
% *                                                                *
% ******************************************************************

% ******************************************************************
% *                                                                *
% *  Initialize Default Parameters of handles structure            *
% *                                                                *
% ******************************************************************
    
handles.DataFile.FileName = '';
handles.DataFile.OutPath = '';
handles.DataFile.OutFileName = '';
handles.DataFile.SaveResult.Mode = 'off';
handles.DataFile.NeuronList = [];
handles.DataFile.EventList = [];
handles.DataFile.CutEvent = [];
handles.DataFile.TPre = -500;
handles.DataFile.TPost = 1000;
handles.DataFile.TimeUnits = 1;
handles.DataFile.TrialOverlapMode = 'causal';
handles.DataFile.GeneralOptions.Compatibility = 'IDLVersion';
handles.DataFile.GeneralOptions.TimeDisplayMode = 'real';
handles.DataFile.GeneralOptions.SpikeDataFormat = 'gdfcell';
handles.DataFile.GeneralOptions.ShowSplashScreen = 'on';
handles.DataFile.SelectMode = 'none';
handles.DataFile.SelectEvent = [];
handles.DataFile.SortMode = 'none';
handles.DataFile.SortEvent = [];
handles.DataFile.ShiftMode = 'none';
handles.DataFile.ShiftWidth = [100];
handles.DataFile.ShiftNeuronList = [7];
handles.DataFile.Analysis.Alpha = 0.05;
handles.DataFile.Analysis.Complexity = 2;
handles.DataFile.Analysis.ComplexityMax = 2;
handles.DataFile.Analysis.Binsize = 5;
handles.DataFile.Analysis.TSlid = 100;
handles.DataFile.Analysis.UEMethod = 'trialaverage';
handles.DataFile.Analysis.Wildcard = 'off';
handles.DataFile.UEMWAFigure.Display = 'screen';
handles.DataFile.UEMWAFigure.FileDevice = 'eps';
handles.DataFile.UEMWAFigure.PrintDevice = 'off';
handles.DataFile.UEMWAFigure.Text = handles.DataFile.OutFileName;
handles.DataFile.UEMWAFigure.FileName = [handles.DataFile.OutFileName 'UE'];
handles.DataFile.UEMWAFigure.EventsToPlot = handles.DataFile.OutFileName;
handles.DataFile.UEMWAFigure.TextFontSize = 18;
handles.DataFile.UEMWAFigure.VerticalLinePosInMS = [-500 0 500 1000 1500];
handles.DataFile.UEMWAFigure.VerticalLineStyle = {'-','-','-','-','-'};
handles.DataFile.UEMWAFigure.VerticalLineWidth = {0.75, 0.75, 0.75, 0.75, 0.75};
handles.DataFile.UEMWAFigure.VerticalLineText = {'-500' handles.DataFile.CutEvent '500' '1000' '1500'};
handles.DataFile.SignFigure.Display = 'screen';
handles.DataFile.SignFigure.FileDevice = 'eps';
handles.DataFile.SignFigure.PrintDevice = 'off';
handles.DataFile.SignFigure.FileName = handles.DataFile.OutFileName;
handles.DataFile.SignFigure.Text = 'default';
handles.DataFile.SignFigure.PatSel = ':';
handles.DataFile.SignFigure.TextFontSize = handles.DataFile.UEMWAFigure.TextFontSize;
handles.DataFile.SignFigure.EventsToPlot = handles.DataFile.UEMWAFigure.EventsToPlot;
handles.DataFile.SignFigure.VerticalLinesPosInMS = handles.DataFile.UEMWAFigure.VerticalLinePosInMS;
handles.DataFile.SignFigure.VerticalLineStyle = handles.DataFile.UEMWAFigure.VerticalLineStyle;
handles.DataFile.SignFigure.VerticalLineWidth = handles.DataFile.UEMWAFigure.VerticalLineWidth;
handles.DataFile.SignFigure.VerticalLineText = handles.DataFile.UEMWAFigure.VerticalLineText;
handles.DataFile.DotDisplay.TrialDisplayMode = 'from_top';
handles.DataFile.DotDisplay.Interactive = 'off';
handles.DataFile.DotDisplay.DotMarker = 'o';
handles.DataFile.DotDisplay.DotColor = [0 0 0];
handles.DataFile.DotDisplay.DotHeightPercentage = 0.01;
handles.DataFile.DotDisplay.Raw.Marker = 's';
handles.DataFile.DotDisplay.Raw.Color = [0 1 0];
handles.DataFile.DotDisplay.Raw.MarkerHeightPercentage = 0.1;
handles.DataFile.DotDisplay.UE.Marker = 's';
handles.DataFile.DotDisplay.UE.Color = [1 0 0];
handles.DataFile.DotDisplay.UE.MarkerHeightPercentage = 0.1;
handles.DataFile.DotDisplay.Behavior.Marker = 'd';
handles.DataFile.DotDisplay.Behavior.Color = [0 0 1];
handles.DataFile.DotDisplay.Behavior.MerkerHeightPercentage = 0.1;
handles.DataFile.FontSize = 14;

save UEParameters_Default handles;
